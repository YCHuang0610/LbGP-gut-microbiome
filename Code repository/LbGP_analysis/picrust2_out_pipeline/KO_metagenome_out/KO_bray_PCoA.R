library(FactoMineR)
library(factoextra)
design <- read.table("metadata.txt", header=T, row.names=1, sep="\t") 
data <- read.table("picrust2_out_pipeline/KO_metagenome_out/pred_metagenome_unstrat.tsv",header = T,row.names = 1,sep = '\t')
colnames(data) <- substr(colnames(data),1,nchar(colnames(data))-5)

data <- as.data.frame(t(data))
data <- data[16:30,]
library(ape)
library(vegan)
bray <- vegdist(data,method="bray")
df <- as.data.frame(as.matrix(bray))
annot_data <- data.frame(row.names=rownames(design), Group=design$Group, Week=design$time)
annot_data <- annot_data[16:30,]
res <- pcoa(df)
data <- res$vectors[,1:2]
data <- data.frame(data)
data <- cbind(data, annot_data)
colnames(data) <- c('x','y','group','week')
eig <- as.numeric(res$value[,1])

colormap = c("#f8766d",	
             "#00ba38",
             "#619cff",
             "#f9928a",
             "#00cc3d",
             "#85b1ff",
             "#faa49e",
             "#00e043",
             "#99beff")
p <- ggplot(data, aes(x=x, y=y, color=group)) +
  geom_point(size=3) + 
  labs(x=paste("PCoA 1 (", format(100*eig[1]/sum(eig), digits=4), "%)",sep=""),
       y=paste("PCoA 2 (", format(100*eig[2]/sum(eig), digits=4), "%)",sep=""))
p <- p +stat_ellipse(type ="t", aes(linetype = week)) +theme_bw()
p + scale_color_manual(values = colormap)

