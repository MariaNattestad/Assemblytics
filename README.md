# Assemblytics: a web analytics tool for the detection of variants from an assembly 

Assemblytics is available online at http://assemblytics.com

Please cite our paper in Bioinformatics: http://www.ncbi.nlm.nih.gov/pubmed/27318204

If you prefer to run Assemblytics from the command-line this repository contains all the code, from unique anchor filtering and calling variants to creating the output plots and summary tables. 

The whole web application can also be downloaded and run locally, utilizing the graphical user interface and giving the added benefit of the interactive dot plot which is only available in the web version: https://github.com/marianattestad/assemblytics_web


To run Assemblytics on the command-line, simply copy all the scripts in this repository into your path and make them executable (chmod +x script_name) if necessary.

Follow the instructions at http://assemblytics.com for how to prepare your data and get a delta file for Assemblytics. 

Then run as:
```
Assemblytics delta_file output_prefix unique_anchor_length path_to_R_scripts

```

Important: Use only contigs rather than scaffolds from the assembly. This will prevent false positives when the number of Ns in the scaffolded sequence does not match perfectly to the distance in the reference.
