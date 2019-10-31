#!/usr/bin/env nextflow
nextflow.preview.dsl=2

/*
NEMO
Author: hoelzer.martin@gmail.com
*/

/************************** 
* META & HELP MESSAGES 
**************************/

/* 
Comment section: First part is a terminal print for additional user information,
followed by some help statements (e.g. missing input) Second part is file
channel input. This allows via --list to alter the input of --nano & --illumina
to add csv instead. name,path   or name,pathR1,pathR2 in case of illumina 
*/

// terminal prints
if (params.help) { exit 0, helpMSG() }

println " "
println "\u001B[32mProfile: $workflow.profile\033[0m"
println " "
println "\033[2mCurrent User: $workflow.userName"
println "Nextflow-version: $nextflow.version"
println "Starting time: $nextflow.timestamp"
println "Workdir location:"
println "  $workflow.workDir\u001B[0m"
println " "
if (workflow.profile == 'standard') {
println "\033[2mCPUs to use: $params.cores"
println "Output dir name: $params.output\u001B[0m"
println " "}

if (params.profile) { exit 1, "--profile is WRONG use -profile" }
if (params.nano == '' &&  params.illumina == '' &&  params.fasta == '') { exit 1, "input missing, use [--nano] or [--illumina] or [--fasta]"}

/************************** 
* INPUT CHANNELS 
**************************/

// nanopore reads input & --list support
if (params.nano && params.list) { nano_input_ch = Channel
  .fromPath( params.nano, checkIfExists: true )
  .splitCsv()
  .map { row -> ["${row[0]}", file("${row[1]}", checkIfExists: true)] }
  .view() }
  else if (params.nano) { nano_input_ch = Channel
    .fromPath( params.nano, checkIfExists: true)
    .map { file -> tuple(file.baseName, file) }
    .view()
}

// illumina reads input & --list support
if (params.illumina && params.list) { illumina_input_ch = Channel
  .fromPath( params.illumina, checkIfExists: true )
  .splitCsv()
  .map { row -> ["${row[0]}", [file("${row[1]}", checkIfExists: true), file("${row[2]}", checkIfExists: true)]] }
  .view() }
  else if (params.illumina) { illumina_input_ch = Channel
  .fromFilePairs( params.illumina , checkIfExists: true )
  .view() 
}

// fasta input & --list support
if (params.fasta && params.list) { fasta_input_ch = Channel
  .fromPath( params.fasta, checkIfExists: true )
  .splitCsv()
  .map { row -> ["${row[0]}", file("${row[1]}", checkIfExists: true)] }
  .view() }
  else if (params.fasta) { fasta_input_ch = Channel
    .fromPath( params.fasta, checkIfExists: true)
    .map { file -> tuple(file.baseName, file) }
    .view()
}

/************************** 
* MODULES
**************************/

/* Comment section: */

include './modules/blastGetDB' params(cloudProcess: params.cloudProcess, cloudDatabase: params.cloudDatabase, db: params.blast_db)
include './modules/blast' params(output: params.output)


/************************** 
* DATABASES
**************************/

/* Comment section:
The Database Section is designed to "auto-get" pre prepared databases.
It is written for local use and cloud use via params.cloudProcess.
*/

workflow download_blast_db {
  main:
    // local storage via storeDir
    if (!params.cloudProcess) { blastGetDB(); db = blastGetDB.out }
    // cloud storage via db_preload.exists()
    if (params.cloudProcess) {
      db_preload = file("${params.cloudDatabase}/test_db/${params.blast_db}")
      if (db_preload.exists()) { db = db_preload }
      else  { blastGetDB(); db = blastGetDB.out } 
    }
  emit: db
}


/************************** 
* SUB WORKFLOWS
**************************/

/* Comment section: */

workflow subworkflow_blast {
  get: 
    fasta
    db

  main:
    blast(fasta, download_blast_db())
} 

/************************** 
* WORKFLOW ENTRY POINT
**************************/

/* Comment section: */

workflow {
      if (params.fasta) { subworkflow_blast(fasta_input_ch, params.blast_db) }
}


/**************************  
* --help
**************************/
def helpMSG() {
    c_green = "\033[0;32m";
    c_reset = "\033[0m";
    c_yellow = "\033[0;33m";
    c_blue = "\033[0;34m";
    c_dim = "\033[2m";
    log.info """
    ____________________________________________________________________________________________
    
    Workflow: Template
    
    ${c_yellow}Usage example:${c_reset}
    nextflow run wf_template --nano '*/*.fastq' 

    ${c_yellow}Input:${c_reset}
    ${c_green} --nano ${c_reset}            '*.fasta' or '*.fastq.gz'   -> one sample per file
    ${c_green} --illumina ${c_reset}        '*.R{1,2}.fastq.gz'         -> file pairs
    ${c_green} --fasta ${c_reset}           '*.fasta'                   -> one sample per file
    ${c_dim}  ..change above input to csv:${c_reset} ${c_green}--list ${c_reset}            

    ${c_yellow}Options:${c_reset}
    --cores             max cores for local use [default: $params.cores]
    --memory            max memory for local use [default: $params.memory]
    --output            name of the result folder [default: $params.output]

    ${c_yellow}Parameters:${c_reset}
    --blast_db             a variable [default: $params.blast_db]
  
    ${c_dim}Nextflow options:
    -with-report rep.html    cpu / ram usage (may cause errors)
    -with-dag chart.html     generates a flowchart for the process tree
    -with-timeline time.html timeline (may cause errors)

    Profile:
    -profile                 standard (local, pure docker) [default]
                             conda (mixes conda and docker)
                             gcloudMartin (googlegenomics and docker)
                             ${c_reset}
    """.stripIndent()
}
