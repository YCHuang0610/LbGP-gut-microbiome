
library(reshape2)
library(ggplot2) 
genus_top10 <- read.table('tax/genus.xls', sep='\t', header = T, row.names = 1)
genus_top10$genus <- row.names(genus_top10)

genus_top10$genus <- factor(genus_top10$genus, levels=rev(genus_top10$genus))

genus_top10 <- genus_top10[,c(1:9,15)]
genus_top10 <- melt(genus_top10, id = 'genus')

design <- read.table("metadata.txt", header=T, row.names=1, sep="\t") 
group <- unique(data.frame(variable=design$Group, group=design$time))
genus_top10 <- merge(genus_top10, group, by = 'variable')

p <- ggplot(genus_top10, aes(x=variable, y=value, fill = genus)) +
  geom_col(position = 'stack') +
  facet_wrap(~group, scales = 'free_x') +  #分面
  ylab('Relative Abundance(%)') +
  xlab('Group') +
  scale_fill_manual(values =  rev(c('#F7A58F','#8DD3C7', '#FFFFB3', '#BEBADA', '#F07167', '#80B1D3', '#FDB462', '#B3DE69', '#FCCDE5', '#BC80BD', '#CCEBC5', 'gray')))
p	+ theme_bw()
