process stringtie {

    label 'stringtie'

	container "${params.apptainer}/stringtie.sif"

    input:
	path reference_dir
    tuple val(name), path(bam)

    output:
    path("*.gtf"), emit: diffexp

	publishDir "${params.outdir}/output/stringtie/${name}"

    script:
       
    """
    stringtie \
	-G ${reference_dir}/genome.gff3 \
	-o ${name}.gtf \
	${bam}

    """
}

process stringtie_merge {

	label 'stringtie'

	publishDir "${params.outdir}/output/stringtie"
	container "${params.apptainer}/stringtie.sif"

	input:
	path reference_dir
	path stringtie

	output:
	path("merged.annotated.gtf"), emit: annotation
	path("merged*"), emit: stats

	script:

	"""
	stringtie \
    --merge ${stringtie} \
	-G ${reference_dir}/genome.gff3 \
	-o stringtie_merged.gtf

	gffcompare \
	-r ${reference_dir}/genome.gff3 \
	-R \
	-o merged \
	stringtie_merged.gtf

	"""

}

process stringtie_abund {

	label 'stringtie'

	container "${params.apptainer}/stringtie.sif"

    input:
	path mergedgtf
    tuple val(name), path(bam)

	output:
	path("*.tsv"), emit: expression
	path("*.ctab"), emit: ballgown
	val(namesave)
	path("*.gtf"), emit: gtf_file

	publishDir "${params.outdir}/output/stringtie/${name}"
	
	script:

	namesave="${params.outdir}/output/stringtie/${name}"

	"""
	stringtie \
    -e -B \
	-G ${mergedgtf} \
	-A expression.tsv \
	-o ${name}.gtf \
    ${bam}

	"""
}
