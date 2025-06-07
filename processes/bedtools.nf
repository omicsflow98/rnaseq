process bedtools {

        label 'bedtools'

	publishDir "${params.outdir}/output/bigwig"
        container "${params.apptainer}/bedtools.sif"

        input:
        tuple val(name), path(bam)

        output:
        tuple val(name), path("*.sort.bedgraph"), emit: bedtools
        
        script:
        
        """
        genomeCoverageBed \
	-bga \
        -ibam ${bam} | sort -k1,1 -k2,2n > ${name}.sort.bedgraph  

        """
}

