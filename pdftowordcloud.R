#This code downloads and converts pdf to text files using xpdf an open source pdf converter
# download pdftotxt from 
# ftp://ftp.foolabs.com/pub/xpdf/xpdfbin-win-3.03.zip
# and extract to your program files folder

# Local Docs --------------------------------------------------------------


# here is a pdf for mining

dest <- "C:\\Users\\mmann\\Desktop//IPS-38D33C70-7B8A-4286-AFDA-8B0E1E61E95D.pdf"
dest = "http://www.researchgate.net/profile/Robert_Kaufmann2/publication/259517313_Pasture_conversion_and_competitive_cattle_rents_in_the_Amazon/links/00b4952c9ca36d8c43000000.pdf"
# set path to pdftotxt.exe and convert pdf to text
exe <- "C:\\Program Files\\Xpdf\\pdftotext.exe"
system(paste("\"", exe, "\" \"", dest, "\" -layout", sep = ""), wait = F)
#system(paste("\"", exe, "\" \"", dest, "\"", sep = ""), wait = F)

# get txt-file name and open it  
filetxt <- sub(".pdf", ".txt", dest)
shell.exec(filetxt)    # strangely the first try sometimes throws an error..
shell.exec(filetxt) 
# set path to pdftotxt.exe and convert pdf to text
exe <- "C:\\Program Files\\Xpdf\\pdftotext.exe"
#system(paste("\"", exe, "\" \"", dest, "\" -table", sep = ""), wait = F)
system(paste("\"", exe, "\" \"", dest, "\"", sep = ""), wait = F)

# get txt-file name and open it  
filetxt <- sub(".pdf", ".txt", dest)
shell.exec(filetxt)    # strangely the first try sometimes throws an error..
shell.exec(filetxt) 




# Online docs -------------------------------------------------------------



# here is a pdf for mining
url <- "https://www.researchgate.net/profile/Michael_Mann6/publication/264235193_Modeling_residential_development_in_California_from_2000_to_2050_Integrating_wildfire_risk_wildland_and_agricultural_encroachment/links/53d3a3c90cf220632f3cd974.pdf?origin=publication_detail&ev=pub_int_prw_xdl&msrp=2QjwQ60gkdWjUnnu2N8vRinUm57gFwSlxJAzeMS7oIaIx1iYoNQZakiW94IWkjeBfFWCCyEQ1%2BiwTSDmWAXgJA%3D%3D_bw2pKNto4h5lD%2FjTDgqbGUubzhN9oUaUQFBP6I98JIpI4WXsF0Dhv9KcslOGWrN%2Ff43oV84bictH207toJTViQ%3D%3D_mEz0f3HrjS4%2BbJtoyEjt2EhHVq3lLVSRM%2FjoKfC3nMOUKbvcRHyCKlp8JudVBTclfDQxmJEULlG%2By79QEwL9Vg%3D%3D"
dest <- tempfile(fileext = ".pdf")
download.file(url, dest, mode = "wb",)

# set path to pdftotxt.exe and convert pdf to text
exe <- "C:\\Program Files\\Xpdf\\pdftotext.exe"
system(paste("\"", exe, "\" \"", dest, "\" -table", sep = ""), wait = F)
#system(paste("\"", exe, "\" \"", dest, "\"", sep = ""), wait = F)

# get txt-file name and open it  
filetxt <- sub(".pdf", ".txt", dest)
shell.exec(filetxt)    # strangely the first try sometimes throws an error..
shell.exec(filetxt) 

# do something with it, i.e. a simple word cloud 
library(tm)
library(wordcloud)
library(Rstem)
library(RTextTools)
library(RColorBrewer)


txt <- readLines(filetxt) # don't mind warning..

txt <- tolower(txt)
txt <- removeWords(txt, c("\\f", stopwords()))

corpus <- Corpus(VectorSource(txt))
corpus <- tm_map(corpus, removePunctuation)
tdm <- TermDocumentMatrix(corpus)
m <- as.matrix(tdm)
d <- data.frame(freq = sort(rowSums(m), decreasing = TRUE))

# Stem words
d$stem <- wordStem(row.names(d), language = "english")

# and put words to column, otherwise they would be lost when aggregating
d$word <- row.names(d)

# remove web address (very long string):
d <- d[nchar(row.names(d)) < 20, ]

# aggregate freqeuncy by word stem and
# keep first words..
agg_freq <- aggregate(freq ~ stem, data = d, sum)
agg_word <- aggregate(word ~ stem, data = d, function(x) x[1])

d <- cbind(freq = agg_freq[, 2], agg_word)

# sort by frequency
d <- d[order(d$freq, decreasing = T), ]

# set up color pallete
pal <- brewer.pal(8, "Set3")
pal <- pal[-(1:2)]

# print wordcloud:
windows()
wordcloud(d$word, d$freq,max.words = 150, colors=pal, vfont=c("sans serif","bold"))

# remove files
file.remove(dir(tempdir(), full.name=T)) # remove files
