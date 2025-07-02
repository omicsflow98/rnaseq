#!/usr/bin/env nextflow

include {stringtie} from '../../processes/stringtie.nf'
include {stringtie_merge} from '../../processes/stringtie.nf'
include {stringtie_abund} from '../../processes/stringtie.nf'
include {ballgown} from '../../processes/ballgown.nf'
include {featurecounts} from '../../processes/featurecounts.nf'
include {deseq2} from '../../processes/DGE.nf' 
workflow diffexp_gene {

    take:
    gene_aligned

    main:

    sample_paths = "${params.outdir}/output/stringtie/"

    stringtie(params.reference, gene_aligned)

    stringtie.out.diffexp
	| collect
	| set { gtf_files }

	stringtie_merge(params.reference, gtf_files)

	stringtie_abund(stringtie_merge.out.annotation, gene_aligned)

    stringtie_abund.out[2]
	| collect
	| set { namesave }

    ballgown(namesave, params.bg_file, sample_paths, params.outdir)

    emit:
    gene_aligned

    
}

workflow diffexp_transcript {

    take:
    transcript_aligned

    main:

    transcript_aligned
	| collect
	| set { bam_files }

	featurecounts(bam_files, params.reference)

    deseq2(featurecounts.out.counts, params.bg_file, params.outdir)
    
}