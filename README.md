[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
![Nextflow](https://img.shields.io/badge/nextflow-19.10.0-brightgreen)
![](https://img.shields.io/badge/uses-docker-blue.svg)
[![Twitter URL](https://img.shields.io/twitter/url/https/twitter.com/martinhoelzer?label=%40martinhoelzer&style=social)](https://twitter.com/martinhoelzer)

# NEMO
A NExtflow MOdule helper. This is a repository for Nextflow modules and helper scripts.

# Installation

You simply need 

* Docker
* Nextflow

installed to execute tools within this workflow. Please cite Nextflow and the tools you are using. 

# Input examples

* **one** .fastq file per sample: `--nano 'sample1.fastq'`
* paired end illumina: `--illumina 'S_41_17_Cf*.R{1,2}.fastq.gz'`

# Execution example

````
nextflow run main.nf --help
````

# Flowchart
![chart](figures/chart.png)