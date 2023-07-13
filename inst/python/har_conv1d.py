import torch
import torch.nn as nn
from torch.utils.data import Dataset, DataLoader
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from torch.utils.data import TensorDataset
import torch.nn.functional as F
import sys
import functools
import operator

class Conv1DNet(nn.Module):
    def __init__(self, in_channels, input_dim):
        super(Conv1DNet,self).__init__()
        ksize = 2
        if (input_dim == 1): 
          ksize = 1
        
        self.feature_extractor = nn.Sequential(
            nn.Conv1d(in_channels = in_channels, out_channels = 64, kernel_size = ksize),
            nn.ReLU(inplace=True)
        )
        
        # https://datascience.stackexchange.com/questions/40906/determining-size-of-fc-layer-after-conv-layer-in-pytorch
        num_features_before_fcnn = functools.reduce(operator.mul, list(self.feature_extractor(torch.rand(1, input_dim)).shape))
        
        self.regressor = nn.Sequential(
            nn.Linear(in_features=num_features_before_fcnn, out_features=50),
            nn.ReLU(inplace=True),
            nn.Linear(50, 1)
        )

    def forward(self,x):
        out = self.feature_extractor(x)
        out = nn.Flatten(1, -1)(out)
        out = self.regressor(out)
        return out
      

def create_torch_conv1d(in_channels, input_dim):
  in_channels = int(in_channels)
  input_dim = int(input_dim)
  device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
  model = Conv1DNet(in_channels, input_dim).to(device)
  return(model)  


def torch_fit_conv1d(epochs, lr, model, train_loader, opt_func=torch.optim.SGD):
  # to track the training loss as the model trains
  
  train_losses = []
  # to track the average training loss per epoch as the model trains
  avg_train_losses = []
  
  criterion = nn.MSELoss()
  last_error = sys.float_info.max
  last_epoch = 0
  
  convergency = epochs/10
  if (convergency < 100):
    convergency = 100
  
  optimizer = opt_func(model.parameters(), lr)
  for epoch in range(epochs):
    ###################
    # train the model #
    ###################
    model.train() # prep model for training
    for data, target in train_loader:
      # clear the gradients of all optimized variables
      model.zero_grad()
      # forward pass: compute predicted outputs by passing inputs to the model
      output = model(data.float())
      
      #print('Going to compute loss...')
      # calculate the loss
      loss = criterion(output, target.float())
      
      # backward pass: compute gradient of the loss with respect to model parameters
      loss.backward()
      # perform a single optimization step (parameter update)
      optimizer.step()
      # record training loss
      train_losses.append(loss.item())
    
    # validate the model #
    model.eval() # prep model for evaluation
    
    # print training/validation statistics 
    # calculate average loss over an epoch
    train_loss = np.average(train_losses)
    avg_train_losses.append(train_loss)
    
    if ((last_error - train_loss) > 0.001):
      last_error = train_loss
      last_epoch = epoch

    # clear lists to track next epoch
    train_losses = []
    
    if (train_loss == 0):
      break
        
    if (epoch - last_epoch > convergency):
      break

  return model, avg_train_losses


def train_torch_conv1d(model, df_train, n_epochs = 3000, lr = 0.001):
  n_epochs = int(n_epochs)
  
  X_train = df_train.drop('t0', axis=1).to_numpy()
  y_train = df_train.t0.to_numpy()
  
  X_train = X_train[:, :, np.newaxis]
  y_train = y_train[:, np.newaxis]
  
  train_x = torch.from_numpy(X_train)
  train_y = torch.from_numpy(y_train)
  
  train_x = torch.permute(train_x, (0, 2, 1))

  train_ds = TensorDataset(train_x, train_y)
  
  BATCH_SIZE = 8
  train_loader = torch.utils.data.DataLoader(train_ds, batch_size = BATCH_SIZE, shuffle = False)
  
  model = model.float()
  model, train_loss = torch_fit_conv1d(n_epochs, lr, model, train_loader, opt_func=torch.optim.Adam)

  return model


def predict_torch_conv1d(model, df_test):
  X_test = df_test.drop('t0', axis=1).to_numpy()
  y_test = df_test.t0.to_numpy()
  
  X_test = X_test[:, :, np.newaxis]
  y_test = y_test[:, np.newaxis]
  
  test_x = torch.from_numpy(X_test)
  test_y = torch.from_numpy(y_test)
  
  test_x = torch.permute(test_x, (0, 2, 1))	

  test_ds = TensorDataset(test_x, test_y)
  
  BATCH_SIZE = 8
  test_loader = torch.utils.data.DataLoader(test_ds, batch_size = BATCH_SIZE, shuffle = False)
  
  outputs = []
  with torch.no_grad():
    for xb, yb in test_loader:
      output = model(xb.float())
      outputs.append(output)
  
  test_predictions = torch.vstack(outputs).squeeze(1)  
  test_predictions = test_predictions.flatten().numpy()
  
  return test_predictions

