#BS_call
bcftools filter -e "QUAL<30" SRR6006943.variants.vcf > SRR6006943.variants.filtered.vcf

#BisSNP
bcftools filter -e "QUAL==inf || QUAL<275" SRR6006943_snp.fixed.vcf > SRR6006943_snp.fixed.filtered.vcf

