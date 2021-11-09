#!/bin/bash
wk=~/gouji_UNOiSE_pipeline
#databasedir
db=~/database/amplicon
#softwaredir
sf=~/biosoft/amplicon
#enteringworkingdir
cd $wk

sed -i 's/\r//' metadata.txt
tail -n+2 metadata.txt | cut -f 1 > SampleID
tail -n+2 metadata.txt | cut -f 3 > fileID
paste fileID SampleID > fileID_SampleID
#GDDOM21080070_order_1_16S_M21081289_1.fq.gz
mkdir -p temp result

cat fileID_SampleID|while read id;do
  arr=($id)
  fileID=${arr[0]}
  SampleID=${arr[1]}
  ${sf}/vsearch --fastq_mergepairs seq/GDDOM21080070_order_1_16S_${fileID}_1.fq.gz \
  --reverse seq/GDDOM21080070_order_1_16S_${fileID}_2.fq.gz \
  --fastqout temp/${SampleID}.merged.fq \
  --relabel ${SampleID}.
done

cat temp/*.merged.fq > temp/all.fq
ls -lsh temp/all.fq
head -n 6 temp/all.fq

${sf}/vsearch --fastx_filter temp/all.fq \
  --fastq_stripleft 0 --fastq_stripright 0 \
  --fastq_maxee_rate 0.01 \
  --fastaout temp/filtered.fa

${sf}/vsearch --derep_fulllength temp/filtered.fa \
  --output temp/uniques.fa \
  --relabel Uni --minuniquesize 10 --sizeout

${sf}/usearch -unoise3 temp/uniques.fa \
  -zotus temp/zotus.fa
sed 's/Zotu/ASV_/g' temp/zotus.fa > temp/otus.fa

mkdir -p result/raw
${sf}/vsearch --uchime_ref temp/otus.fa \
    -db ${db}/usearch/silva_16s_v123.fa.gz \
    --nonchimeras result/raw/otus.fa
    --threads 20

${sf}/usearch -otutab temp/filtered.fa -otus result/raw/otus.fa \
  -otutabout result/raw/otutab.txt -threads 20

${sf}/vsearch --sintax result/raw/otus.fa --db ${db}/usearch/silva_16s_v123.fa.gz \
  --tabbedout result/raw/otus.sintax --sintax_cutoff 0.6\
  --threads 20

cp result/raw/otu* result/
${sf}/usearch -otutab_stats result/otutab.txt \
  -output result/otutab.stat
cat result/otutab_rare.stat

#alpha
${sf}/usearch -alpha_div result/otutab_rare.txt \
      -output result/alpha/alpha.txt
#beta
${sf}/usearch -cluster_agg result/otus.fa \
    -treeout result/otus.tree
${sf}/usearch -beta_div result/otutab_rare.txt \
    -tree result/otus.tree \
    -filename_prefix result/beta/

#tax
mkdir -p result/tax
for i in p c o f g;do
${sf}/usearch -sintax_summary result/otus.sintax \
      -otutabin result/otutab_rare.txt \
      -rank ${i} \
      -output result/tax/sum_${i}.txt
    done

sed -i 's/(//g;s/)//g;s/\"//g;s/\#//g;s/\/Chloroplast//g' result/tax/sum_*.txt

echo 'done'
