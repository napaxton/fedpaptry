################################################
# Initialize your R environment
library(tm)
library(stringr)




################################################
# Getting the Text

fedtext <- scan("~/Desktop/Fedpapers.txt", what="character", sep="\n")

#("http://www.gutenberg.org/dirs/etext91/feder16.txt")

################################################
# Cleaning the Text
print("Cleaning the text . . . ")
# Ignore the Gutenberg preamble and then split each of the 85 (actually 86 
# b/c of two versions of Federalist 70) essays into separate units

# fedtext <- unlist(fedtext)	
startfed <- which(fedtext == "FEDERALIST. No. 1")
endfed <- which(fedtext == "Sciences.\"")
fullfed.lines <-  fedtext[startfed:endfed] #line-split version (with the EOL from the raw text)

chap.positions.v <- grep("FEDERALIST[. ]+No\\.\\s[0-9]", fullfed.lines)
last.position.v <-  endfed #grep("End\\ of\\ the\\ Project\\ Gutenberg\\ Etext\\ of\\ the\\ 
#                Federalist\\ Papers", fedtext)
chap.positions.v  <-  c(chap.positions.v , last.position.v)

chap.contents.l <-list()

pattern <- "FEDERALIST[. ]+No\\.\\s[0-9]{1,2}"
# longpattern <- "FEDERALIST[. ]+No\\.\\s[0-9]{1,2}.*?(FEDERALIST[. ]+No\\.\\s[0-9]{1,2})|(End\\ of\\ the\\ Project\\ Gutenberg\\ Etext\\ of\\ the\\ Federalist\\ Papers)"
# chap.contents.l <- str_split(fullfed.char,pattern=pattern)
chap.contents.l <- list(length(chap.positions.v))
for (i in 1:length(chap.positions.v)){
    if (i != length(chap.positions.v)){
        chapter.start <- chap.positions.v[i]
        chapter.end <- chap.positions.v[i+1]-1
        chap.contents.l[i] <- str_c(fullfed.lines[chapter.start:chapter.end], collapse=" ")
    }
}

#####
# Dump the separated papers to ind. text files in a directory, should you want to use , e.g., the tm package to make corpuses
for (i in 1:length(chap.contents.l)){
    if (i <= 70)
        cat(chap.contents.l[[i]], file=paste0("fedpap", i, ".txt") )
    else if (i == 71)
        cat(chap.contents.l[[i]], file=paste0("fedpap", "70b", ".txt") )
    else cat(chap.contents.l[[i]], file=paste0("fedpap", i-1, ".txt") )
}
#####

# convert \r and \n to " " ### for the separate papers, this was done in the for loop above
# fullfed.char <- str_c(fullfed.lines, collapse=" ") # version with the full text as one long char vector

# convert multiple spaces to a single space


# make list of names of essays (necessary b/c of 2 versions of Federalist 70)
fedpap.names.l <- list()
for (i in 1:length(chap.contents.l)){
    fedpap.names.l[i] <- str_extract(pattern=pattern,chap.contents.l[[i]])
}

# make list of authors
fedpap.authors.l <- list()
auth.patt <- "(HAMILTON|JAY|MADISON)(\\s(AND|OR)\\s(MADISON))?"
fedpap.auth <- lapply(chap.contents.l, str_extract, pattern=auth.patt)

# keep just the text of the essays

# lowercase everything
## fullfed.ch.low <- tolower(fullfed.char) # lower-casing

# remove most punctuation 

# cbind the text, authors, and titles into a data frame
fedpap.data <- cbind(chap.contents.l,fedpap.names.l,fedpap.authors.l)
fedpap.data <- as.data.frame(fedpap.data)

##################################################
#### Working above



##################################################
### Tokenization
##

### tokens for FedPapListNoPunct will be words
FedPapListNoPunctTokens = [essay.split() for essay in FedPapListNoPunct]
##
### drop stop words from FedPapListNoPunct

# keep only stop words

##################################################
### Tagging
##
### We'll use the Brill-based tagger in  MontyLingua

# for FedPapList we will analyze sentences (sentence like units)
#  so first break each essay in FedPapList up into sentences

# tokenize (note the difference in output from the tokenization above)

# Tag part of speech 

##
### get just nouns 

##################################################
### Stemming

##################################################
### Counting Things of Interest
### function to create a dictionary of frequencies


### stemmed non stop word unigram frequency per essay 


# make a list of all words that appear somehwere in the collection

# unstemmed non stop word unigram frequency per essay


# unstemmed stop word unigram frequency per essay 


# unstemmed noun frequency per essay

################################################
# Storing the Data

# store info in NoStopStemAllWords in a NON-SPARSE tab delimited file


################################################
# Cut Code

# for(i in length(chap.positions.v)){
#     if (i != length(chap.positions.v)){
#         chap.contents.l[i] <- fullfed.lines[chap.positions.v[i]:chap.positions.v[i+1]-1]
#     }
#     
# }