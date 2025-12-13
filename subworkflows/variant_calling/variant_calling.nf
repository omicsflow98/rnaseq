#!/usr/bin/env nextflow

include {splitreads} from '../../processes/splitreads.nf'
include {samtools} from '../../processes/samtools.nf'
include {BQSR} from '../../processes/bqsr.nf'
include {gvcf} from '../../processes/VariantCalling.nf'
include {mergedgvcf} from '../../processes/VariantCalling.nf'

workflow variant_calling {

    take:
    gene_aligned

    main:

    splitreads(params.temp_dir, params.reference, gene_aligned)

    if (params.recalibrate) {
	    BQSR(params.reference, params.temp_dir, splitreads.out.split_bam)
	    bam_files = BQSR.out.bam_bqsr
    } else {
	    bam_files = splitreads.out.split_bam
    }

    samtools(bam_files)

    gvcf(params.reference, params.temp_dir, samtools.out.bai_index)

    gvcf.out.vcf_files
		| collect
		| set {collected_vcf}

	mergedgvcf(params.reference, params.temp_dir, collected_vcf)
    
}