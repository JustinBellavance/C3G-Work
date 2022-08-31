#!/usr/bin/python3

'''
Title: bisulfite.py
Date: 20180522
Author: Adam Nunn
Description:
  Takes input *.fastq files and converts a user-defined proportion of the bases
  from C to T (or G to A, for read_2) in order to simulate reads obtained
  through bisulfite sequencing. Adapted from Sherman read simulator.

List of functions:
  int()
  open()
  .rstrip()
  list()
  range()
  len()
  random.randint()
  .join()

Procedure:
  1. iterate through lines in input fastq file
  2. convert sequence lines only
  3. iterate through bases in sequence line for converting C to T
  4. generate random number and compare with conversion conversion_rate
  5. print converted sequence line to stdout
  6. print all other lines unchanged to stdout

Usage:
    ./bisulfite.py [options] unconverted.fastq.gz > converted.fastq
eg. ./bisulfite.py -b methylome.bedGraph -f genome.fasta -r 1 -m 2 -k 10 -c 99 read1.fastq.gz
'''

import gzip, sys, argparse, random

# main function
def main(FASTQ,CR=99,PE=1,M=2,K=10,REFERENCE=None,BED=None):

	# check file extension
	if FASTQ.split(".")[-1] == "gz": reads = gzip.open(FASTQ, "rt")
	else: reads = open(FASTQ, "r")

	# generate position depth dictionary
	if REFERENCE and BED:
		genome = build_index(REFERENCE)
		methylome = generate_methylome(BED)
	elif (BED and not REFERENCE) or (REFERENCE and not BED):
		sys.exit('Require both reference genome and methylome together')

	line_count = 0
	total_errors = 0
	reads_with_errors = 0
	# 1) iterate through lines in input *.fastq file 'reads'
	for line in reads:

		line = line.rstrip()
		line_count += 1

		# get ref ID to cross-reference with genome/methylome
		if (line_count % 4 == 1) and BED:

			ref = "_".join(line.split("_")[1:])
			ref = ":".join(ref.split(":")[:-1])
			pos = line.split(":")[-1]
			pos = pos.split("-")
			print(line, file=sys.stdout)

		# 2) convert sequence lines only
		elif line_count % 4 == 2:

			if BED:
				result = check_strand(genome[ref],pos,line,M,K,PE)
				strand, errors = result[0], result[1]
				if errors > M: print("WARN: {} errors relative to strand {} in read {}".format(errors,strand,ref),file=sys.stderr)

			bases = list(line)
			warn_count = 0

			# 3) iterate through bases in sequence line for converting C to T
			for base in range(len(bases)):

				if ((PE == 1) and (bases[base] == 'C')) or ((PE == 2) and (bases[base] == 'G')):

					# modify conversion rate based on provided methylome
					if BED:
						result = lookup_methylome(methylome,ref,pos,base,strand,PE)
						conversion_rate = result[0] * (CR/100)
						#print(result,file=sys.stderr)
						if result[1] == True:
							#print("^ that was: {}:{}-{}".format(ref,pos[0],pos[1]),file=sys.stderr)
							warn_count += 1

					else: conversion_rate = CR
					
					bases[base] = bisulfite_convert(bases[base], PE, conversion_rate)

			# print converted sequence line to stdout
			line = "".join(bases)
			print(line, file=sys.stdout)
			if warn_count > M: print("WARN: read {}:{}-{} ({}) had {} failed lookups".format(ref,pos[0],pos[1],strand,warn_count),file=sys.stderr)
			if warn_count > 0: reads_with_errors += 1
			total_errors += warn_count

		# print all other lines unchanged to stdout
		else: print(line, file=sys.stdout)
	
	print("\nTotal reads: {}\nReads with errors: {}\nTotal errors: {}\n----------".format(line_count/4,reads_with_errors,total_errors),file=sys.stderr)
	print("Done!",file=sys.stderr)
	# close reads file object
	reads.close()


# build dictionary object for lookup of provided reference genome
def build_index(reference):

	genome = dict()
	with open(reference, "r") as ref:
		First = True

		for line in ref:
			line = line.rstrip()
			if line.startswith(">") and First == True:
				ID = line.split(" ")[0][1:]
				First = False
				seq = ""
			elif line.startswith(">") and First == False:
				genome[ID] = seq
				ID = line.split(" ")[0][1:]
				seq = ""
			else: seq += line

		genome[ID] = seq

	print("finished building index...",file=sys.stderr)
	return genome


