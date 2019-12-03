# Assemblytics: a web analytics tool for the detection of variants from an assembly 

Assemblytics is available online at http://assemblytics.com

Please cite our paper in Bioinformatics: http://www.ncbi.nlm.nih.gov/pubmed/27318204

The preprint is still freely available on the BioRxiv: https://www.biorxiv.org/content/10.1101/044925v1

There are three ways to use Assemblytics:
1. Use the hosted online version at http://assemblytics.com. This is the easiest option.
2. Run it from the command-line. For this you need only the contents of the `scripts/` directory. See instructions below.
3. Run the full web app from a local server. See instructions below.

Important: Use only contigs rather than scaffolds from the assembly. This will prevent false positives when the number of Ns in the scaffolded sequence does not match perfectly to the distance in the reference.

## Dependencies
- R
    - ggplot2
    - plyr
    - RColorBrewer
    - scales
- Python
    - argparse
    - numpy

## Command-line instructions
If you prefer to run Assemblytics from the command-line the scripts/ directory contains all the code you need, from unique anchor filtering and calling variants to creating the output plots and summary tables. 


To run Assemblytics on the command-line, simply copy all the scripts from the `scripts/` directory into your PATH and make them executable (chmod +x script_name) if necessary.

Follow the instructions at http://assemblytics.com for how to prepare your data and get a delta file for Assemblytics. 

Then run Assemblytics:

```
Assemblytics <delta_file> <output_prefix> <unique_anchor_length> <min_variant_size> <max_variant_size>
```

## Local web app instructions
The whole web application can be downloaded and run locally, utilizing the graphical user interface and giving the added benefit of the interactive dot plot which is only available in the web version and cannot run from the CLI.

Notes for installation:
- Use a local server like [Apache](https://www.apachefriends.org/download.html) and follow the instructions there.
- Clone this repository into a folder called `assemblytics`, to make the `.htaccess` file point the server correctly to the `public/` folder, where the index.php and other pages and web app resources are located.
- Make sure to open up permissions in user_uploads and user_data so the webserver can read and write there. 
- It does not contain the examples as some of these are huge files.
