# Assemblytics: a web analytics tool for the detection of variants from an assembly 

> :warning: Assemblytics is pretty outdated at this point, made around 2015 when no other assembly-based variant callers were available and I needed one for my own research. Since then the use of genome assembly has exploded and many more tools are available for downstream variant calling from assemblies, like [SVIM-asm](https://github.com/eldariont/svim-asm) and [SyRI](https://github.com/schneebergerlab/syri).
> Given it's been 8 years since I published Assemblytics, and I haven't worked with genome assemblies since then, I'm not in a great position to answer your questions, compare Assemblytics' results to other tools,  or provide scientific support. I did manage to keep it running until late 2024 when server issues finally made it intractable to keep maintaining it.
> Feel free to use the github issues here to share your favorite alternative assembly-based variant callers.
> Good luck with your research! 🙏 Maria 2024

We recorded a podcast episode discussing the challenge of maintaining academic software including some more back story on Assemblytics: [https://youtu.be/eyd7Cb7ueNg?si=LvFMAIG6A8fDPrma](https://youtu.be/eyd7Cb7ueNg?si=LvFMAIG6A8fDPrma).

[![YouTube video of Academic software podcast episode from the OMGenomics Podcast](https://img.youtube.com/vi/eyd7Cb7ueNg/0.jpg)](https://www.youtube.com/watch?v=eyd7Cb7ueNg)

If you used Assemblytics, please cite our paper in Bioinformatics: http://www.ncbi.nlm.nih.gov/pubmed/27318204

The preprint is still freely available on the BioRxiv: https://www.biorxiv.org/content/10.1101/044925v1

## Input instructions
IMPORTANT: Assemblytics has been configured to work only with MUMmer3 and using the following alignment instructions. Running Assemblytics with any other delta file as input may give errors or miscallibrated results.

Upload a delta file to analyze alignments of an assembly to another assembly or a reference genome

1. Download and install [MUMmer 3](https://sourceforge.net/projects/mummer/files/)
2. Align your assembly to a reference genome using nucmer (from MUMmer package)
```bash
nucmer -maxmatch -l 100 -c 500 REFERENCE.fa ASSEMBLY.fa -prefix OUT
# Settings above are important for unique anchor filtering to work correctly in Assemblytics.
```
Consult the [MUMmer 3 manual](https://mummer.sourceforge.net/manual/) if you encounter problems.

3. Optional: Gzip the delta file to speed up upload (usually 2-4X faster)
```
gzip OUT.delta
```
Then use the OUT.delta.gz file for upload.

4. Upload the .delta or delta.gz file (view example) to Assemblytics

Important: Use only contigs rather than scaffolds from the assembly. This will prevent false positives when the number of Ns in the scaffolded sequence does not match perfectly to the distance in the reference.

The unique sequence length required represents an anchor for determining if a sequence is unique enough to safely call variants from, which is an alternative to the mapping quality filter for read alignment.

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

To run Assemblytics from the command-line the scripts/ directory contains all the code you need, from unique anchor filtering and calling variants to creating the output plots and summary tables. 

To run Assemblytics on the command-line, keep all the scripts together inside the `scripts/` directory, either in your PATH or anywhere else you like, and make them all executable:
```
chmod a+x scripts/Assemblytics*
```
Keeping the scripts together in the same folder will allow the main `Assemblytics` script to call all the other scripts that do filtering, analysis, indexing, and plotting.

Follow the instructions above ("input instructions") for how to prepare your data and get a delta file for Assemblytics. 

Then run Assemblytics:

```
scripts/Assemblytics <delta_file> <output_prefix> <unique_anchor_length> <min_variant_size> <max_variant_size>
```

## Local web app instructions
The whole web application can be downloaded and run locally, utilizing the graphical user interface and giving the added benefit of the interactive dot plot which is only available in the web version and cannot run from the CLI.

Notes for installation:
- Use a local server like [Apache](https://www.apachefriends.org/download.html) and follow the instructions there.
- Clone this repository into a folder called `assemblytics`, to make the `.htaccess` file point the server correctly to the `public/` folder, where the index.php and other pages and web app resources are located.
- Make sure to open up permissions in user_uploads and user_data so the webserver can read and write there. 
- It does not contain the examples as some of these are huge files.
