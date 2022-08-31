#!/usr/bin/env python

'''
Title: eval_tp_razers3.py
Date: 20180525
Author: Adam Nunn
Description:
  	Iterate through Razer S3 bam and test bam files

List of functions:
	xxxx

Procedure:
	1.
	2.
	3.
	4.
	5.

Usage:
	./eval_tp_razers3.py [-t, --threads] <int> [-i, --ignores] <str> [BAM] [TEST]
eg. ./eval_tp_razers3.py -t 1 -i multis.txt razers3.bam test.bam
'''

import multiprocessing as mp
from collections import Counter
import argparse
import pysam


####### define main
def main(BAM,TEST,TOOL,IGNORES=None,THREADS=1,ADJ=5,MAPQ=20):

	# Declare vars
	total = 0
	#rtotal = 0
	#count = 0

	template = dict()
	for i in range(0,MAPQ+1): template[i] = 0

	tp_count = Counter(template.copy())
	p_count = Counter(template.copy())

	# 1) determine reads to ignore (eg. multis)
	if IGNORES: ignores = set(open(IGNORES).read().split())
	else: ignores = set()

	# 2) build threads pool
	pool = mp.Pool(int(THREADS))
	jobs = list()
	counts = list()

	# 3) Open initial BAM file instance to read references
	with pysam.AlignmentFile(BAM, "rb") as razers3, pysam.AlignmentFile(TEST, "rb") as test:

		trefs = test.references
		for ref in razers3.get_index_statistics():

			# 3) Fire off workers to process reads for each scaffold 'ref' from 'BAM'
			if ref.mapped > 0:

				if TOOL == "bsseeker2": tref = ref.contig.replace(".","_")
				else: tref = ref.contig
				
				job = pool.apply_async(worker, (BAM, TEST, TOOL, ADJ, ignores, ref.contig, tref, bool(tref in trefs), template))
				jobs.append(job)
		
		for tref in test.get_index_statistics():

			# 3) Fire off workers to process reads for each scaffold 'ref' from 'BAM'
			if tref.mapped > 0:
				job = pool.apply_async(counting, (TEST, TOOL, ignores, tref.contig, template))
				counts.append(job)

	# 4) iterate through job results
	for job in jobs:
		job = job.get()
		tp_count = tp_count + Counter(job[0])
		total += job[1]
	
	for job in counts:
		job = job.get()
		p_count = p_count + Counter(job)

	# 5) print final counts
	for i in sorted(template):
		print("{}\t{}\t{}".format(i,tp_count[i],p_count[i]))
	print(total)

	# close the pool
	pool.close()
	pool.join()



####### Function for READING the input reads
def worker(BAM,TEST,TOOL,ADJ,ignores,ref,tref,boolean,template):

	'''
	BAM = path to input Razer S3 bam file eg. "/path/to/razers3.bam"
	TEST = path to input test bam file eg. "/path/to/test.bam"
	TOOL = string representing the mapping tool eg. "bsseeker2"
	ADJ = integer to specify the error adjustment at position start/end
	ignores = a set containing read names eg. '122321_AZNP01000001.1:12124-12234'
	ref = current scaffold or chromosome reference eg. "Chr1"
	tref = current scaffold or chromosome reference eg. "Chr1"
	boolean = boolean test that tref exists eg. True or False
	template = dictionary object with mapq scores
	'''

	total = 0 # total number of alignments in razers3
	count = template.copy()

	# Parse alignments in Razer S3 bam file and compare them to the test bam file
	with pysam.AlignmentFile(BAM, "rb") as razers3, pysam.AlignmentFile(TEST, "rb") as test:

		# iterate through unique Razer S3 alignments
		for alignment in razers3.fetch(ref):
			if (alignment.is_unmapped == True) or (alignment.is_secondary) or (alignment.is_qcfail == True): continue

			qnam = alignment.query_name # eg. '122321_AZNP01000001.1:12124-12234'

			if not (":" in qnam): continue
			if qnam in ignores: continue

			total += 1

			Found = False
			# compare alignment region to test file to determine TP count
			if boolean:

				lpos = alignment.reference_start+1 # eg. 12124
				rpos = alignment.reference_end # eg. 12234

				if lpos-ADJ+1 < 0: ladj = 0
				else: ladj = lpos-ADJ+1

				for read in test.fetch(tref, ladj, rpos+ADJ):

					if (read.is_unmapped == True) or (read.is_secondary) or (read.is_qcfail == True): continue
					if (read.query_name == qnam) and ((alignment.is_read1 and read.is_read1) or (alignment.is_read2 and read.is_read2)):

						start = read.reference_start+1
						cigar = read.cigartuples[0]
						if cigar[0] == 4 and (start - cigar[1]) < lpos: continue
						else:
							map_qual = read.mapping_quality
							Found = True
							break

					else: continue

			# add the TP to the count
			if Found:
 
				for i in sorted(count):
					if i <= map_qual: count[i] += 1
					else: break
				#count += 1

		# return the counts
		return count, total	


####### Function for READING the input reads
def counting(TEST,TOOL,ignores,tref,template):

	'''
	TEST = path to input test bam file eg. "/path/to/test.bam"
	tref = current scaffold or chromosome reference eg. "Chr1"
	'''

	count = template.copy()

	# Parse alignments in Razer S3 bam file and compare them to the test bam file
	with pysam.AlignmentFile(TEST, "rb") as test:

		# iterate through unique Razer S3 alignments
		for alignment in test.fetch(tref):
			if (alignment.is_unmapped == True) or (alignment.is_secondary) or (alignment.is_qcfail == True): continue

			qnam = alignment.query_name # eg. '122321_AZNP01000001.1:12124-12234'

			if not (":" in qnam): continue
			if qnam in ignores: continue

			map_qual = alignment.mapping_quality
			for i in sorted(count):
				if i <= map_qual: count[i] += 1
				else: break
			#total += 1

		# return the counts
		return count


#############
## RUN SCRIPT

# define argparse
usage = ''' This program takes an input BAM file and compares each alignments to the read
	origin according to the metadata contained within the read names. '''

parser = argparse.ArgumentParser(description=usage)

parser.add_argument('razers3', metavar = 'razers3.bam', help='[REQUIRED] The path to the original SAM/BAM file')
parser.add_argument('test', metavar = 'test.bam', help='[REQUIRED] The path to the original SAM/BAM file')
parser.add_argument('tool', metavar = '<tool>', help='[REQUIRED] String representing the tool name')
parser.add_argument('-i','--ignores', metavar='', help='[OPTIONAL] Path to a .txt file containing reads to ignore', type=str, default=None)
parser.add_argument('-t','--threads', metavar='', help='[OPTIONAL] Number of threads for reading [default: 1]', type=int, default=1)
parser.add_argument('-a','--adjustment', metavar='', help='[OPTIONAL] Error adjustment at position start/end [default: 5]', type=int, default=5)
parser.add_argument('-m','--mapq', metavar='', help='[OPTIONAL] MAPQ threshold for evaluation [default: 20]', type=int, default=20)

args = parser.parse_args()

# call main()
if __name__ == '__main__': main(args.razers3,args.test,args.tool,args.ignores,args.threads,args.adjustment,args.mapq)

## END OF SCRIPT
################
