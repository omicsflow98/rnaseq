process sortmerna {

        label 'sortmerna'

        publishDir "${params.outdir}/output/sortmerna", mode: 'copy'
        container "${params.apptainer}/sortmerna.sif"

        input:
        path reference_dir
        path fastq

        output:
        path("*.gz"), emit: norrna
        val true, emit: signal

        script:

        """
        sortmerna \
        --ref ${reference_dir}/smr_v4.3_default_db.fasta \
        --reads ${fastq[0]} \
        --reads ${fastq[1]}
        """
}
