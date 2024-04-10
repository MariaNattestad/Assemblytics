# Assemblytics: a web analytics tool for the detection of variants from an assembly 

Assemblytics is available online at http://assemblytics.com

Please cite our paper in Bioinformatics: http://www.ncbi.nlm.nih.gov/pubmed/27318204

The preprint is still freely available on the BioRxiv: https://www.biorxiv.org/content/10.1101/044925v1

There are three ways to use Assemblytics:
1. Use the hosted online version at http://assemblytics.com. This is the easiest option.
2. Run it from the command-line. For this you need only the contents of the `scripts/` directory. See instructions below.
3. Run the full web app from a local server. See instructions below.


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

## Running Assemblytics locally
### Dependencies
- R
    - ggplot2
    - plyr
    - RColorBrewer
    - scales
- Python
    - argparse
    - numpy

### Command-line instructions
If you prefer to run Assemblytics from the command-line the scripts/ directory contains all the code you need, from unique anchor filtering and calling variants to creating the output plots and summary tables. 

To run Assemblytics on the command-line, keep all the scripts together inside the `scripts/` directory, either in your PATH or anywhere else you like, and make them all executable:
```
chmod a+x scripts/Assemblytics*
```
Keeping the scripts together in the same folder will allow the main `Assemblytics` script to call all the other scripts that do filtering, analysis, indexing, and plotting.

Follow the instructions at http://assemblytics.com for how to prepare your data and get a delta file for Assemblytics. 

Then run Assemblytics:

```
scripts/Assemblytics <delta_file> <output_prefix> <unique_anchor_length> <min_variant_size> <max_variant_size>
```

### Local web app instructions

It is technically possible to install Assemblytics as a web app locally, but I do not recommend this because it is not a very straight-forward process, so unless you're quite familiar with setting up a local web server, you're probably better off using [assemblytics.com](assemblytics.com) or the command-line instructions above.

Here are a few pointers if you choose to make an attempt though:
- Use a local server like [Apache](https://www.apachefriends.org/download.html) and follow the instructions there.
- Clone this repository into a folder called `assemblytics`, to make the `.htaccess` file point the server correctly to the `public/` folder, where the index.php and other pages and web app resources are located.
- Make sure to open up permissions in user_uploads and user_data so the webserver can read and write there. 
- It does not contain the examples as some of these are huge files.

## FAQ

**Can I use this delta file that I already have with other nucmer parameters or that is already filtered?**

This is not recommended because Assemblytics does its own "unique anchor filtering" that relies on being able to see all the unfiltered alignments to analyze which regions of the reference are unique enough to anchor the alignments. Following the instructions above, in particular using `nucmer -maxmatch` without any additional filter steps, is the only method I can recommend because it is how I built and tested Assemblytics. For genomes like human that may have delta files larger than 10 MB, you can run nucmer with `-l 10000` instead of `-l 100`.

**Why are the alignments or variants I see are not showing up in the Assemblytics results?**

First, the unique anchor filtering in Assemblytics might be filtering out some of the alignments. Second, Assemblytics only catalogues the gaps between alignments and the larger within-alignment insertions and deletions that are in the delta file. To see where they came from, if they are between-alignments, you should see the edges of alignments bordering those locations. If they are within-alignments you can see them by using the `show-aligns` command in MUMmer.