# build dictionary object for lookup of provided methylome
def generate_methylome(bedGraph):

	methylome = dict()
	with open(bedGraph, "r") as bed:

		# iterate bedGraph
		for line in bed:
			line = line.rstrip()
			line = line.split("\t")

			# calculate rate
			Chr = line[0]
			Pos = int(line[1])
			mcov = int(line[3])
			ucov = int(line[4])
			tcov = mcov + ucov
			if tcov == 0: rate = 100
			else: rate = (ucov/tcov)*100

			# add to dict
			if Chr in methylome: methylome[Chr][Pos] = rate
			else: methylome[Chr] = {Pos: rate}
	
	print("finished building methylome...", file=sys.stderr)
	# return dict
	return methylome


# identify strand by recursive kmer / seed match
def check_strand(contig,pos,line,m,k,pe):

	# off-by-one modifier for kmer calc
	if pe == 1: n = 1
	else: n = 0

	tab = str.maketrans("ACGT","TGCA")
	seed = line[0:k].upper()

	# check beginning of subsequence
	#kmer = contig[int(pos[0])-1:int(pos[0])+k-1].upper() # pe == 1,  n = 1	
	kmer = contig[int(pos[0])-n:int(pos[0])+k-n].upper() # pe == 2,  n = 0

	errors = sum(c1!=c2 for c1,c2 in zip(kmer,seed))
	#print("{}\n{}".format(kmer,seed),file=sys.stderr)

	# check sequence match in forward orientation
	if errors <= m:
		# probably this orientation, but check opposite to be sure
		#kmer = contig[int(pos[1])-k:int(pos[1])].upper()
		kmer = contig[int(pos[1])-k-(1-n):int(pos[1])-(1-n)].upper()
		kmer = kmer.translate(tab)[::-1]

		# checking opposite orientation
		if sum(c1!=c2 for c1,c2 in zip(kmer,seed)) <= m:
			# repeat with k+1 because both fwd and rev orientations look similar
			result = check_strand(contig,pos,line,m,k+1,pe)
			strand, errors = result[0], result[1]
		else:
			strand = "+"

	else:
		# assume the opposite orientation, otherwise we're screwed...
		strand = "-"

		# if this is also full of mismatches then skip read + warn
		#kmer = contig[int(pos[1])-k:int(pos[1])].upper() # pe == 1,  n = 1
		kmer = contig[int(pos[1])-k-(1-n):int(pos[1])-(1-n)].upper() # pe == 2,  n = 0

		#kmer = contig[int(pos[1])-k-1:int(pos[1])-1].upper() # pe == 2         n = 0
		kmer = kmer.translate(tab)[::-1]
		#print("{}\n{}".format(kmer,seed),file=sys.stderr)
		errors = sum(c1!=c2 for c1,c2 in zip(kmer,seed))
	
	return strand, errors
	

# retrieve the methylation rate from provided methylome
def lookup_methylome(methylome,ref,pos,base,strand,pe):

	warn = False
	methylome = methylome[ref] # eg. {2124: 0.9, 2125: 0.8, 2250: 0.3, 2251: 0.2, ...}

	# off-by-one modifier for read 2
	if pe != 1: base += 1

	if strand == "+": current = int(pos[0]) + base
	else: current = int(pos[1]) - base	

	try: rate = methylome[current]
	except:
		#print("WARN: {}:{} ({}) not recorded in bedGraph (likely a point mutation)".format(ref,current,strand),file=sys.stderr)
		warn = True
		rate = 100

	return rate, warn


# conversion function once the file object is opened
def bisulfite_convert(base,pe,conversion_rate):

	random_number = int(random.randint(0,10000)+1)/100
	if (random_number <= conversion_rate) and pe == 1: return 'T'
	elif (random_number <= conversion_rate) and pe == 2: return 'A'
	else: return base


# define argparse
usage = ''' Take input fastq files [optional gzip format] and apply bisulfite treatment
	based on a provided methylome in bedGraph format and/or a blanket conversion success
	rate based on input parameter -c'''

parser = argparse.ArgumentParser(description=usage)

parser.add_argument('fastq', metavar = '<fastq>', help='[REQUIRED] Path to the input reads in fastq / gzip format')
parser.add_argument('-b','--bed', metavar='', help='Path to methylome profile in bedGraph format', default=None)
parser.add_argument('-f','--fasta', metavar='', help='Path to reference genome in fasta format (needed if methylome provided)', default=None)
parser.add_argument('-r','--read', metavar='', help='Read orientation for paired-end sequencing [default: 1]', type=int, default=1)
parser.add_argument('-k','--kmer', metavar='', help='Needed for strand identification', type=int, default=10)
parser.add_argument('-m','--mismatch', metavar='', help='Allowed mismatches in the seed for strand identification', type=int, default=2)
parser.add_argument('-c','--conversion', metavar='', help='Bisulfite conversion rate / percentage [default: 99]', type=int, default=99)

args = parser.parse_args()

# call main()
if __name__ == '__main__':
	main(args.fastq,args.conversion,args.read,args.mismatch,args.kmer,args.fasta,args.bed)