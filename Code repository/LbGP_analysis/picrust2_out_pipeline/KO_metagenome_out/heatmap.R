library(edgeR)
# create DGE list
design <- read.table("metadata.txt", header=T, row.names=1, sep="\t") 
data <- read.table("picrust2_out_pipeline/KO_metagenome_out/metrics_of_level_3.txt",header = T,row.names = 1,sep = '\t')
counts <- data
counts_DSS<- subset(counts[,1:5])
counts_LbGP <- subset(counts[,6:10])

DSSLbGP <- cbind(counts_DSS,counts_LbGP)
group <- c(rep("DSS",5),rep("LbGP",5))
d <- DGEList(counts=DSSLbGP, group=group)
d = calcNormFactors(d)


design.mat = model.matrix(~ 0 + d$samples$group)
colnames(design.mat)=c('DSS','LbGP')
d2 = estimateGLMCommonDisp(d, design.mat)
d2 = estimateGLMTagwiseDisp(d2, design.mat)
fit = glmFit(d2, design.mat)


BvsA <- makeContrasts(contrasts = "DSS-LbGP", levels=design.mat)
# calculate Fold change, Pvalue
lrt = glmLRT(fit,contrast=BvsA)
# FDRtest
de_lrt = decideTestsDGE(lrt, adjust.method="fdr", p.value=0.05)

x=lrt$table
x$sig=de_lrt
enriched = row.names(subset(x,sig==1))
depleted = row.names(subset(x,sig==-1))

library(pheatmap)
pair_group = subset(design, Group %in% c("W2_DSS", "W2_LbGP"))
# Sig OTU in two genotype
DE=c(enriched,depleted)
sub <- DSSLbGP[DE,]
pheatmap(sub,scale='row',cluster_rows = T,cluster_cols = F,border_color=NA)





