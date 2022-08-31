#!/usr/bin/env python3

'''
Title: eval_tp_origin.py
Date: 20180525
Author: Adam Nunn
Description:
	xxxx

List of functions:
	xxxx

Procedure:
	1.
	2.
	3.
	4.
	5.

Usage:
	./eval_tp_origin.py [-t, --threads] int [bamfile]
eg. ./eval_tp_origin.py -t 1 simulated.bismark.bam
'''

import multiprocessing as mp
from collections import Counter
import argparse
import pysam


####### define main
def main(BAM,THREADS,MAPQ):

	# Declare vars
	total = 0 # total number of positives / alignments
	count = 0 # total number of true positive alignments

	template = dict()
	for i in range(0,MAPQ+1): template[i] = 0

	total = Counter(template.copy())		
	count = Counter(template.copy())

	# 1) build threads pool
	pool = mp.Pool(int(THREADS))
	jobs = list()

	# 2) Open initial BAM file instance to read references
	with pysam.AlignmentFile(BAM, "rb") as original:

		for ref in original.get_index_statistics():

			# 3) Fire off workers to process reads for each scaffold 'ref' from 'BAM'
			if ref.mapped > 0:
				job = pool.apply_async(worker, (BAM, ref.contig, template))
				jobs.append(job)

	# 4) iterate through job results
	for job in jobs:
		job = job.get()
		count = count + Counter(job[0])
		total = total + Counter(job[1])

	# 5) print final counts
	for i in sorted(template): print("{}\t{}\t{}".format(i, count[i], total[i]))
	#print("{}\t{}".format("total",total))

	# close the pool
	pool.close()
	pool.join()



####### Function for READING the input reads
def worker(BAM,ref,template):

	'''
	BAM = path to input bam file eg. "/path/to/input.bam"
	ref = current scaffold or chromosome reference eg. "Chr1"
	mapq = empty dictionary object with range of mapq scores
	'''

	total = 0 # total number of positives / alignments
	count = 0 # total number of true positive alignments

	total = template.copy()
	count = template.copy()

	# 1) Open pysam.AlignmentFile objects for reading and writing
	with pysam.AlignmentFile(BAM, "rb") as original:

		# 2) Iterate through input SAM/BAM file
		for line in original.fetch(ref):

			# skip uninteresting alignments
			if (line.is_unmapped) or (line.is_secondary) or (line.is_qcfail): continue
			if not (":" in line.query_name): continue

			map_qual = line.mapping_quality
			for i in sorted(total):
				if i <= map_qual: total[i] += 1
				else: break
			#total += 1

			# 3) get the origin info from query name
			read = line.query_name.split(":") # eg. ['122321_AZNP01000001.1','12124-12234']
			read_id = read[0].split('_', 1)[-1] # eg. AZNP01000001.1
			read_id = read_id[:-2] # eg. AZNP01000001
			read_lpos = int(read[1].split("-")[0]) # eg. 12124
			read_rpos = int(read[1].split("-")[1]) # eg. 12234
			ref_id = line.reference_name # eg. AZNP01000001.1
			ref_id = ref_id[:-2] # eg. AZNP01000001
			ref_lpos = line.reference_start+1 # eg. 12124
			ref_rpos = line.reference_end # eg. 12234
			#map_qual = line.mapping_quality

			# 4) identify possible soft-clipping and adjust accordingly
			first_cigar = line.cigartuples[0]
			if first_cigar[0] == 4:
				change_pos_by = first_cigar[1]
				read_lpos = read_lpos - change_pos_by
				#read_rpos = read_rpos - change_pos_by

			# 5) allow for small deviations of +/- 4 from read_lpos or read_rpos
			range_lpos = list(range(read_lpos-4,read_lpos+5))
			range_rpos = list(range(read_rpos-4,read_rpos+5))

			# 6) print output for both reads
			if (read_id == ref_id) and ((ref_rpos in range_rpos) or (ref_lpos in range_lpos)):

				for i in sorted(count):
					if i <= map_qual: count[i] += 1
					else: break
				#count += 1
				#print("{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}".format(str(line.query_name),str(line.flag),read[1],str(read_lpos),str(ref_lpos),str(read_rpos),str(ref_rpos),line.cigarstring,ref_id))
			else:
				continue
				#print("{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}".format(str(line.query_name),str(line.flag),read[1],str(read_lpos),str(ref_lpos),str(read_rpos),str(ref_rpos),line.cigarstring,ref_id))

	# return the counts
	return count, total




#############
## RUN SCRIPT

# define argparse
usage = ''' This program takes an input BAM file and compares each alignments to the read
	origin according to the metadata contained within the read names. '''

parser = argparse.ArgumentParser(description=usage)

parser.add_argument('infile', metavar = 'in.bam', help='[REQUIRED] The path to the original SAM/BAM file')
parser.add_argument('-t','--threads', metavar='', help='[OPTIONAL] Number of threads for reading [default: 1]', type=int, default=1)
parser.add_argument('-m','--mapq', metavar='', help='[OPTIONAL] MAPQ threshold for evaluation [default: 20]', type=int, default=20)

args = parser.parse_args()

# call main()
if __name__ == '__main__': main(args.infile,args.threads,args.mapq)

## END OF SCRIPT
################
