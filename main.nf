#!/usr/bin/env nextflow

//include {multiqc} from './processes/multiqc.nf'

include { diffexp_gene } from './subworkflows/diffexp.nf'
include { diffexp_transcript } from './subworkflows/diffexp.nf'
include { stats } from './subworkflows/stats.nf'
include { make_bam } from './subworkflows/make_bam.nf'
workflow {

	make_bam(params.bam_present, params.data_csv)
	(gene_bam, transcript_bam) = make_bam.out

	diffexp_gene(gene_bam)

	diffexp_transcript(transcript_bam)

	stats(gene_bam)

//	multiqc(rnaseqc.out.control_2.collect(), samtools.out.control_3.collect(), bigwig.out.control_4.collect(), ballgown.out.control_5, qualimap.out.control_6.collect(), deseq2.out.control_7)

}

