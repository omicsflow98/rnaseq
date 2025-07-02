process ballgown {

    label 'DE'

    container "${params.apptainer}/ballgown.sif"

    input:
    path namesave
    path bg_file
    val samplepath
    val directory

    output:
	val("process_complete"), emit: control_5

        script:

        """
        ballgown.r -f "${namesave}" -b ${bg_file} -p ${samplepath} -s ${directory}
        """
}
