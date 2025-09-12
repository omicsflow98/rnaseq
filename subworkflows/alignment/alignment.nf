#!/usr/bin/env nextflow

include { runfastqc } from '../../processes/fastqc.nf'
include { trim_galore } from '../../processes/trim_galore.nf'
include { bbsplit } from '../../processes/bbsplit.nf'
include { STAR_run1 } from '../../processes/star.nf'
include { STAR_genome } from '../../processes/star.nf'
include { STAR_run2 } from '../../processes/star.nf'
include { markduplicates } from '../../processes/markdup.nf'

workflow alignment {

main:
first_ch = Channel.fromPath(params.data_csv, checkIfExists: true)
	| splitCsv(header: true, sep: '\t')
	| map { row -> tuple(row.SampName,
			file(row.File1),
			file(row.File2),
			row.Adapter1,
			row.Adapter2,
			row.LibName,
			row.Barcode,
			row.Platform) }

runfastqc(first_ch)

if (params.trim) {
	trim_galore(first_ch)
	trimmed_reads = trim_galore.out.trimmed_fastq
} else {
	trimmed_reads = Channel.fromPath(params.data_csv, checkIfExists: true)
	| splitCsv(header: true, sep: '\t')
	| map { row -> tuple(row.SampName,
			row.LibName,
			row.Barcode,
			row.Platform,
			[file(row.File1), file(row.File2)]) 
			}
}

bbsplit(params.rrna, trimmed_reads)

STAR_run1(params.star_index, bbsplit.out.readgroup, bbsplit.out.no_rrna)

STAR_run1.out.tab_files
	| collect
	| set { tab_files }

STAR_genome(params.reference, tab_files)

STAR_run2(bbsplit.out.readgroup, bbsplit.out.no_rrna, STAR_genome.out.starindex)
gene_bam = STAR_run2.out.gene_aligned
transcript_bam = STAR_run2.out.bam


markduplicates(params.temp_dir, STAR_run2.out.gene_aligned)

emit:
gene_bam
transcript_bam

}