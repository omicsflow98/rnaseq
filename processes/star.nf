process STAR_run1 {

	label 'STAR'

        publishDir "${params.outdir}/output/STAR/firstpass"
		container "${params.apptainer}/star.sif"

        input:
		path star_index
		tuple val(SampName), val(LibName), val(Barcode), val(Platform)
        path fastq

        output:
        path("*.out.tab"), emit: tab_files

        script:

        """
        STAR \
        --runMode alignReads \
        --genomeDir ${star_index} \
        --readFilesCommand gunzip -c \
		--runThreadN 4 \
		--outSAMunmapped Within \
        --outSAMtype BAM Unsorted \
        --outFileNamePrefix ${SampName}_ \
        --outSAMattrRGline ID:${SampName}      PL:${Platform}   PU:${Barcode}    LB:${LibName}    SM:${SampName} \
        --readFilesIn ${fastq[0]} ${fastq[1]}

        """
}

process STAR_genome {

	label 'STAR'

	publishDir "${params.outdir}/output/STAR/newref"
	container "${params.apptainer}/star.sif"

	input:
	path reference_dir
	path tabfiles

	output:
	path("*"), emit: starindex
	val("Ready"), emit: control

	script:

	"""

	STAR \
	--runMode genomeGenerate \
	--genomeDir . \
	--runThreadN 4 \
	--genomeFastaFiles ${reference_dir}/genome.fa \
	--sjdbFileChrStartEnd ${tabfiles} \
	--sjdbGTFfile ${reference_dir}/genome.gff3 \
	--sjdbGTFtagExonParentTranscript Parent \
	--sjdbOverhang 99 \
	--genomeSAindexNbases 13

	"""

}

process STAR_run2 {

    label 'STAR'

    publishDir "${params.outdir}/output/STAR/aligned", mode: 'copy'
	container "${params.apptainer}/star.sif"

    input:
	tuple val(SampName), val(LibName), val(Barcode), val(Platform)
    path fastq
	val ready

    output:
    tuple val(SampName), path("*.sortedByCoord.out.bam"), emit: gene_aligned
	path("*.sortedByCoord.out.bam"), emit: bam
	path("*.out")

    script:
	
    """
    STAR \
	--runMode alignReads \
	--genomeDir ${params.outdir}/output/STAR/newref \
    --runThreadN 4 \
	--readFilesCommand gunzip -c \
	--outSAMunmapped Within \
    --outSAMtype BAM SortedByCoordinate \
    --outFileNamePrefix ${SampName}_ \
	--outSAMattrRGline ID:${SampName}	PL:${Platform}	PU:${Barcode}	LB:${LibName}	SM:${SampName} \
    --readFilesIn ${fastq[0]} ${fastq[1]}

    """
}
