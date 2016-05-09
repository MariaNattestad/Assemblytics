#! /usr/bin/env python

# Author: Maria Nattestad
# Email: mnattest@cshl.edu
# This script is part of Assemblytics, a program to detect and analyze structural variants from an assembly aligned to a reference genome using MUMmer. 



import argparse


def run(args):

    coords = args.coords
    output_prefix = args.out
    
    f = open(coords)
    f.readline() # ignore header

    fields_by_query = {}
    for line in f:
        fields = line.strip().split(",")
        query_name = fields[7]
        fields_by_query[query_name] = fields_by_query.get(query_name,[]) + [fields]

    f.close()


    flip_by_query = {}
    for query_name in fields_by_query:
        lines = fields_by_query[query_name]
        sum_forward = 0
        sum_reverse = 0
        for fields in lines:
            query_stop = int(fields[3])
            query_start = int(fields[2])
            if query_stop < query_start:
                sum_reverse += abs(int(fields[3])-int(fields[2])) # add alignment length
            else:
                sum_forward += abs(int(fields[3])-int(fields[2]))
        flip_by_query[query_name] = sum_reverse > sum_forward

    f = open(coords)
    fout = open(output_prefix + ".oriented_coords.csv",'w')
    fout.write(f.readline()) # copy the header

    for line in f:
        fields = line.strip().split(",")
        query_name = fields[7]
        if flip_by_query[query_name] == True:
            fields[2] = str(int(fields[5]) - int(fields[2]))
            fields[3] = str(int(fields[5]) - int(fields[3]))

        fout.write(",".join(fields)+ "\n")

    f.close()
    fout.close()


def main():
    parser=argparse.ArgumentParser(description="Index and orient a coordinate file for dotplots.")
    parser.add_argument("-coords",help="coords.csv file from Assemblytics_uniq_anchor.py" ,dest="coords", type=str, required=True)
    parser.add_argument("-out",help="output prefix for indices and oriented coordinates file" ,dest="out", type=str, required=True)
    parser.set_defaults(func=run)
    args=parser.parse_args()
    args.func(args)

if __name__=="__main__":
    main()