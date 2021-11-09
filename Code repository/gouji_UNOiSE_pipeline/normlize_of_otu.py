'''
OTUnorm
'''
import sys
import pandas as pd
import numpy as np
from collections import Counter
df = pd.read_table('result/otutab.txt',header=0,index_col=0)
size = int(sys.argv[1])
print(df)
def flattt(df):
    #Flatten each column into one dimension 
    dict = {}
    for col in df.columns.tolist():
        s = df[col]
        list = np.repeat(s.index.tolist(),s.values)
        dict[col] = list
    return dict

dict = flattt(df)

def choice_count(list,size):
    #Sample each column without putting back and count the number of occurrences of each element after sampling
    list_choice = np.random.choice(list,size,replace=False, p=None)
    dict_count = Counter(list_choice)
    return dict_count


#return to dataframe
df_dict = {}
for col in df.columns.tolist():
    df_dict[col] = pd.Series(choice_count(dict[col],size),index=df._stat_axis) #dataframe的行名是df._stat_axis
df_rare = pd.DataFrame(df_dict)
df_rare = df_rare.fillna(0)
df_rare = df_rare.astype(int)

print(df_rare)

df_rare.to_csv('result/otutab_rare.txt', sep='\t')