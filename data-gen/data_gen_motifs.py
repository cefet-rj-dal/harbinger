#pip install -U pyreadr
#pip install -U wfdb

import wfdb
import pandas as pd
import pyreadr
import numpy as np


def read_data(name):
  data = wfdb.rdrecord(name, sampfrom = 0, pn_dir = 'mitdb')
  data = pd.DataFrame(data.p_signal, columns = data.sig_name)
  pyreadr.write_rdata('data-gen/' + name + '.rdata', data, df_name="data", compress="gzip")
  return(data)

def read_ann(name):
  ann = wfdb.rdann(name, 'atr', pn_dir = 'mitdb')
  ann = pd.DataFrame({'anot':ann.sample, 'symbol':np.array(ann.symbol)})
  pyreadr.write_rdata('data-gen/' + name+'-anot.rdata', ann, df_name="anot", compress="gzip")
  return(ann)


data = read_data("100")
ann = read_ann("100")

data = read_data("102")
ann = read_ann("102")

