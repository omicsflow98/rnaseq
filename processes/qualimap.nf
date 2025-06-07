process qualimap {

    label 'qualimap'

    publishDir "${params.outdir}/output/QC"
	container "${params.apptainer}/qualimap.sif"

    input:
	path reference_dir
    tuple val(name), path(bam)

	output:
	path("qualimap/*.pdf")
	val("process_complete"), emit: control_6

    script:
        
    """

	samtools sort \
	-n \
	-o ${name}.sortedbyname.bam \
	${bam}

    qualimap rnaseq \
	-bam ${name}.sortedbyname.bam \
	-gtf ${reference_dir}/genome.gtf \
	-pe \
	-sorted \
	-outdir qualimap \
	-outfile ${name}

    """
}
