import sys
from numpy import mean
from numpy import median
from scipy.stats import *

#
#This notice has been added by the downloader
#
#Python script Downloaded from http://code.google.com/p/oases-to-csv/
#Original author: Adrian Reich <adrian.m.reich@gmail.com>
#

Usage = """
Usage: OasesOutputToCsvDataBase.py This script will read the output files from Oases and generate a csv file that can be used to create a FileMaker database of your transcriptome data or simply to be able to centralize and easily parse the data.
The script is executed as follows:python OasesFileMakerDBgenerator.py OutFilePrefix

You need to navigate to the folder that contains the output from your Oases assembly and you need to have not renamed or modified the following files from Oases:
transcripts.fa, contig-ordering.txt, and stats.txt

You will also be promted for other information:
Upon Prompt 1: The species name (or some other descriptor of your choosing)
Upon Prompt 2: The tissue type sequenced (or another descriptor of your choosing)
Upon Prompt 3: An ID code for this sample (or another short descriptor of your choosing) 
Upon Prompt 4: The sequencing replicate number (or some other number ID of your choosing)
Upon Prompt 5: The transcript length cutoff fraction
Upon Prompt 6: Series of prompts to add protein sequences to the database
Upon Prompt 7: Series of prompts to addBlast2GO annotations to the database

Next step: Import into FileMaker or use to centralize and parse your data
"""

if len(sys.argv) != 2:
	print Usage
else:
	try:
		TransProblem=open('transcripts.fa','r')
		TransProblemString=''
	except IOError:
		TransProblem=True
		TransProblemString='transcripts.fa'
	try:
		ContigProblem=open('contig-ordering.txt','r')
		ContigProblemString=''
	except IOError:
		ContigProblem=True
		ContigProblemString='contig-ordering.txt'
	try:
		StatsProblem=open('stats.txt','r')
		StatsProblemString=''
	except IOError:
		StatsProblem=True
		StatsProblemString='stats.txt'
