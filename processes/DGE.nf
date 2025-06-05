process deseq2 {

	label 'DE'

	input:
	path counts

	output:
	val("process_complete"), emit: control_7

	script:

	"""
	#!/usr/bin/env Rscript

	library(DESeq2)
	library(tidyverse)

	dir.create(file.path("${launchDir}", "output", "DE"))

	countfile <- as.matrix(read.csv("${counts}",sep="\\t",row.names="Geneid",check.names=FALSE))
	sampletable <- read.table(file="${launchDir}/ballgown.txt", sep='\\t', header=TRUE)
	rownames(sampletable) <- sampletable\$SampID
	sampletable\$SampID <- NULL

	countfile <- countfile[, match(rownames(sampletable), colnames(countfile))]
	
	for (condition in colnames(sampletable)) {

		newtable <- sampletable %>%
			select(all_of(condition))

		newtable[,1] <- as.factor(newtable[,1])

		newtable <- newtable %>%
			filter(.[[1]] != 2)
		
		countnew <- countfile[, colnames(countfile) %in% rownames(newtable)]
		
		colnameformula <- as.formula(paste("~", colnames(newtable)[1]))

		dds <- DESeqDataSetFromMatrix(countData=countnew, colData=newtable, design=colnameformula)
		dds <- DESeq(dds)
		res <- results(dds)
		res <- as.data.frame(res)
		res <- arrange(res,padj)
		res\$geneIDs <- rownames(res)
		res <- res %>% relocate(geneIDs)

		final_path <- file.path("${launchDir}", "output", "DE", condition, "deseq")

		dir.create(final_path, recursive=TRUE)
		full_path <- file.path(final_path, "DGE.csv")

		write.csv(res, file=full_path, row.names=FALSE, quote=FALSE)

	}

	"""
}
