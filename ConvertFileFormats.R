# convert Files between formats


# check for packages 
pkgTest <- function(x)
{
  if (!require(x,character.only = TRUE))
  {
    install.packages(x,dep=TRUE)
    if(!require(x,character.only = TRUE)) stop("Package not found")
  }
}

pkgTest('foreign')

# function to pull right n letters
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}


# ask for a file
fname <- file.choose()
fname

# set working directory to locaiton of input file
setwd(dirname(fname))
 
# deal with spss files
if(substrRight(fname,4)=='.sav'){
  data = read.spss(fname,to.data.frame = T)
}

# get output file type
#x = readline('Type the type you want to convert to. \n For instance dta for stata, or csv to comma delimited \n >')
if (interactive() ){x = readline('Type the type you want to convert to. \n For instance dta for stata, or csv to comma delimited \n >')
  } else{
  #  non-interactive
  cat("Type the type you want to convert to. \n For instance dta for stata, or csv to comma delimited \n >");
  x = readLines("stdin",n=1);
  }

# write out file will approriate file type
do.call(paste('write.',x,sep=''),list(data,file=paste(sub(substrRight(fname,4),'',basename(fname)),'.',x,sep='')))
 


