library( "edgeR" )
counts <- read.csv("OTU.xls",sep="\t",header=TRUE,row.names = 1)
# compare W2_DSS and W2_LbGP
counts_DSS<- subset(counts[,22:26])
counts_LbGP <- subset(counts[,27:31])
DSSLbGP <- cbind(counts_DSS,counts_LbGP)
# group design
group <- c(rep("DSS",5),rep("LbGP",5))
# set up DGEList
y <- DGEList(counts=DSSLbGP, group=group)
# filtered
# default min.count = 10, min.total.count = 15
keep <- filterByExpr(y)
y <- y[keep, , keep.lib.sizes=FALSE]
# calculate normalize factors
y <- calcNormFactors(y)
y <- estimateDisp(y)
et <- exactTest(y)
# output otus
et <- topTags(et, n=100000)
# change to dataframe
et <- as.data.frame(et)
et <- cbind(rownames(et),et)
# set colnames
colnames(et) <- c("OTU", "log2FoldChange", "log2CPM", "PValue", "FDR")

############ differ OTU filtration
# set threshold: pvalue under 0.05 foldchange over 2
etSig <- et[which(et$PValue < 0.05 & abs(et$log2FoldChange) > 1),]
#set group enrichment
etSig[which(etSig$log2FoldChange > 0), "level"] <- "LbGP"
etSig[which(etSig$log2FoldChange < 0), "level"] <- "DSS"
head(etSig)
tax <- counts[,92:98]
tax$OTU <- rownames(tax)
#plot
library(ggplot2)
et$level=as.factor(ifelse(et$PValue< 0.05 & abs(et$log2FoldChange)>1, 
                          ifelse(et$log2FoldChange> 1,'LbGP','DSS'),'No'))

merge_et <- merge(et,tax,by="OTU",sort=F)
merge_et$text[1:10] <- merge_et$Genus[1:10]
merge_et$text[11:120] <- NA

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
p <- p + geom_text(aes(label = text), size = 3,color = "black")
p
ggsave(p,filename = "volcano/volcano_DSS_LbGP.pdf",width = 10,height = 8)
