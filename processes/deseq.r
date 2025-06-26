#!/usr/bin/env Rscript

suppressMessages(library(DESeq2))
suppressMessages(library(magrittr))
suppressMessages(library(readr))
suppressMessages(library(tidyr))
suppressMessages(library(dplyr))
suppressMessages(library(optparse))

option_list <- list(
  make_option(c("-c", "--counts_file"), default = NULL,
              help = "featurecounts count file", metavar = "counts files"),

  make_option(c("-b", "--ballgown_file"), default = NULL,
              help = "ballgown parameter file", metavar = "ballgown file")
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

if (is.null(opt$vc)) {
  print_help(opt_parser)
  stop("At least one argument must be supplied (gtf files) ", call. = FALSE)
}

dir.create(file.path("${launchDir}", "output", "DE"))

countfile <- as.matrix(read.csv(opt$counts_file,
                                sep = "\t",
                                row.names = "Geneid",
                                check.names = FALSE))

sampletable <- read.table(file = opt$ballgown_file,
                          sep = "\t",
                          header = TRUE)

rownames(sampletable) <- sampletable$SampID
sampletable$SampID <- NULL

countfile <- countfile[, match(rownames(sampletable), colnames(countfile))]

for (condition in colnames(sampletable)) {

  newtable <- sampletable %>%
    select(all_of(condition))

  newtable[, 1] <- as.factor(newtable[, 1])

  newtable <- newtable %>%
    filter(.[[1]] != 2)

  countnew <- countfile[, colnames(countfile) %in% rownames(newtable)]

  colnameformula <- as.formula(paste("~", colnames(newtable)[1]))

  dds <- DESeqDataSetFromMatrix(countData = countnew,
                                colData = newtable,
                                design = colnameformula)
  dds <- DESeq(dds)
  res <- results(dds)
  res <- as.data.frame(res)
  res <- arrange(res, padj)
  res$geneIDs <- rownames(res)

  res <- res %>%
    relocate(geneIDs)

  final_path <- file.path("${launchDir}", "output", "DE", condition, "deseq")

  dir.create(final_path, recursive = TRUE)
  full_path <- file.path(final_path, "DGE.csv")

  write.csv(res,
            file = full_path,
            row.names = FALSE,
            quote = FALSE)

}