#uncomment the following two lines for first installation
#source("http://bioconductor.org/biocLite.R")
#biocLite("DEGseq")

#load DEGseq
library(DEGseq)

#open gene expression file
expression_file<-read.table("rpkm_geneexpression.txt",sep="\t")

#reserve some layout space for multiple graphs
layout(matrix(c(1, 2, 3, 4, 5, 6), 3, 2, byrow = TRUE))
par(mar = c(2, 2, 2, 2))

#Look at the help/manual for DEGexp command
?DEGexp

#Run DEGexp to get differential gene expression
DEGexp(
    geneExpMatrix1 = expressionfile, #variable holding the expression table
    geneCol1 = 1, #Column number of gene identifier
    expCol1 = c(2, 3, 4, 5, 6), #Column number/s of expression values 
    groupLabel1 = "kidney", #Sample/experimental group name
    geneExpMatrix2 = expressionfile,
    geneCol2 = 1,
    expCol2 = c(2, 3, 4, 5, 6),
    groupLabel2 = "liver",
    method = "MARS" #method for calculation see ?DEGexp for more info
    )

