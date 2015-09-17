#! /usr/bin/env python

# Illustration of many data processing steps using the Federalist Papers
# 
# Kevin Quinn
# 9/15/2007
# edited Andy Eggers 9/22/2007 to add progress reporting and conform to most recent nltk distribution

print "Importing necessary modules . . . "
# import the necessary modules
import re
import urllib

import sys

### add MontyLingua location to the search path
### EDIT AND UNCOMMENT THE NEXT LINE!!!
# sys.path.append("your\path\to\montylingua\probably\ending\with\montylingua-2.1\python")
### on my machine this line would say
### sys.path.append("c:\Python25\Lib\site-packages\montylingua-2.1\python")

from MontyLingua import *

import nltk, string 
from nltk import corpus, tokenize 
from nltk import PorterStemmer

## original code said
# from nltk.book import *
## but apparently this module not in the most recent distribution
# source code to nltk.book at http://nltk.org/doc/api/nltk.book-pysrc.html
# imports, in addition to modules re and string,
# wordnet,  stem, tag, chunk, parse, sem, all from nltk 
# stem.Porter is deprecated in favor of PorterStemmer module 

from pprint import pprint 


################################################
# Getting the Text
print "Getting the text . . . "
# from URL:
FedPapFile = urllib.urlopen("http://www.gutenberg.org/dirs/etext91/feder16.txt")
FedPapRaw = FedPapFile.read()
FedPapFile.close()

# or local file:
# FedPapFile = open("../data/feder16.txt")
# FedPapRaw = FedPapFile.read()
# FedPapFile.close()




################################################
# Cleaning the Text
print "Cleaning the text . . . "
# Ignore the Gutenberg preamble and then split each of the 85 (actually 86 
# b/c of two versions of Federalist 70) essays into separate units


pattern = re.compile(r'''(?xs)               # re.VERBOSE and re.DOTALL
                                             #
            FEDERALIST[. ]+No\.\s[0-9]       # start matching here on 
                                             # FEDERALIST No. #
                                             # (note some have a 
                                             # . after FEDERALIST
                                             #
            .*?                              # anything (non-greedy)
                                             #
                                             # finally a lookahead match
                                             # on next essay number or 
                                             # string at end of file
            (?=((FEDERALIST[. ]+No\.\s[0-9]) | 
             (End\ of\ the\ Project\ Gutenberg\ Etext\ of\ the\ 
                Federalist\ Papers)) ) 
            ''')

FedPapList = list(tokenize.regexp_tokenize(FedPapRaw, pattern))  # was tokenize.regexp, but method does not exist


# convert \r and \n to " "
FedPapListWithoutControlChars = [re.sub("\r|\n", " ", essay) for essay in FedPapList]

# convert multiple spaces to a single space
FedPapListWithoutSpaces = [re.sub("\s+", " ", essay) for essay in FedPapListWithoutControlChars]

FedPapList = FedPapListWithoutSpaces[:]


# make list of names of essays (necessary b/c of 2 versions of Federalist 70)
FedPapNameList = []
for essay in FedPapList:
    name_search = re.search("FEDERALIST[. ]+No\.\s[0-9]{1,2}", essay)
    FedPapNameList.append( name_search.group() )

# make list of authors
FedPapAuthorList = []
for essay in FedPapList:
    author_search = re.search("(HAMILTON|JAY|MADISON)(\s(AND|OR)\s(MADISON))?",
                              essay)
    FedPapAuthorList.append( author_search.group() )


# keep just the text of the essays
pattern = re.compile(r'''
             (To\ the\ People\ of\ the\ State\ of\ New\ York)
             .*?                              # anything non-greedy
          $                                # end of string
             ''', re.VERBOSE)
for i in range(len(FedPapList)):
    text_search = re.search(pattern, FedPapList[i])
    FedPapList[i] = text_search.group()


# lowercase everything
FedPapList = [essay.lower() for essay in FedPapList]

# remove most punctuation 
FedPapListNoPunct = [re.sub("[.?!:;,()`'*]|(--)|\[|\]", "", essay) for essay in FedPapList]

