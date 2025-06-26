process deseq2 {

	label 'DE'

	input:
	path counts
	path bg_file

	output:
	val("process_complete"), emit: control_7

	script:

	"""
	deseq.r -c ${counts} -b ${bg_file}
	"""
}
