library(ape) # pcoa package
library(ggplot2) 
df <- read.table('beta//bray-curtis.xls', sep='\t', header = T, row.names = 1)
design <- read.table("metadata.txt", header=T, row.names=1, sep="\t") 
annot_data <- data.frame(row.names=colnames(df), group=design$Group,week=design$time)
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
p <- ggplot(data, aes(x=x, y=y, color=group, shape=week)) +
  geom_point(size=3) + 
  labs(x=paste("PCoA 1 (", format(100*eig[1]/sum(eig), digits=4), "%)",sep=""),
       y=paste("PCoA 2 (", format(100*eig[2]/sum(eig), digits=4), "%)",sep=""))
p <- p +stat_ellipse(type ="t", aes(linetype = week)) +theme_bw()
p + scale_color_manual(values = colormap)
