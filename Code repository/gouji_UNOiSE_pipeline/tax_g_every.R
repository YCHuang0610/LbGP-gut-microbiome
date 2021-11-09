#plot top10
library(reshape2)
library(ggplot2) 
genus <- read.table('result/tax/sum_g.txt', sep='\t', header = T, row.names = 1)
genus_top10 <- subset(genus[1:10,])
genus_top10 <- rbind(genus_top10, others=apply(genus_top10, 2, function(x){100-sum(x)}))
genus_top10$genus <- row.names(genus_top10)

genus_top10$genus <- factor(genus_top10$genus, levels=rev(genus_top10$genus))

genus_top10 <- melt(genus_top10, id = 'genus')

design <- read.table("metadata.txt", header=T, row.names=1, sep="\t") 
group <- data.frame(variable=rownames(design), group=design$Group)
genus_top10 <- merge(genus_top10, group, by = 'variable')
#plot
p <- ggplot(genus_top10, aes(x=variable, y=value, fill = genus)) +
  geom_col(position = 'stack') +
  facet_wrap(~group, scales = 'free_x') +  #facet
  ylab('Relative Abundance(%)') +
  xlab('Sample') +
  scale_fill_manual(values =  rev(c('#8DD3C7', '#FFFFB3', '#BEBADA', '#FB8072', '#80B1D3', '#FDB462', '#B3DE69', '#FCCDE5', '#BC80BD', '#CCEBC5', 'gray')))
p	+ theme(axis.title.x=element_blank(),
           axis.text.x=element_blank(),
           axis.ticks.x=element_blank())
