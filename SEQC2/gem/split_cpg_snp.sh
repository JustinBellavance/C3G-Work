#!/bin/bash

#seperate bs_call vcf
module load mugqic/bcftools
bcftools view SRR6006942_variants_pass.vcf.gz | grep "#"  > SRR6006942.cpg.vcf
cp SRR6006942.cpg.vcf SRR6006942.snp.vcf
bcftools view SRR6006942_variants_pass.vcf.gz | grep -v "#" | awk -F "[\t:]" '{ if ($31 != "N" && $32 !="N") print $0;}' >> SRR6006942.cpg.vcf
bcftools view SRR6006942_variants_pass.vcf.gz | grep -v "#" | awk -F "[\t:]" '{ if ($31 == "N" || $32 == "N") print $0;}' >> SRR6006942.snp.vcf
gzip SRR6006942.cpg.vcf SRR6006942.snp.vcf
