process bbsplit {

        label 'bbsplit'

        publishDir "${params.outdir}/output/bbsplit"
        container "${params.apptainer}/bbmap.sif"

        input:
        path rrna
        tuple val(SampName), val(LibName), val(Barcode), val(Platform), path(fastq)

        output:
        path("*_norrna.fastq.gz"), emit: no_rrna
        tuple val(SampName), val(LibName), val(Barcode), val(Platform), emit: readgroup
        path("*_junk.fastq.gz"), emit: junk

        script:

        """
	bbsplit.sh \
        ref=${rrna} \
        in1=${fastq[0]} \
        in2=${fastq[1]} \
        threads=10 \
        basename=%_junk.fastq.gz \
        outu1=${SampName}_norrna.fastq.gz \
        outu2=${SampName}_norrna.fastq.gz

        """

}
