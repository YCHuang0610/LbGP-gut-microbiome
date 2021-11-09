
library(reshape2)
library(ggplot2) 
phylum <- read.table('result/tax/sum_p.txt', sep='\t', header = T, row.names = 1)
phylum_top10 <- subset(phylum[1:10,])
phylum_top10 <- rbind(phylum_top10, others=apply(phylum_top10, 2, function(x){100-sum(x)}))
phylum_top10$Phylum <- row.names(phylum_top10)

phylum_top10$Phylum <- factor(phylum_top10$Phylum, levels=rev(phylum_top10$Phylum))

phylum_top10 <- melt(phylum_top10, id = 'Phylum')

design <- read.table("metadata.txt", header=T, row.names=1, sep="\t") 
group <- data.frame(variable=rownames(design), group=design$Group)
phylum_top10 <- merge(phylum_top10, group, by = 'variable')
#plot
p <- ggplot(phylum_top10, aes(x=variable, y=value, fill = Phylum)) +
  geom_col(position = 'stack') +
  facet_wrap(~group, scales = 'free_x') +  #facet
  ylab('Relative Abundance(%)') +
  xlab('Sample') +
  scale_fill_manual(values =  rev(c('#8DD3C7', '#FFFFB3', '#BEBADA', '#FB8072', '#80B1D3', '#FDB462', '#B3DE69', '#FCCDE5', '#BC80BD', '#CCEBC5', 'gray')))
p	+  theme(axis.title.x=element_blank(),
           axis.text.x=element_blank(),
           axis.ticks.x=element_blank())
