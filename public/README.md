# Assemblytics (full web application)

This repo contains the full Assemblytics web application.
The web app is running on assemblytics.com, and the command-line version is available at https://github.com/marianattestad/assemblytics
This repository exists so you can install it on your own servers or locally on your computer if need be. 
The code here includes the interactive dot plot (which you can't use from the command-line version).

Dependencies:
- R
    - ggplot
    - plyr
- Python
    - argparse
    - numpy


Notes for installation:
- Make sure to open up permissions in user_uploads and user_data so the webserver can read and write there. 
- It does not contain the examples as some of these are huge files.