##################################################
### Tokenization
##
print "Tokenizing . . . "

### tokens for FedPapListNoPunct will be words
FedPapListNoPunctTokens = [essay.split() for essay in FedPapListNoPunct]
##
### drop stop words from FedPapListNoPunct
def dropList(mylist, rmlist):

    def testfun(somestring, checklist=rmlist):
        return somestring not in checklist

    mylist = filter(testfun, mylist)

    return mylist

stop_words = list(corpus.stopwords.words("english"))  # was "read" instead of "words"; deprecated 
FedPapListNoStop = [dropList(wordlist, stop_words) 
                    for wordlist in FedPapListNoPunctTokens]

# keep only stop words
def keepList(mylist, keeplist):

    def testfun(somestring, checklist=keeplist):
        return somestring in checklist

    mylist = filter(testfun, mylist)

    return mylist

FedPapListJustStop = [keepList(wordlist, stop_words) 
                    for wordlist in FedPapListNoPunctTokens]


##################################################
### Tagging
##
### We'll use the Brill-based tagger in  MontyLingua
print "Now for tagging via MontyLingua . . ."

ML = MontyLingua()

# for FedPapList we will analyze sentences (sentence like units)
#  so first break each essay in FedPapList up into sentences
FedPapListSent = [ML.split_sentences(essay) for essay in FedPapList]

# tokenize (note the difference in output from the tokenization above)
FedPapListSentTokens = [ [ ML.tokenize(sentence) for sentence in essay  ] 
                         for essay in FedPapListSent] 

# Tag part of speech 
FedPapListSentTagged = [ string.join([ ML.tag_tokenized(tokensentence) 
                                        for tokensentence in essay ])  
                          for essay in FedPapListSentTokens]
##
### get just nouns 
FedPapListNouns = [ list(tokenize.regexp_tokenize(essay, "[a-z0-9-]+/NN"))
                    for essay in FedPapListSentTagged]  # regexp_tokenize instead of regexp 
# remove the /NN tags
FedPapListNouns = [ [re.sub("/NN", "", noun) for noun in essay]
                    for essay in FedPapListNouns]
##################################################
### Stemming

print "Stemming . . . "

stemmer = PorterStemmer()
FedPapListNoStopStem = []
for i in range(len(FedPapListNoStop)):
    FedPapListNoStopStem.append( [stemmer.stem(word) 
                               for word in FedPapListNoStop[i] ] )





##################################################
### Counting Things of Interest
### function to create a dictionary of frequencies

print "Counting words . . . "
def makeFreqDict(strlist):
    mydict = {}
    for element in strlist:
        if element in mydict:
            mydict[element] += 1
        else:
            mydict[element] = 1
    
    return mydict
            

### stemmed non stop word unigram frequency per essay 
NoStopStemFreq = [makeFreqDict(essay) for essay in FedPapListNoStopStem]

# make a list of all words that appear somehwere in the collection
NoStopStemAllWords = []
for essay in NoStopStemFreq:
    NoStopStemAllWords = NoStopStemAllWords + essay.keys()
NoStopStemAllWords = list(set(NoStopStemAllWords))
NoStopStemAllWords.sort()

# unstemmed non stop word unigram frequency per essay


# unstemmed stop word unigram frequency per essay 


# unstemmed noun frequency per essay

################################################
# Storing the Data

# store info in NoStopStemAllWords in a NON-SPARSE tab delimited file
print "Outputting data . . . "
outfile = open("../data/NoStopStemAllWords.txt", "w")
outstring = "wordstem"
for essay in FedPapNameList:
    outstring += "\t" + essay
outstring += "\n"
outfile.write(outstring)
##
for wordstem in NoStopStemAllWords:
    outstring = wordstem
    for i in range(len(NoStopStemFreq)):
        if wordstem in NoStopStemFreq[i]:
            outstring += "\t" + str(NoStopStemFreq[i][wordstem])
        else:
            outstring += "\t" + str(0)

    outstring += "\n"
    outfile.write(outstring)

outfile.close()
