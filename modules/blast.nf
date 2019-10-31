process blast {
    label 'blast'
    publishDir "${params.output}/", mode: 'copy', pattern: "${name}.blast"

    input:
    tuple val(name), file(fasta) 
    file db
    
    output:
	file("${name}.blast") 
    
    script:
    """
    makeblastdb -in ${db} -dbtype nucl
    blastn -task blastn -num_threads ${task.cpus} -query ${fasta} -db ${db} -evalue 1e-10 -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend qlen sstart send evalue bitscore slen" > ${name}.blast
    """
}

/* Comments:
I removed the -parse_seqids parameter from the makeblastdb command because of an error with fasta IDs that are longer than 50 chars. strange.
*/