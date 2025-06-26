#!/usr/bin/env nextflow

include { alignment } from './alignment/alignment.nf'
workflow make_bam {

    take:
    bam_present
    csv_file

    main:
    if (!bam_present) {
		alignment()
		(gene_bam, transcript_bam) = alignment.out
	} else {
		gene_bam = Channel.fromPath(csv_file, checkIfExists: true)
		| splitCsv(header: true, sep: '\t')
		| map { row -> tuple(row.SampName,
				file(row.File1)) 
			}
		transcript_bam = Channel.fromPath(csv_file, checkIfExists: true)
		| splitCsv(header: true, sep: '\t')
		| map { row -> row.File2
			}
	}

    emit:
    gene_bam
    transcript_bam
}