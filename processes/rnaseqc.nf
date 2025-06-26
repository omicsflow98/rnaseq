process rnaseqc {

    label 'rnaseqc'

    publishDir "${params.outdir}/output/rnaseqc"
	container "${params.apptainer}/rnaseqc.sif"

    input:
	path reference_dir
    tuple val(name), path(bam)

    output:
    path("*.metrics.tsv")
	path("*.exon_reads.gct")
	path("*.gene_reads.gct")
	path("*.gene_tpm.gct")
	path("*.fragmentSizes.txt")
	path("*.coverage.tsv")
	val("process_complete"), emit: control_2

    script:
       
    """
    rnaseqc \
	${reference_dir}/genome.gtf \
	${bam} \
	--bed ${reference_dir}/genome.bed12 \
	--coverage \
	.

    """
}
