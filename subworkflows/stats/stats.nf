#!/usr/bin/env nextflow

include {samtools} from '../../processes/samtools.nf'
include {bedtools} from '../../processes/bedtools.nf'
include {bigwig} from '../../processes/bigwig.nf'
include {qualimap} from '../../processes/qualimap.nf'
include {rnaseqc} from '../../processes/rnaseqc.nf'

workflow stats {

    take:
    gene_aligned

    main:
    rnaseqc(params.reference, gene_aligned)

	samtools(gene_aligned)

	bedtools(gene_aligned)

	bigwig(params.reference, bedtools.out.bedtools)

	qualimap(params.reference, gene_aligned)
}