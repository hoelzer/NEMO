/*Comment section: */

process blastGetDB {
  label 'label'
  if (params.cloudProcess) { 
    publishDir "${params.cloudDatabase}/test_db/", mode: 'copy', pattern: "${params.db}" 
  }
  else { 
    storeDir "nextflow-autodownload-databases/test_db/" 
  }  

  output:
    file(params.db)

  script:
    """
    wget ftp://ftp.ensemblgenomes.org/pub/bacteria/release-45/fasta/bacteria_44_collection/chlamydia_gallinacea_08_1274_3/dna/${params.db}.gz
    gunzip -f ${params.db}
    """
}

