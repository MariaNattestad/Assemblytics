#! /usr/bin/env python


# Author: Maria Nattestad
# Email: mnattest@cshl.edu
# This script is part of Assemblytics, a program to detect and analyze structural variants from an assembly aligned to a reference genome using MUMmer. 



import argparse


def run(args):

    coords = args.coords

    f = open(coords)

    fields_by_query = {}
    for line in f:
        fields = line.strip().split()
        query_name = fields[12]
        fields_by_query[query_name] = fields_by_query.get(query_name,[]) + [fields]

    f.close()


    flip_by_query = {}
    for query_name in fields_by_query:
        lines = fields_by_query[query_name]
        longest_alignment_flip = False
        longest_alignment_length = 0
        for fields in lines:
            alignment_length = fields[5]
            if alignment_length > longest_alignment_length:
                longest_alignment_length = alignment_length
                query_stop = int(fields[3])
                query_start = int(fields[2])
                longest_alignment_flip = query_stop < query_start
        flip_by_query[query_name] = longest_alignment_flip

    f = open(coords)
    for line in f:
        fields = line.strip().split()
        query_name = fields[12]
        if flip_by_query[query_name] == True:
            fields[2] = str(int(fields[8]) - int(fields[2]))
            fields[3] = str(int(fields[8]) - int(fields[3]))

        print "\t".join(fields)



def main():
    parser=argparse.ArgumentParser(description="Flips queries in coords file to match the reference. Useful for dot plots.")
    parser.add_argument("--coords",help="coords file from show-coords -rclTH" ,dest="coords", type=str, required=True)
    parser.set_defaults(func=run)
    args=parser.parse_args()
    args.func(args)

if __name__=="__main__":
    main()