#	try:
#		SpliceProblem=open('splicing_events.txt','r')
#		SpliceProblemString=''
#	except IOError:
#		SpliceProblem=True
#		SpliceProblemString='splicing_events.txt'
	if TransProblem==True or ContigProblem==True or StatsProblem==True:	# or SpliceProblem==True:
		print 'This program requires the unadultered raw output from an Oases assembly. You appear to have renamed or moved or deleted some of these file(s).'
		print 'The following file(s) have issues:',TransProblemString,ContigProblemString,StatsProblemString	#,SpliceProblemString
		print 'Once you have fixed the file(s), please come back. Goodbye!'
		sys.exit(0)
		
	SMALLEST_LENGTH_FRACTION =42
	IDcode=''
	SpeciesName =''
	Tissue=''
	Replicates=''
	ProtDone=False
	B2GODone=False
	OutFilePrefix=sys.argv[1]
	while len(SpeciesName) == 0 or SpeciesName.count(',') > 0:
		SpeciesName=raw_input('Please type in full species name of organism using no commas: ')
	while len(Tissue) == 0 or Tissue.count(',') > 0:
		Tissue=raw_input('Please type in tissue or sample type using no commas: ')
	while len(IDcode) < 2 or len(IDcode) > 4 or IDcode.isalpha()==False:
		IDcode=raw_input('Please enter a unique ID code between 2 and 4 letters using no commas to help distinguish datasets: ')
	while len(Replicates) == 0 or Replicates.count(',') > 0:
		Replicates=raw_input('Please enter the sequencing replicate number of this sample: ')
	while SMALLEST_LENGTH_FRACTION<=0 or SMALLEST_LENGTH_FRACTION>1.0:
		SMALLEST_LENGTH_FRACTION=float(raw_input('Please enter the transcript length cutoff fraction between 0.01 and 1.00 (converted to 100% scale): '))
	while ProtDone==False:
		ProteinSeqsAvail=raw_input('Do you have protein sequences in .fasta format for the Oases transcriptome? "yes" or "no": ')
		ProteinSeqsAvail=ProteinSeqsAvail.lower()
		if ProteinSeqsAvail=='yes':
			ProtSeqFile=raw_input('Please enter the filename for the protein sequences: ')
			try:
				ProtSeqRead=open(ProtSeqFile,'r')
			except IOError:
				ProtDone=False
				print 'I cannot open '+ProtSeqFile+' Please check the spelling.'
			else:
				ProtTempLine=ProtSeqRead.readline().strip()
				ProtTempFields=ProtTempLine.split('_')
				try:
					Locus=ProtTempFields[1]
					TransFields=ProtTempFields[3].split('/')
					Transcript=TransFields[0]
				except IndexError:
					ProtDone=False
					print 'The file structure of '+ProtSeqFile+" doesn't look right."
					print 'I need the first line to look something like this: >Locus_70297_Transcript_1/1_Confidence_1.000' 
					print 'The first line of '+ProtSeqFile+' looks like: '+ProtTempLine
				else:
					if ProtTempLine[0:7] == '>Locus_' and ProtTempLine.count('/')>0:
						ProtDone=True
					else:
						ProtDone=False
						print 'The file structure of '+ProtSeqFile+" doesn't look right."
						print 'I need the first line to look something like this: >Locus_70297_Transcript_1/1_Confidence_1.000' 
						print 'The first line of '+ProtSeqFile+' looks like: '+ProtTempLine
			TryAgain=False
			while TryAgain==False and ProtDone==False:
				Retry=raw_input('Do you want to try to input protein sequence again? "yes" to continue, "no" to exit program: ')
				Retry=Retry.lower()
				if Retry=='yes':
					TryAgain=True
					ProtDone==False
				elif Retry=='no':
					print 'Goodbye.'
					sys.exit(0)
		elif ProteinSeqsAvail=='no':
			ProtSeqFile=False
			ProtDone=True
	while B2GODone==False:
		B2GOAvail=raw_input('Do you have Blast2GO annotations in .annot format for the Oases transcriptome? "yes" or "no": ')
		B2GOAvail=B2GOAvail.lower()
		if B2GOAvail=='yes':
			B2GOfile=raw_input('Please enter the filename for the B2GO annotations: ')
			try:
				B2GOannotRead=open(B2GOfile,'r')
			except IOError:
				B2GODone=False
				print 'I cannot open '+B2GOfile+' Please check the spelling.'
			else:
				B2GOTempLine=B2GOannotRead.readline().strip()
				B2GOTempFields=B2GOTempLine.split('_')
				B2GOTempBIGfields=B2GOTempLine.split('\t')
				try:
					Locus=B2GOTempFields[1]
					TransFields=B2GOTempFields[3].split('/')
					Transcript=TransFields[0]
					B2GOname=B2GOTempBIGfields[2]
					B2GOtempCode=B2GOTempBIGfields[1]
				except IndexError:
					B2GODone=False
					print 'The file structure of '+B2GOfile+" doesn't look quite right."
					print 'I need the first line to look something like this: Locus_11707_Transcript_5/7_Confidence_0.105	GO:0016604	splicing factor 3a' 
					print 'The first line of '+B2GOfile+' looks like: '+B2GOTempLine
				else:
					if B2GOtempCode[0:3] == 'GO:' and B2GOTempLine.count('/')>0 and B2GOTempLine.count('_')>2:
						B2GODone=True
					else:
						B2GODone=False
						print 'The file structure of '+B2GOfile+" doesn't look right."
						print 'I need the first line to look something like this: Locus_11707_Transcript_5/7_Confidence_0.105	GO:0016604	splicing factor 3a' 
						print 'The first line of '+B2GOfile+' looks like: '+B2GOTempLine
			TryAgain=False
			while TryAgain==False and B2GODone==False:
				Retry=raw_input('Do you want to try to input B2GO annotation again? "yes" to continue, "no" to exit program: ')
				Retry=Retry.lower()
				if Retry=='yes':
					TryAgain=True
					B2GODone==False
				elif Retry=='no':
					print 'Goodbye.'
					sys.exit(0)
		elif B2GOAvail=='no':
			B2GOfile=False
			B2GODone=True
	print 'Thank you for your input, your opinion is valuable to us. Please stand by...'
	
	
	ErrorCount=0
	BabyErrorCount=0
	ErrorOut=open(OutFilePrefix+'_ErrorLog.txt',"w")
	FaRead = open('transcripts.fa',"r")
	FaLine=FaRead.readline().strip()	#enters into first line of file
	Long_Trans={}#key is locus, value is the length of longest transcript
	All_Trans={}#key is locus+Transcript, value is the length of transcript
	Trans_Per_Locus={}#key is locus, value is list of all transcript numbers
	print 'Reading transcripts.fa. Measuring length of all transcripts and the longest transcript in each locus.'
	PrevLocus=''
	LongestTrans=0
	AllTransLengthsList = []
	AllTransLengthTotal = 0
	while FaLine != '':
		if FaLine[0:7] == '>Locus_':
			FaFields=FaLine.split('_')
			Locus=int(FaFields[1])
			TransFields=FaFields[3].split('/')
			Transcript=int(TransFields[0])
			LocusTransID=str(str(Locus)+'T'+str(Transcript))
			if Locus not in Trans_Per_Locus:
				TransLocusList=list()
			else:
				TransLocusList=list(Trans_Per_Locus[Locus])
			TransLocusList.append(Transcript)
			Trans_Per_Locus[Locus]=TransLocusList
			FaLine=FaRead.readline()
			while FaLine=='\n':
				FaLine=FaRead.readline()
			FaLine=FaLine.strip()
		FaSeq = []
		while FaLine[0:7] != '>Locus_' and FaLine != '':	#loop through fasta file to generate fasta sequence
			FaSeq.append(FaLine)
			FaLine=FaRead.readline()
			while FaLine=='\n':
				FaLine=FaRead.readline()
			FaLine=FaLine.strip()
		FaSeq=''.join(FaSeq)	#convert sequence to single line
		AllTransLengthTotal += len(FaSeq)
		AllTransLengthsList.append(len(FaSeq))
		All_Trans[LocusTransID] = len(FaSeq)
		if PrevLocus==Locus and len(FaSeq) > LongestTrans:
			LongestTrans=len(FaSeq)
			Long_Trans[Locus]=len(FaSeq)
		elif PrevLocus!=Locus and Locus not in Long_Trans:
			LongestTrans=len(FaSeq)
			Long_Trans[Locus]=len(FaSeq)
		PrevLocus=Locus
	FaRead.close()
	AllTransLengthsList.sort(reverse=True)
	AllTransN50Target = AllTransLengthTotal * float(.50)
	RunningTotal = 0
	for i in AllTransLengthsList:
		RunningTotal += i
		if RunningTotal > AllTransN50Target:
			AllTransN50=str(i)
			break
	
	print "Reading stats.txt. Measuring the fold coverage of each node (parts of each transcript)."
	stats = open('stats.txt',"r")
	first = True
	node_dict = {} #key is nodeid, value is exact coverage
	for i in stats:
		if first == True:
			first = False
			continue
		spls = i.strip().split("\t")
		if spls[6] != 'Inf':
			node_dict[int(spls[0])] = float(spls[6])
	stats.close()
	
	Alt_Splice={}#key is locus, value is list of alt splicing events [MEE aPs SE IR a5p a3p] EMPTY DICT FOR THIS VERSION OF OASES
	
	'''	
	print "Reading splicing_events.txt. Getting alternative splicing events of all transcripts."
	SpliceRead = open('splicing_events.txt',"r")
	Alt_Splice={}#key is locus, value is list of alt splicing events [MEE aPs SE IR a5p a3p] 
	SpliceLine=SpliceRead.readline().strip()	#enters into first line of file
	AltCount=0
	AltTotalList=[0,0,0,0,0,0]
	while SpliceLine != '':
		if ": " in SpliceLine:
			AltCount=AltCount+1
			SpliceFields=SpliceLine.split(' ')
			SpliceLocus=int(SpliceFields[1].strip(':'))
			AltEvent=str(SpliceFields[2]).strip('[]')
			if SpliceLocus not in Alt_Splice:
				AltList=[0,0,0,0,0,0]
			else:
				AltList=list(Alt_Splice[SpliceLocus])
			if AltEvent=='MEE':
				AltList[0]=AltList[0]+1
				AltTotalList[0]=AltTotalList[0]+1
			elif AltEvent=='aPS':
				AltList[1]=AltList[1]+1
				AltTotalList[1]=AltTotalList[1]+1
			elif AltEvent=='SE':
				AltList[2]=AltList[2]+1
				AltTotalList[2]=AltTotalList[2]+1
			elif AltEvent=='IR':
				AltList[3]=AltList[3]+1
				AltTotalList[3]=AltTotalList[3]+1
			elif AltEvent=='a5p':
				AltList[4]=AltList[4]+1
				AltTotalList[4]=AltTotalList[4]+1
			elif AltEvent=='a3p':
				AltList[5]=AltList[5]+1
				AltTotalList[5]=AltTotalList[5]+1
			else:
				ErrorString=str('YIKES!!! there is a value besides [MEE aPS SE IR a5p a3p] in alt splice files: '+str(AltEvent)+', at locus '+str(SpliceLocus))
				ErrorOut.write(ErrorString+'\n')
				ErrorCount=ErrorCount+1
			Alt_Splice[SpliceLocus]=AltList
		SpliceLine=SpliceRead.readline()
		while SpliceLine=='\n':
			SpliceLine=SpliceRead.readline()
		SpliceLine=SpliceLine.strip()
	SpliceRead.close()
	'''	
	
	print "Reading contig-ordering.txt. Measuring coverage of all transcripts and the transcript with the highest coverage in each locus."
	ContigOrdRead = open('contig-ordering.txt',"r")
	High_Fold={}#key is locus, value is the highest fold coverage of locus
	All_Fold={}#key is locus+Transcript, value is the geometric mean of fold coverage of transcript
	COrdLine=ContigOrdRead.readline().strip()	#enters into first line of file
	First=True
	countcount=0
	while COrdLine != '':
		if First==True:
			First=False
			PrevCOrdLocus=''
		if "Transcript" in COrdLine:
			countcount+=1
			COrdFields=COrdLine.split('_')
			COrdLocus=int(COrdFields[1])
			TransFields=COrdFields[3].split('/')
			COrdTranscript=int(TransFields[0])
			COrdLocusTransID=str(str(COrdLocus)+'T'+str(COrdTranscript))
			COrdLine=ContigOrdRead.readline().strip()
			NodeFields=COrdLine.split("->")
			Count=0
			nums = []
			GeoMult=float(1.0)
			for j in NodeFields:
				tid = j.split(":")[0]
				if tid[0] == "-":
					tid = tid[1:]
				if int(tid) in node_dict:
					Count+=1
					nums.append(float(node_dict[int(tid)]))
			if Count>0:
				GeoMean=gmean(nums)
			else:
				GeoMean=float(2.0)	#this represents transcripts in which all nodes have 'inf' coverage
			All_Fold[COrdLocusTransID] = float(GeoMean)
			if All_Trans[COrdLocusTransID] >= Long_Trans[COrdLocus]*SMALLEST_LENGTH_FRACTION:	#only transcripts that are larger than SMALLEST_LENGTH_FRACTION of longest can be considered for highest fold coverage
				if PrevCOrdLocus==COrdLocus and GeoMean > HighestFold:
					HighestFold=GeoMean
					High_Fold[COrdLocus]=GeoMean
				elif PrevCOrdLocus!=COrdLocus and COrdLocus not in High_Fold:
					HighestFold=GeoMean
					High_Fold[COrdLocus]=GeoMean
				PrevCOrdLocus=COrdLocus
		COrdLine=ContigOrdRead.readline()
		while COrdLine=='\n':
			COrdLine=ContigOrdRead.readline()
		COrdLine=COrdLine.strip()
	ContigOrdRead.close()
	
	if ProtSeqFile!=False:
		ProtRead = open(ProtSeqFile,"r")
		ProtLine=ProtRead.readline().strip()	#enters into first line of file
		All_Prots={}#key is locus+Transcript, value is the protein sequence
		print 'Reading protein.fa. Getting protein sequences for all transcripts.'
		while ProtLine != '':
			if ProtLine[0:1] == '>':
				ProtFields=ProtLine.split('_')
				ProtLocus=int(ProtFields[1])
				if ProtLine[1:7] == 'Locus_':
					TransFields=ProtFields[3].split('/')
					ProtTranscript=int(TransFields[0])
				elif ProtLine.count('_Trans_') > 0 and ProtLine.count('_of_') > 0:	#this is here because I modified some of my protein names - START
					ProtTranscript=int(ProtFields[3])	#this is here because I modified some of my protein names - END
				ProtLocusTransID=str(str(ProtLocus)+'T'+str(ProtTranscript))
				ProtLine=ProtRead.readline()
				while ProtLine=='\n':
					ProtLine=ProtRead.readline()
				ProtLine=ProtLine.strip()
			ProtSeq = []
			while ProtLine[0:1] != '>' and ProtLine != '':	#loop through fasta file to generate fasta sequence
				ProtSeq.append(ProtLine)
				ProtLine=ProtRead.readline()
				while ProtLine=='\n':
					ProtLine=ProtRead.readline()
				ProtLine=ProtLine.strip()
			ProtSeq=''.join(ProtSeq)	#convert sequence to single line
			if ProtLocusTransID not in All_Prots:
				All_Prots[ProtLocusTransID] = ProtSeq
			else:
				TempCompareSeq=All_Prots[ProtLocusTransID]
				if TempCompareSeq==ProtSeq:
					ErrorString=str('No biggie! There were multiple instances of Locus+Transcripts in protein file: '+str(ProtLocusTransID)+' but they have the same protein sequence.')
					ErrorOut.write(ErrorString+'\n')
					BabyErrorCount=BabyErrorCount+1
				else:
					ErrorString=str('YIKES! Multiple instances of Locus+Transcripts in protein file: '+str(ProtLocusTransID)+' and they have different protein sequences.')
					ErrorOut.write(ErrorString+'\n')
					ErrorCount=ErrorCount+1
		ProtRead.close()
	
	
	if B2GOfile!=False:
		AnnotsRead = open(B2GOfile, "r")
		B2Gline=AnnotsRead.readline().strip()	#enters into first line of file
		All_B2GO={}#key is locus+Transcript, value is list of the GO name and GO codes, GO name is the first in the list 
		print 'Reading annotation file. Getting Blast2GO names and GO codes for all transcripts.'
		while B2Gline != '':
			B2GbigFields = B2Gline.split('\t')
			B2GgoNum = str(B2GbigFields[1]).strip('GO:')
			B2GgoGene = str(B2GbigFields[2]).replace(',','-').replace(':','-')	#get rid of all commas and colons
			B2GOFields=B2GbigFields[0].split('_')
			B2GOLocus=B2GOFields[1]
			if B2Gline[0:6] == 'Locus_':
				TransFields=B2GOFields[3].split('/')
				B2GOTranscript=int(TransFields[0])
			elif B2Gline.count('_Trans_') > 0 and B2Gline.count('_of_') > 0:	#this is here because I modified some of my B2GO names - START
				B2GOTranscript=int(B2GOFields[3])	#this is here because I modified some of my B2GO names - END
			B2GOLocusTransID=str(str(B2GOLocus)+'T'+str(B2GOTranscript))
			if B2GOLocusTransID not in All_B2GO:
				B2GOList=[B2GgoGene,B2GgoNum]
			else:
				B2GOList=list(All_B2GO[B2GOLocusTransID])
				B2GOList.append(B2GgoNum)
			All_B2GO[B2GOLocusTransID]=B2GOList
			B2Gline=AnnotsRead.readline().strip()
		AnnotsRead.close()


	CopyOut=open(str(OutFilePrefix+'_OasesOutputToCsvDataBase.csv'),'w')
	CopyOutString=str('IDcodeLocus,Species,Tissue,Replicate,CurrentTrans,TotalTrans,LongTrans(T/F),OtherTrans(#/F),Confidence,Splice(Codes/F),RNAseq,RNAlen,ORFseq,ORFlen,b2GOgeneName,GONums\n')
	CopyOut.write(CopyOutString)
	SmallFractionString='%.f' % float(SMALLEST_LENGTH_FRACTION*100)
	ChosenNucSeqs = open(OutFilePrefix+'_OasesChosenTransExcludeBottom'+SmallFractionString+'%.fasta',"w")
	FaRead = open('transcripts.fa',"r")
	Chosen_Len_Precent={}#key is locus, value is the percent length of the chosen transcript in the locus 
	FaLine=FaRead.readline().strip()	#enters into first line of file
	FractionString='%.2f' % float(SMALLEST_LENGTH_FRACTION*100)
	print 'Reading transcripts.fa for output. Copying the transcripts with the highest fold coverage that are longer than '+FractionString+'% of the longest transcript in each locus.'
	First=True
	PrevLocus=''
	ChosenTransLengthsList = []
	ChosenTransLengthTotal = 0
	ChosenTransCount=0
	B2GOcounter=0
	while FaLine != '':
		if FaLine[0:7] == '>Locus_':
			FaFields=FaLine.split('_')
			Locus=int(FaFields[1])
			TransFields=FaFields[3].split('/')
			Transcript=int(TransFields[0])
			LocusTransID=str(str(Locus)+'T'+str(Transcript))
			FullTitle=str(FaLine)
			FaLine=FaRead.readline()
			while FaLine=='\n':
				FaLine=FaRead.readline()
			FaLine=FaLine.strip()
		FaSeq = []
		if PrevLocus!=Locus:
			if First==True:
				First=False
				LocusDone=False
			else:
				LocusDone=False
				###BEGINNING OF DATABASE OUTPUT - ALL BUT LAST ENTRY - COPIED BELOW FOR LAST ENTRY
				ChosenNucSeqs.write(OutString+'\n')
				BigFields=OutString.split('\n')
				OutFields=BigFields[0].split('_')
				TempLocus=int(OutFields[1])
				TempTransFields=OutFields[3].split('/')
				Confidence=str(OutFields[5])
				TempTranscript=int(TempTransFields[0])
				TotalTrans=str(TempTransFields[1])
				TempLocusTransID=str(str(TempLocus)+'T'+str(TempTranscript))
				RNAseq=str(BigFields[1])
				RNALen=str(len(RNAseq))
				if int(RNALen)==Long_Trans[TempLocus]:
					LongestTrans='True'
				else:
					LongestTrans='False'
				OtherTransList=list(Trans_Per_Locus[TempLocus])
				OtherTransList.remove(TempTranscript)
				TempTransList=list(OtherTransList)
				for i in OtherTransList:
					if int(i) <  Long_Trans[TempLocus]*SMALLEST_LENGTH_FRACTION:	#we don't want ALL the transcripts, only those that are longer than the minimum cutoff
						TempTransList.remove(i)
				OtherTransList=list(TempTransList)
				if OtherTransList==[]:
					OtherTrans='False'
				else:
					OtherTrans=str(OtherTransList).strip('[]').replace(',','')
				if TempLocus not in Alt_Splice:
					SpliceCodes='False'
				else:
					AltSpliceList=list(Alt_Splice[TempLocus])
					SpliceCodes=str('MEE-'+str(AltSpliceList[0])+' aPS-'+str(AltSpliceList[1])+' SE-'+str(AltSpliceList[2])+' IR-'+str(AltSpliceList[3])+' a5p-'+str(AltSpliceList[4])+' a3p-'+str(AltSpliceList[5]))
				if ProtSeqFile!=False:
					if TempLocusTransID not in All_Prots:
						ORFseq=str('ERROR Missing Protein Sequence')
						ErrorString=str('Locus '+str(TempLocusTransID)+' does not have a protein sequence, substituted the sequence: "ERROR Missing Protein Sequence".')
						ErrorOut.write(ErrorString+'\n')
						ErrorCount=ErrorCount+1
					else:
						ORFseq=str(All_Prots[TempLocusTransID])
					ORFlen=str(len(ORFseq)*3)
				else:
					ORFseq='None'
					ORFlen=str(0)
				if B2GOfile!=False:
					if TempLocusTransID not in All_B2GO:
						B2GgoGene=''
						B2GgoNumTotal=''
					else:
						B2GOcounter+=1
						B2GOgeneList=list(All_B2GO[TempLocusTransID])
						B2GgoGene=str(B2GOgeneList[0])
						B2GgoNumTotal=str(B2GOgeneList[1:]).strip('[]').replace(',','').replace("'",'')
				else:
					B2GgoGene='None'
					B2GgoNumTotal='0'
				Chosen_Len_Precent[TempLocus]='%.2f' % float((All_Trans[TempLocusTransID]*100)/Long_Trans[TempLocus])
				CopyOutString=str(IDcode+'_'+str(TempLocus)+','+SpeciesName+','+Tissue+','+Replicates+','+str(TempTranscript)+','+TotalTrans+','+LongestTrans+','+OtherTrans+','+Confidence+','+SpliceCodes+','+RNAseq+','+RNALen+','+ORFseq+','+ORFlen+','+B2GgoGene+','+B2GgoNumTotal+'\n')
				CopyOut.write(CopyOutString)
				###END OF DATABASE OUTPUT - ALL BUT LAST ENTRY - COPIED BELOW FOR LAST ENTRY
				
		if All_Fold[LocusTransID]==High_Fold[Locus] and All_Trans[LocusTransID]>=Long_Trans[Locus]*SMALLEST_LENGTH_FRACTION and LocusDone==False:
			while FaLine[0:7] != '>Locus_' and FaLine != '':	#loop through fasta file to generate fasta sequence
				FaSeq.append(FaLine)
				FaLine=FaRead.readline()
				while FaLine=='\n':
					FaLine=FaRead.readline()
				FaLine=FaLine.strip()
			FaSeq=''.join(FaSeq)	#convert sequence to single line
			ChosenTransLengthTotal += len(FaSeq)
			ChosenTransLengthsList.append(len(FaSeq))
			OutString=FullTitle+'\n'+FaSeq
			LocusDone=True
			ChosenTransCount+=1
		else:
			while FaLine[0:7] != '>Locus_' and FaLine != '':	#loop through fasta file to get to next entry
				FaLine=FaRead.readline()
				while FaLine=='\n':
					FaLine=FaRead.readline()
				FaLine=FaLine.strip()
		PrevLocus=Locus
	
	###BEGINNING OF DATABASE OUTPUT - LAST ENTRY ONLY
	ChosenNucSeqs.write(OutString+'\n')
	BigFields=OutString.split('\n')
	OutFields=BigFields[0].split('_')
	TempLocus=int(OutFields[1])
	TempTransFields=OutFields[3].split('/')
	Confidence=str(OutFields[5])
	TempTranscript=int(TempTransFields[0])
	TotalTrans=str(TempTransFields[1])
	TempLocusTransID=str(str(TempLocus)+'T'+str(TempTranscript))
	RNAseq=str(BigFields[1])
	RNALen=str(len(RNAseq))
	if int(RNALen)==Long_Trans[TempLocus]:
		LongestTrans='True'
	else:
		LongestTrans='False'
	OtherTransList=list(Trans_Per_Locus[TempLocus])
	OtherTransList.remove(TempTranscript)
	TempTransList=list(OtherTransList)
	for i in OtherTransList:
		if int(i) <  Long_Trans[TempLocus]*SMALLEST_LENGTH_FRACTION:	#we don't want ALL the transcripts, only those that are longer than the minimum cutoff
			TempTransList.remove(i)
	OtherTransList=list(TempTransList)
	if OtherTransList==[]:
		OtherTrans='False'
	else:
		OtherTrans=str(OtherTransList).strip('[]').replace(',','')
	if TempLocus not in Alt_Splice:
		SpliceCodes='False'
	else:
		AltSpliceList=list(Alt_Splice[TempLocus])
		SpliceCodes=str('MEE-'+str(AltSpliceList[0])+' aPS-'+str(AltSpliceList[1])+' SE-'+str(AltSpliceList[2])+' IR-'+str(AltSpliceList[3])+' a5p-'+str(AltSpliceList[4])+' a3p-'+str(AltSpliceList[5]))
	if ProtSeqFile!=False:
		if TempLocusTransID not in All_Prots:
			ORFseq=str('ERROR Missing Protein Sequence')
			ErrorString=str('Locus '+str(TempLocusTransID)+' does not have a protein sequence, substituted the sequence: "ERROR Missing Protein Sequence".')
			ErrorOut.write(ErrorString+'\n')
			ErrorCount=ErrorCount+1
		else:
			ORFseq=str(All_Prots[TempLocusTransID])
		ORFlen=str(len(ORFseq)*3)
	else:
		ORFseq='None'
		ORFlen=str(0)
	if B2GOfile!=False:
		if TempLocusTransID not in All_B2GO:
			B2GgoGene=''
			B2GgoNumTotal=''
		else:
			B2GOcounter+=1
			B2GOgeneList=list(All_B2GO[TempLocusTransID])
			B2GgoGene=str(B2GOgeneList[0])
			B2GgoNumTotal=str(B2GOgeneList[1:]).strip('[]').replace(',','').replace("'",'')
	else:
		B2GgoGene='None'
		B2GgoNumTotal='0'
	Chosen_Len_Precent[TempLocus]='%.2f' % float((All_Trans[TempLocusTransID]*100)/Long_Trans[TempLocus])
	CopyOutString=str(IDcode+'_'+str(TempLocus)+','+SpeciesName+','+Tissue+','+Replicates+','+str(TempTranscript)+','+TotalTrans+','+LongestTrans+','+OtherTrans+','+Confidence+','+SpliceCodes+','+RNAseq+','+RNALen+','+ORFseq+','+ORFlen+','+B2GgoGene+','+B2GgoNumTotal+'\n')
	CopyOut.write(CopyOutString)
	###END OF DATABASE OUTPUT - LAST ENTRY ONLY
	
	FaRead.close()
	ChosenNucSeqs.close()
	CopyOut.close()
	ChosenTransLengthsList.sort(reverse=True)
	ChosenTransN50Target = ChosenTransLengthTotal * float(.50)
	RunningTotal = 0
	for i in ChosenTransLengthsList:
		RunningTotal += i
		if RunningTotal > ChosenTransN50Target:
			ChosenTransN50=str(i)
			break

	
	print "Generating scatterplot and histograms."
	ChosenNucSeqs = open(OutFilePrefix+'_OasesChosenTransExcludeBottom'+SmallFractionString+'%.fasta',"r")
	ScatterPlot = open(OutFilePrefix+'_ScatterPlotExcludeBottom'+SmallFractionString+'%.txt',"w")
	PercentBins = [x+1 for x in range(100)]
	MasterHisto=[0 for x in range(100)]
	ChosenHisto=[0 for x in range(100)]
	ScatterPlotString='Locus\tTranscript\tPercentLength\tCoverageFraction'
	ScatterPlot.write(ScatterPlotString+'\n')
	for i in All_Trans:
		i=str(i)
		ExtractFields=i.split('T')
		FinalLocus=int(ExtractFields[0])
		FinalTrans=int(ExtractFields[1])
		PercentLen='%.2f' % float((All_Trans[i]*100)/Long_Trans[FinalLocus])
		CoverageFrac='%.4f' % float(All_Fold[i]/High_Fold[FinalLocus])
		MasterDone=False
		ChosenDone=False
		for m in range(len(MasterHisto)):	#generate histograms
			if float(PercentLen)<=int(PercentBins[m]) and MasterDone==False:
				MasterDone=True
				MasterBin=m
			if Chosen_Len_Precent[FinalLocus]=='done':
				ChosenDone=True
			if ChosenDone==False and float(Chosen_Len_Precent[FinalLocus])<=int(PercentBins[m]):
				ChosenDone=True
				ChosenBin=m
			if MasterDone==True and ChosenDone==True:
				break
		MasterHisto[MasterBin]=int(MasterHisto[MasterBin])+1
		if Chosen_Len_Precent[FinalLocus]!='done':
			ChosenHisto[ChosenBin]=int(ChosenHisto[ChosenBin])+1
		Chosen_Len_Precent[FinalLocus]='done'
		
		if All_Fold[i]/High_Fold[FinalLocus] > 1.0:
			CoverageFrac=1.0
		ScatterPlotString=str(str(FinalLocus)+'\t'+str(FinalTrans)+'\t'+PercentLen+'\t'+str(CoverageFrac))
		ScatterPlot.write(ScatterPlotString+'\n')
	ScatterPlot.close()
	ChosenNucSeqs.close()
	Histogram = open(OutFilePrefix+'_HistogramExcludeBottom'+SmallFractionString+'%.txt',"w")
	HistogramString=str('PercentileBinsForHistogram\tAllTranscriptsHistogram\tChosenTranscriptsHistogram')
	Histogram.write(HistogramString+'\n')
	for j in range(len(PercentBins)):
		HistogramString=str(PercentBins[j])+'\t'+str(MasterHisto[j])+'\t'+str(ChosenHisto[j])
		Histogram.write(HistogramString+'\n')
	Histogram.close()
	print 'You have a total of '+str(ChosenTransCount)+' transcripts in your database.'
	if B2GOfile!=False:
		print 'You have a total of '+str(B2GOcounter)+' B2GO annotated transcripts in your database.'
#	print 'The N50 of the raw assembled oases transcriptome is: '+AllTransN50
	print 'The N50 of the transcriptome in the database is: '+ChosenTransN50
	if ErrorCount==0:
		print 'Congratulations! There were no serious errors that occured during the script, enjoy the data.'
		ErrorString='No serious errors were detected during the processing of this script.'
		ErrorOut.write(ErrorString+'\n')
	else:
		print 'WARNING! There were '+str(ErrorCount)+' serious errors that occured in the processing of this script. Please read the '+OutFilePrefix+'_ErrorLog.txt file.'
	print 'There were '+str(BabyErrorCount)+' minor errors that also occured but these can be safely ignored. For details read the '+OutFilePrefix+'_ErrorLog.txt file.'
	ErrorOut.close()
