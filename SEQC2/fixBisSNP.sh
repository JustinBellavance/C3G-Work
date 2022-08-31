#combine cpg and snps
grep -v "^#" SRR6006943_cpg.vcf > SRR6006943.noHeader.cpg.vcf
cat SRR6006943.snp.vcf SRR6006943.noHeader.cpg.vcf > SRR6006943.vcf

#remove bad lines and whitespaces.
awk -F "\t" '{if(NF < 11){print $0}; }' SRR6006942.vcf > SRR6006942.fixed.vcf
sed -i '/^$/d' SRR6006942.fixed.vcf

#sort if necessary (necessary for hap.py)
bcftools sort -O v -o SRR6006942.fixed.sorted.vcf SRR6006942.fixed.vcf

#need to remove infinity as qual value.
awk -F "\t" 'BEGIN {OFS="\t"}; {if(NF==10){if ($6=="inf"){$6=50000}; }; print $0; }' SRR6006943_snp.fixed.filtered.sorted.vcf > out.vcf
