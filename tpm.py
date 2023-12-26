import pandas as pd
import numpy as np
import sys 

input_file= sys.argv[1]
output_file= sys.argv[2]

samples=[line.rstrip() for line in open("samples")]
header=["chrom", "start", "end", "gene"]+ samples               #adding headers

df=pd.read_csv(input_file, names=header, sep="\t")             #headers applied in the csv file
#print(df)

df=df.sort_values("gene")                                       #sorting the values wrt gene
#print(df)

df=df.drop_duplicates(subset=["gene"], keep="last")             #taking out all the duplicates from the df
#print(df)

gene_length=(df['end']-df['start']).tolist()                    #calculating gene length (end-start)=length and adding it to list

onlyGenes={'Genes':df["gene"].tolist()}                         #only genes from the dataframe is loaded in TPM_df
TPM_df=pd.DataFrame(onlyGenes)      
#print(TPM_df)

for col_name in samples:        
    reads=df[col_name].tolist()                                 #read count from the sample added to list
    A_val=[]
    A_val=[((x*1000)/gene_length) for x, gene_length in zip(reads, gene_length)]        #formula for calculating A
    sum_A=sum(A_val)                                            #taking sum of A_val
   # print(sum_A)
    TPM=[]                                                      #creating a list TPM
    TPM=[A*(1/sum_A)*1000000 for A in A_val]                    #tpm formula
    TPM_df[col_name]=TPM                                        #TPM_df and calculated tpm values stored in TPM

TPM_df=TPM_df.round(4)                                          #TPM values rounded upto 4 places
#print(TPM_df)
TPM_df.to_csv(output_file, sep="\t")                        #saving in csv file 
