process ballgown {

    label 'DE'

    input:
    path namesave
    path bg_file

    output:
	val("process_complete"), emit: control_5

        script:

        """
        ballgown.r -g ${namesave} -b ${bg_file}
        """
}
