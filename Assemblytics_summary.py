#!/usr/bin/env python


# Author: Maria Nattestad
# Email: mnattest@cshl.edu
# This script is part of Assemblytics, a program to detect and analyze structural variants from an assembly aligned to a reference genome using MUMmer. 



import argparse
import numpy as np

def SVtable(args):
    filename = args.file
    minimum_variant_size = args.minimum_variant_size
    maximum_variant_size = args.maximum_variant_size
    simplify_types = False #args.simplify
    f=open(filename)
    typeList = []
    sizeList = []
    rawTypes = []
    for line in f:
        fields = line.strip().split()
        if not fields[4].isdigit():
            continue
        svType = fields[6]
        rawTypes.append(svType)
        if simplify_types == True:
            if svType == "Insertion" or svType == "Expansion":
                typeList.append("Insertion/Expansion")
            elif svType == "Deletion" or svType == "Contraction":
                typeList.append("Deletion/Contraction")
            else:
                typeList.append(svType)
        else:
            typeList.append(svType)
        sizeList.append(int(fields[4]))
    f.close()
    
    size_thresholds = [10,50,100,1000,10000,50000,100000,500000,1000000]

    sizeArray = np.array(sizeList)
    typeArray = np.array(typeList)
    svTypes = ["Insertion","Deletion","Tandem_expansion","Tandem_contraction","Repeat_expansion","Repeat_contraction"] #,"Substitution", "Longrange", "Interchromosomal"]
    if simplify_types == True:
        svTypes = ["Insertion/Expansion","Deletion/Contraction"] #,"Substitution", "Longrange", "Interchromosomal"]
    overall_total = 0
    overall_total_bases = 0
    overall_total_SVs = 0
    overall_total_SV_bases = 0

    SV_size = 50

    all_SV_types = svTypes + list(set(rawTypes)-set(svTypes))
    for svType in all_SV_types:
        sizes = sizeArray[typeArray==svType]
        overall_total += len(sizes)
        overall_total_bases += sum(sizes)
        overall_total_SVs += len(sizes[sizes>=SV_size])
        overall_total_SV_bases += sum(sizes[sizes>=SV_size])
        print svType
        
        format = "%20s%10s%15s"

        print format % ("", "Count","Total bp")
        previous_size = minimum_variant_size
        for threshold in size_thresholds:
            if threshold <= minimum_variant_size or previous_size >= maximum_variant_size:
                continue
            subset = sizes[np.logical_and(sizes>=previous_size,sizes<threshold)]; 
            print format % ("%s-%s bp: " % (intWithCommas(previous_size),intWithCommas(threshold)), str(len(subset)), str(sum(subset)))
            previous_size = threshold

        if previous_size < maximum_variant_size:
            subset = sizes[sizes>=previous_size];    
            print format % ("> %s bp: " % (intWithCommas(previous_size)), str(len(subset)), str(sum(subset)))
            # print "\t> %s bp: \t\t" % (intWithCommas(previous_size)), len(subset), "\t\t", sum(subset)

        # subset = sizes[sizes<50];                              print "\t1-49 bp: \t\t", len(subset), "\t\t", sum(subset)
        # subset = sizes[np.logical_and(sizes>=50,sizes<100)];    print "\t50-99 bp: \t\t", len(subset),"\t\t", sum(subset)
        # subset = sizes[np.logical_and(sizes>=100,sizes<1000)];    print "\t100-999 bp: \t\t", len(subset),"\t\t", sum(subset)
        # subset = sizes[np.logical_and(sizes>=1000,sizes<10000)];    print "\t1000-9,999 bp: \t\t", len(subset), "\t\t", sum(subset)
        # subset = sizes[sizes>=10000];    print "\t> 10,000 bp: \t\t", len(subset), "\t\t", sum(subset)
        print format % ("Total: ",str(len(sizes)),str(sum(sizes))) + "\n"
        
   
    # for svType in list(set(rawTypes)-set(svTypes)):
    #     sizes = sizeArray[typeArray==svType]
    #     overall_total += len(sizes)
    #     overall_total_bases += sum(sizes)
    #     print svType
    #     print "\t\t\t\tCount\t\tTotal bp"
    #     subset = sizes[sizes<50];                              print "\t1-49 bp: \t\t", len(subset), "\t\t", sum(subset)
    #     subset = sizes[np.logical_and(sizes>=50,sizes<=100)];    print "\t50-99 bp: \t\t", len(subset),"\t\t", sum(subset)
    #     subset = sizes[np.logical_and(sizes>=100,sizes<1000)];    print "\t100-999 bp: \t\t", len(subset),"\t\t", sum(subset)
    #     subset = sizes[np.logical_and(sizes>=1000,sizes<10000)];    print "\t1000-9,999 bp: \t\t", len(subset), "\t\t", sum(subset)
    #     subset = sizes[sizes>=10000];    print "\t> 10,000 bp: \t\t", len(subset), "\t\t", sum(subset)
    #     print "\tTotal: \t\t\t", len(sizes), "\t\t", sum(sizes)
    #     print "\n"

    print "Total number of all variants: %s" % (intWithCommas(overall_total))
    print "Total bases affected by all variants: %s bp" % (intWithCommas(int(overall_total_bases)))

    print "Total number of structural variants: %s" % (intWithCommas(overall_total_SVs))
    print "Total bases affected by structural variants: %s bp" % (intWithCommas(int(overall_total_SV_bases)))


def intWithCommas(x):
    if type(x) not in [type(0), type(0L)]:
        raise TypeError("Parameter must be an integer.")
    if x < 0:
        return '-' + intWithCommas(-x)
    result = ''
    while x >= 1000:
        x, r = divmod(x, 1000)
        result = ",%03d%s" % (r, result)
    return "%d%s" % (x, result)

def main():
    parser=argparse.ArgumentParser(description='Output a summary table of variants from assembly-based variant-calling with mummer and svfinder',formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('-i',help='bed file produced by svfinder.pl script',dest='file',type=str,required=True)
    parser.add_argument('-min',help='minimum variant size',dest='minimum_variant_size',type=int,required=True)
    parser.add_argument('-max',help='maximum variant size',dest='maximum_variant_size',type=int,required=True)

    # parser.add_argument('-simplify',help='Lump together Insertion/Expansion and Deletion/Contraction',dest='simplify',action='store_true')
    args=parser.parse_args()
    SVtable(args)
    
if __name__=="__main__":
    main()











