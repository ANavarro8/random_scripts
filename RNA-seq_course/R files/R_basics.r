
###############################################################################
## A   Introduction                                                          ##
###############################################################################

## A.1 Recap: RStudio gui
# Four windows:
# 1) Script files
# 2) Workspace / Historsy
# 3) Console
# 4) Files / Plots / Packages / Help

## A.2 R-Console input
# ">" R standard prompt: Expects a command terminated by newline
# "#": Everything to the end of line is comment
# "+" Prompt: Command is not complete at the end of line

###############################################################################
## B   R-Commands                                                            ##
###############################################################################

## B.1 Assignments
a<-1  # equivalent: a=1

## B.2 Expressions
1
1:3
1:3*2
a

## B.3 Command grouping
if(TRUE)
{
  a<-1
  b<-2
  c<-3
}

###############################################################################
## C   R-Objects                                                             ##
###############################################################################

## C.1 Everything is an object
a<-1
class(a)  # a is of type numeric
b<-"abc"
class(b)  # b is of type character

## C.2 Everything is a vector
length(a)
length(1:3)

## C.3 Concatenation
a<-c(1,2,3)
a
length(a)

b<-c("a","b","c")   # Different from "abc"!
b
length(b)
length("abc")


###############################################################################
## D   data.frames                                                           ##
###############################################################################

## D.1 Construction, properties
df<-data.frame(a=1:3,b=c("a","b","c"))
df
class(df)
dim(df)
colnames(df)
rownames(df)

## D.2 Inspecting
n<-1000
df<-data.frame(a=1:n,b=10*1:n)
dim(df)
head(df)
tail(df)

###############################################################################
## E   Indexing                                                              ##
###############################################################################

## E.1 Vectors
a<-1:5*10
a
a[2]
a[c(5,3,1)]
a[4:2]

## E.2 data.frames
df<-data.frame(a=1:3,b=c("a","b","c"),stringsAsFactors=FALSE)
df
df[1,2]
df[1,]
df[,2]
df[2,2]<-"Z"


## E.2.1 column vectors (in data.frames)
names(df)
df$a
df$b[2]
df$b[1]<-"A"
df$c<-c(10,20,30)
df


###############################################################################
## F   Data import and export                                                ##
###############################################################################

## F.1 Working directory
getwd()
dir.create("tmp")
setwd("tmp")

## F.2 Export data
df<-data.frame(a=1:3,b=c("a","b","c"))
write.table(df,"df.csv",sep=";",row.names=FALSE)  # dec=","
df2<-read.table("df.csv",sep=";",header=TRUE)


###############################################################################
## G   Installing and loading CRAN and Bioconductor packages                 ##
###############################################################################

## G.1 Installing CRAN Packages
#  See: http://www.cran.r-project.org/  -> Packages -> Available CRAN Packages
install.packages("HSAUR")
install.packages("TeachingDemos")
chooseCRANmirror()

## G.2 Installing Bioconductor Packages
#  See: http://www.bioconductor.org/
source("http://bioconductor.org/biocLite.R")
chooseBioCmirror()
biocLite("Biobase")

## G.3 Loading packages
library("HSAUR")
library("Biobase")

###############################################################################
## H   Help and Documentation                                                ##
###############################################################################

## H.1 Getting help
help(solve)
?solve
??solve
help.start()
demo(graphics)

## H.2 CRAN Homepage
#  http://www.cran.r-project.org/
#  Manuals
#  Packages

## H.3 Tutorials
#  HSAUR
#  HSAUR2
#  faraway: Practiacl Regression and ANOVA in R

###############################################################################