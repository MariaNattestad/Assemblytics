#! /usr/bin/env python



# Author: Maria Nattestad
# Email: mnattest@cshl.edu
# This script is part of Assemblytics, a program to detect and analyze structural variants from an assembly aligned to a reference genome using MUMmer. 


import argparse
from intervaltree import *
import time


def run(args):
    filename = args.delta
    unique_length = args.unique_length
    output_filename = args.out

    f = open(filename)
    
    # Ignore the first two lines for now
    f.readline()
    f.readline()

    linecounter = 0

    current_query_name = ""
    current_header = ""

    lines_by_query = {}
    header_lines_by_query = {}

    before = time.time()

    for line in f:
        if line[0]==">":
            linecounter += 1

            fields = line.strip().split()
            current_query_name = fields[1]
            current_header = line.strip()
            
        else:
            fields = line.strip().split()
            if len(fields) > 4:
                lines_by_query[current_query_name] = lines_by_query.get(current_query_name,[]) + [line.strip()]
                header_lines_by_query[current_query_name] = header_lines_by_query.get(current_query_name,[]) + [current_header]
    f.close()

    print "First read through the file: %d seconds for %d query-reference combinations" % (time.time()-before,linecounter)
    

    before = time.time()
    alignments_to_keep = {}
    num_queries = len(lines_by_query)
    print "Filtering alignments of %d queries" % (num_queries)
    
    num_query_step_to_report = num_queries/100
    if num_queries < 100:
        num_query_step_to_report = num_queries/10
    if num_queries < 10:
        num_query_step_to_report = 1

    query_counter = 0
    for query in lines_by_query:
        alignments_to_keep[query] = summarize(lines_by_query[query], unique_length_required = unique_length)
        query_counter += 1
        if (query_counter % num_query_step_to_report) == 0:
            print "Progress: %d%%" % (query_counter*100/num_queries)
    print "Progress: 100%"

    print "Deciding which alignments to keep: %d seconds for %d queries" % (time.time()-before,num_queries)
    before = time.time()

    f = open(filename)

    fout = open(output_filename,'w')
    fout.write(f.readline())
    fout.write(f.readline())
    
    linecounter = 0

    list_of_alignments_to_keep = []
    alignment_counter = {}
    keep_printing = False
    for line in f:
        linecounter += 1
        if line[0]==">":
            fields = line.strip().split()
            query = fields[1]
            list_of_alignments_to_keep = alignments_to_keep[query]

            header_needed = False
            for index in list_of_alignments_to_keep:
                if line.strip() == header_lines_by_query[query][index]:
                    header_needed = True
            if header_needed == True:
                fout.write(line) # if we have any alignments under this header, print the header
            alignment_counter[query] = alignment_counter.get(query,0)
        else:
            fields = line.strip().split()
            if len(fields) > 4:
                if alignment_counter[query] in list_of_alignments_to_keep:
                    fout.write(line)
                    keep_printing = True
                else:
                    keep_printing = False
                alignment_counter[query] = alignment_counter[query] + 1
            elif keep_printing == True:
                fout.write(line)
    
    print "Reading file and recording all the entries we decided to keep: %d seconds for %d total lines in file" % (time.time()-before,linecounter)

def summarize(lines, unique_length_required):
    before = time.time()
    alignments_to_keep = []
    # print len(lines)

    if len(lines)==0:
        return alignments_to_keep

    if len(lines) == 1:
        fields = lines[0].strip().split()
        query_start = int(fields[2])
        query_end = int(fields[3])
        if abs(int(fields[3])-int(fields[2])) >= unique_length_required:
            return [0]

    starts_and_stops = []
    tags = []

    for line in lines:
        fields = line.strip().split()

        query_start = int(fields[2])
        query_end = int(fields[3])
        # sometimes start and end are the other way around, but for the interval tree they need to be in order
        query_min = min([query_start,query_end])
        query_max = max([query_start,query_end])
        starts_and_stops.append((query_min,query_max))

    # build full tree
    tree = IntervalTree.from_tuples(starts_and_stops) 
    
    # print "Prep and building interval tree: %d seconds" % (time.time()-before)
    before = time.time()

    # for each interval (keeping the same order as the lines in the input file)
    line_counter = 0
    for line in lines:
        fields = line.strip().split()
        query_start = int(fields[2])
        query_end = int(fields[3])

        query_min = min([query_start,query_end])
        query_max = max([query_start,query_end])
        
        # create a tree object from the current interval
        this_interval = IntervalTree.from_tuples([(query_min,query_max)])

        # create a copy of the tree without this one interval
        rest_of_tree = tree - this_interval

        # find difference between this interval and the rest of the tree by subtracting out the other intervals one by one
        for other_interval in rest_of_tree:
            this_interval.chop(other_interval.begin, other_interval.end)
        
        # loop through to count the total number of unique basepairs
        total_unique_length = 0
        for sub_interval in this_interval:
            total_unique_length += sub_interval.end - sub_interval.begin

        # if the total unique length is above our threshold, add the index to the list we are reporting       
        if total_unique_length > unique_length_required:
            alignments_to_keep.append(line_counter)
        line_counter += 1


    return alignments_to_keep


def main():
    parser=argparse.ArgumentParser(description="Filters alignments in delta file based whether each alignment has a unique sequence anchoring it")
    parser.add_argument("--delta",help="delta file" ,dest="delta", type=str, required=True)
    parser.add_argument("--out",help="output file" ,dest="out", type=str, required=True)
    parser.add_argument("--unique-length",help="The total length of unique sequence an alignment must have on the query side to be retained. Default: 10000" ,dest="unique_length",type=int, default=10000)
    parser.set_defaults(func=run)
    args=parser.parse_args()
    args.func(args)

if __name__=="__main__":
    main()
