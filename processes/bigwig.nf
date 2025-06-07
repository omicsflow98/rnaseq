process bigwig {

        label 'bigwig'

        publishDir "${params.outdir}/output/bigwig"
        container "${params.apptainer}/bigwig.sif"

        input:
        path reference_dir
        tuple val(name), path(bedgraph)

        output:
        path("*.bw"), emit: bigwig
	val("process_complete"), emit: control_4
	
	script:

        """
	bedGraphToBigWig ${bedgraph} \
	${reference_dir}/index/samtools/genome.sizes \
	${name}.bw
        """

}
