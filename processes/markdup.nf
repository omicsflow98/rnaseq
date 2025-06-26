process markduplicates {

    label 'markdup'
	container "${params.apptainer}/gatk.sif"

    publishDir "${params.outdir}/output/markdup"

    input:
	path temp_dir
    tuple val(name), path(bam)

    output:
    tuple val(name), path("*.markdup.bam"), emit: mark_dup
	path("*.txt"), emit: metrics

    script:
       
	"""
	gatk MarkDuplicatesSpark \
	--remove-all-duplicates false \
	--read-validation-stringency SILENT \
	--input ${bam} \
	--tmp-dir ${temp_dir} \
	--spark-master local[*] \
	--metrics-file ${name}.markdup.txt \
	--output ${name}.markdup.bam

	gatk CollectBaseDistributionByCycleSpark \
	--chart ${name}.pdf \
	--tmp-dir ${temp_dir} \
	--spark-master local[*] \
	--input ${name}.markdup.bam \
	--output ${name}.txt

    """
}
