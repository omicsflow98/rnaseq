library(ballgown)
library(tidyverse)
library(metaMA)
library(optparse)

option_list <- list(
  make_option(c("-g", "--gtf_files"), default = NULL,
              help = "gtf file list", metavar = "gtf files"),

  make_option(c("-b", "--ballgown_file"), default = NULL,
              help = "ballgown parameter file", metavar = "ballgown file")
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

if (is.null(opt$vc)) {
  print_help(opt_parser)
  stop("At least one argument must be supplied (gtf files) ", call. = FALSE)
}

samplenames <- opt$gtf_files
samplenames <- strsplit(samplenames, split = " ")[[1]]

sampletable <- read.table(file = opt$ballgown_file, sep = "\t",
                          header = TRUE)

samplenames <- samplenames[match(sampletable$SampID, samplenames)]

for (condition in colnames(sampletable)[-1]) {

  newtable <- sampletable %>%
    select(SampID, all_of(condition))

  newtable <- newtable %>%
    filter(.[[2]] != 2)

  newtable[, 2] <- as.factor(newtable[, 2])

  keepsamples <- samplenames[samplenames %in% newtable[,1]]

  keepsamples <- paste0("${params.outdir}/output/stringtie/", keepsamples)

  bg <- ballgown(samples = keepsamples, meas = "all")
  bg_filt <- subset(bg, "rowVars(texpr(bg))>1", genomesubset = TRUE)

  pData(bg_filt) <- newtable

  deres <- stattest(bg_filt, feature = "transcript",
                    meas = "FPKM",
                    covariate = condition,
                    getFC = TRUE)

  deres <- data.frame(geneNames = ballgown::geneNames(bg_filt),
                      geneIDs = ballgown::geneIDs(bg_filt),
                      deres)

  deres[, "log2fc"] <- log2(deres[, "fc"])

  deres <- deres[, c("geneNames", "geneIDs", "feature", "id",
                     "fc", "log2fc", "pval", "qval")]

  deres <- arrange(deres, qval)

  final_path <- file.path("${launchDir}", "output", "DE", condition, "ballgown")

  dir.create(final_path, recursive = TRUE)

  full_path <- file.path(final_path, "DTE.csv")

  write.csv(DEres, file = full_path, row.names = FALSE, quote = FALSE)

}