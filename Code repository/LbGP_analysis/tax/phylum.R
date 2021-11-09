
library(reshape2)
library(ggplot2) 
phylum_top10 <- read.table('tax/phylum.xls', sep='\t', header = T, row.names = 1)
phylum_top10$Phylum <- row.names(phylum_top10)

phylum_top10$Phylum <- factor(phylum_top10$Phylum, levels=rev(phylum_top10$Phylum))

phylum_top10 <- phylum_top10[,-10]
phylum_top10 <- melt(phylum_top10, id = 'Phylum')

design <- read.table("metadata.txt", header=T, row.names=1, sep="\t") 
group <- unique(data.frame(variable=design$Group, group=design$time))
phylum_top10 <- merge(phylum_top10, group, by = 'variable')

p <- ggplot(phylum_top10, aes(x=variable, y=value, fill = Phylum)) +
  geom_col(position = 'stack') +
  facet_wrap(~group, scales = 'free_x') +  #分面
  ylab('Relative Abundance(%)') +
  xlab('Group') +
  scale_fill_manual(values =  rev(c('#F7A58F','#8DD3C7', '#FFFFB3', '#BEBADA', '#F07167', '#80B1D3', '#FDB462', '#B3DE69', '#FCCDE5', '#BC80BD', '#CCEBC5', 'gray')))
p	+theme_bw()

