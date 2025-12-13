process splitreads {

    label 'splitreads'
	container "${params.apptainer}/gatk.sif"

    publishDir "${params.outdir}/output/splitreads"

    input:
	path temp_dir
    path reference_dir
    tuple val(name), path(bam)

    output:
    tuple val(name), path("*.split.bam"), emit: split_bam

    script:
       
	"""
	gatk SplitNCigarReads \
    --reference ${reference_dir}/genome.fa \
    --input ${bam} \
    --tmp-dir ${temp_dir} \
    --output ${name}.split.bam

    """
}
