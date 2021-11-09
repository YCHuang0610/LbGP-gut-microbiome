#normOTUtable, and average


import  pandas as pd


otutab = pd.read_csv('result/otutab.txt',sep='\t',header=0,index_col=0)
metadata = pd.read_csv('metadata.txt',sep='\t',header=0)
group = pd.Series(metadata['Group'].values,index=metadata['SampleID'])
df = pd.DataFrame(index=otutab.index.tolist())

def summ(gro_sample):
    global otutab
    sum_series = pd.Series(0,index=otutab.index.tolist())
    for i in gro_sample:
        sum_series += otutab[i]
    return sum_series


for gro in group.unique():
    gro_sample = group[group.values == gro].index.tolist()
    df[gro] = summ(gro_sample)

df['All'] = df.sum(axis=1)

for col in df.columns.tolist():
    df[col] = df[col]/df[col].sum()*100

df.to_csv('result/otutab_mean.txt',sep='\t')