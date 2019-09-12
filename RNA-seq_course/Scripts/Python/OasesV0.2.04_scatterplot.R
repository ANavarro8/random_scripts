args<-commandArgs(trailingOnly=T)
if(length(args) < 3){
	print("")
	print("Usage <script> scatterplot_file histogram_file output_png")
	q(save="no")
}
	
print("start")
scatterplot<-read.table(file=args[1],header=T)
histo<-read.table(args[2],header=T)
print("files read")
PercentLength=scatterplot$PercentLen
FoldCoverage=scatterplot$CoverageFrac
AllTranscripts=histo$AllTranscriptsHistogram
ChosenTranscripts=histo$ChosenTranscriptsHistogram

png(filename=args[3],bg="transparent")
par(mar=c(5,4,4,4))
plot(PercentLength, FoldCoverage, xlab="Percentile Bins", ylab="",main="Fold coverage and length of all transcripts",col = rgb(0, 0, 0, 0.1))
par(new=T)
plot(AllTranscripts, log = "y", xlab="",ylab="", axes=F, col='red',pch=19)
par(new=T)
plot(ChosenTranscripts, log = "y", xlab="",ylab="", axes=F, col='blue',pch=20)
axis(4, c(1,10,100,1000,10000,1000000))
mtext("Normalized Fold Coverage",side=2,line=2)
mtext("All Transcripts",side=4,line=2,col='red')
mtext("Chosen Transcripts",side=4,line=1,col='blue')
dev.off()
