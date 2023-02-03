# DAL Library
# version 2.1

# depends dal_transform.R
# depends ts_data.R
# depends ts_regression.R
# depends ts_preprocessing.R

# class ts_tlstm
# loadlibrary("reticulate")
# source_python('ts_tlstm.py')

import torch
import torch.nn as nn
from torch.utils.data import Dataset, DataLoader
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os
from torch.utils.data import TensorDataset
import torch.nn.functional as F
import sys
import random


def savemodel(model, filename):
  torch.save(model, filename)
  

def loadmodel(filename):
  model = torch.load(filename)
  model.eval()
  return(model)


def savedf(data, filename):      
  data.to_csv(filename, index=False)
    

class LSTMNet(nn.Module):
  def __init__(self, n_neurons, input_shape):
    super(LSTMNet, self).__init__()
    self.lstm = nn.LSTM(input_size=input_shape, hidden_size=n_neurons)
    self.fc = nn.Linear(n_neurons, 1)
  
  def forward(self, x):
    out, _ = self.lstm(x)
    out = self.fc(out)
    return out


def torch_fit_lstm(epochs, lr, model, train_loader, opt_func=torch.optim.SGD, debug=False):
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
      
      #print('Done computing loss.')
      
      # backward pass: compute gradient of the loss with respect to model parameters
      loss.backward()
      # perform a single optimization step (parameter update)
      optimizer.step()
      # record training loss
      train_losses.append(loss.item())
    
    ######################    
    # validate the model #
    ######################
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

  if debug:
    epoch_len = len(str(epochs))
    print_msg = (f'[{epoch:>{epoch_len}}/{epochs:>{epoch_len}}] ' +
                 f'train_loss: {train_loss:.5f}')
    print(print_msg)

  return model, avg_train_losses


def create_torch_lstm(n_neurons, look_back):
  n_neurons = int(n_neurons)
  look_back = int(look_back)
  device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
  model = LSTMNet(n_neurons, look_back).to(device)
  return model    
	

def train_torch_lstm(model, df_train, n_epochs = 10000, lr = 0.001, deep_debug=False, reproduce=True):
  if (reproduce):
    torch.manual_seed(0)    
    np.random.seed(0)
    random.seed(0)

  X_train = df_train.drop('t0', axis=1).to_numpy()
  y_train = df_train.t0.to_numpy()
  X_train = X_train[:, :, np.newaxis]
  y_train = y_train[:, np.newaxis]	
  train_x = torch.from_numpy(X_train)
  train_y = torch.from_numpy(y_train)
  train_x = torch.permute(train_x, (2, 0, 1))
  train_labels = torch.permute(train_y, (1, 0))
  train_labels = train_labels[:, :, None]
  train_ds = TensorDataset(train_x, train_labels)
  
  BATCH_SIZE = 8
  train_loader = torch.utils.data.DataLoader(train_ds, batch_size = BATCH_SIZE, shuffle = False)
  
  model = model.float()
  n_epochs = int(n_epochs)
  model, train_loss = torch_fit_lstm(n_epochs, lr, model, train_loader, opt_func=torch.optim.Adam, debug = deep_debug)
  
  return model

	

def predict_torch_lstm(model, df_test):
  X_test = df_test.drop('t0', axis=1).to_numpy()
  y_test = df_test.t0.to_numpy()
  X_test = X_test[:, :, np.newaxis]
  y_test = y_test[:, np.newaxis]
  test_x = torch.from_numpy(X_test)
  test_labels = torch.from_numpy(y_test)
  test_x = torch.permute(test_x, (2, 0, 1))	
  test_labels = torch.permute(test_labels, (1, 0))
  test_labels = test_labels[:, :, None]
  test_ds = TensorDataset(test_x, test_labels)
  
  BATCH_SIZE = 8
  test_loader = torch.utils.data.DataLoader(test_ds, batch_size = BATCH_SIZE, shuffle = False)
  
  outputs = []
  with torch.no_grad():
    for xb, yb in test_loader:
      output = model(xb.float())
      outputs.append(output.flatten())

  test_predictions = torch.vstack(outputs).squeeze(1)  
  test_predictions = test_predictions.flatten().numpy()

  return test_predictions
