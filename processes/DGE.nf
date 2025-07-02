process deseq2 {

	label 'DE'

	container "${params.apptainer}/deseq.sif"

	input:
	path counts
	path bg_file
	val directory

	output:
	val("process_complete"), emit: control_7

	script:

	"""
	deseq.r -c ${counts} -b ${bg_file} -s ${directory}
	"""
}
