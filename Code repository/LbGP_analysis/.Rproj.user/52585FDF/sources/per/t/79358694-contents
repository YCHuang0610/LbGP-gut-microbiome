library('pheatmap')
df <- read.table('beta/bray-curtis.xls', sep='\t', header = T, row.names = 1)

annot_data <- data.frame(row.names=colnames(df), Group=design$Group, Week=design$time)

ann_colors = list(
  Week = c(W1="black", W2="gray",W3="white"),
  Group = c(W1_CLT="#f8766d",	
            W1_DSS="#00ba38",
            W1_LbGP="#619cff",
            W2_CLT="#f9928a",
            W2_DSS="#00cc3d",
            W2_LbGP="#85b1ff",
            W3_CLT="#faa49e",
            W3_DSS="#00e043",
            W3_LbGP="#99beff"))

pheatmap(df,annotation_col = annot_data, annotation_row = annot_data,annotation_colors = ann_colors)

