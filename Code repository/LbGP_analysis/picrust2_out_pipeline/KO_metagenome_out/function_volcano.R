library( "edgeR" )
design <- read.table("metadata.txt", header=T, row.names=1, sep="\t") 
data <- read.table("picrust2_out_pipeline/KO_metagenome_out/pred_metagenome_unstrat_descrip.tsv",header = T,row.names = 1,sep = '\t')
colnames(data) <- substr(colnames(data),1,nchar(colnames(data))-5)
counts <- data[,-1]
counts_DSS<- subset(counts[,21:25])
counts_LbGP <- subset(counts[,26:30])

DSSLbGP <- cbind(counts_DSS,counts_LbGP)

group <- c(rep("DSS",5),rep("LbGP",5))
y <- DGEList(counts=DSSLbGP, group=group)

keep <- filterByExpr(y)
y <- y[keep, , keep.lib.sizes=FALSE]

y <- calcNormFactors(y)

y <- estimateDisp(y)

et <- exactTest(y)

et <- topTags(et, n=100000)

et <- as.data.frame(et)

et <- cbind(rownames(et),et)

colnames(et) <- c("KO", "log2FoldChange", "log2CPM", "PValue", "FDR")

etSig <- et[which(et$PValue < 0.05 & abs(et$log2FoldChange) > 1),]

etSig[which(etSig$log2FoldChange > 0), "level"] <- "LbGP"
etSig[which(etSig$log2FoldChange < 0), "level"] <- "DSS"
head(etSig)
library(ggplot2)
et$level=as.factor(ifelse(et$PValue< 0.05 & abs(et$log2FoldChange)>1, 
                          ifelse(et$log2FoldChange> 1,'LbGP','DSS'),'No'))

descri <- data.frame(KO=rownames(data),descri=data$descri)
merge_et <- merge(et,descri,by="KO",sort=F)
merge_et$text<- NA
merge_et$text[1:20] <- merge_et$descri[1:20]
p <- ggplot(data=merge_et, aes(x=log2FoldChange, y=-log10(PValue), color=level)) +
  geom_point() +
  ggtitle('Volcano Plot of DSS vs LbGP') +
  scale_color_manual(values=c("blue", "red","grey")) +
  geom_vline(xintercept=c(-1,1), lty=2, col="black") +      
  geom_hline(yintercept=-log10(0.05), lty=2, col="black")  
LbGP_count <- sum(etSig$level=='LbGP')
DSS_count <- sum(etSig$level=='DSS')
write.csv(merge_et,file='./volcano/volcano.csv',row.names = F)
p <- p + theme_bw()
p <- p + geom_text(aes(label = text), size = 2,color = "black")
p
