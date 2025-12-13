process samtools {

    label 'samtools'
	
	container "${params.apptainer}/bwa.sif"

    input:
	tuple val(names), path(bam)

    output:
    path("*.csi"), emit: index
	tuple val(names), path("*.bai"), path(bam), emit: bai_index
	path("*.idx"), emit: stats
	val("process_complete"), emit: control_3

    script:

    """
    samtools index \
	-c \
	-o ${bam}.csi \
	${bam}

	samtools index \
	-b \
	-o ${bam}.bai \
	${bam}

	samtools idxstats ${bam} > ${bam}.idx 

    """
}
