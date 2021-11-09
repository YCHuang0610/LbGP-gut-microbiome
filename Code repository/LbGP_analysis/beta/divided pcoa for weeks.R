library(ape) # 用于pcoa分析
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

W1 <- data[data$week=='W1',]
W2 <- data[data$week=='W2',]
W3 <- data[data$week=='W3',]


  pw1 <- ggplot(W3, aes(x=x, y=y, color=group)) +
  geom_point(size=3) + 
        labs(x=paste("PCoA 1 (", format(100*eig[1]/sum(eig), digits=4), "%)",sep=""),
        y=paste("PCoA 2 (", format(100*eig[2]/sum(eig), digits=4), "%)",sep=""))
        pw1 <- pw1 +stat_ellipse(type ="t",aes(fill=group),geom = "polygon",
                         alpha=.2,level =0.95 ) +theme_bw()+ ylim(-1,1)+xlim(-1,1)
        pw1

        
