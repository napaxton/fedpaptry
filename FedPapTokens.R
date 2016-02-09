# run after doing the FedPapClean.R source file

## Word tokens for frequency analysis
moby.words.l <- strsplit(novel.lower.v, "\\W")
fed.words.v <- unlist(fed.words.l)
not.blanks.v <- which(fed.words.v!="")
fed.words.v <- fed.words.v[not.blanks.v]
total.words.v <- length(fed.words.v)
fed.freqs.t <- table(fed.words.v)
sort.fed.freqs.t <- sort(fed.freqs.t, decreasing=T)
sort.fed.freqs.rel.t <- 100*(sort.fed.freqs.t/sum(sort.fed.freqs.t))
plot(sort.fed.freqs.rel.t[1:15], type="b",
     xlab="Top Fifteeen Words", ylab="Percentage of Full text", xaxt="n")
axis(1, 1:15, labels=names(sort.fed.freqs.rel.t [1:15]))

## Dispersions


## Onward
chap.contents.l <- list(length(chap.positions.v))
for (i in 1:length(chap.positions.v)){
    if (i != length(chap.positions.v)){
        chapter.start <- chap.positions.v[i]
        chapter.end <- chap.positions.v[i+1]-1
        chap.contents.l[i] <- str_c(fullfed.lines[chapter.start:chapter.end], collapse=" ")
    }
}

for(i in 1:length(chap.positions.v)){
    if(i != length(chap.positions.v)){
        chapter.title <- novel.lines.v[chap.positions.v[i]]
        start <- chap.positions.v[i]+1
        end <- chap.positions.v[i+1]-1
        chapter.lines.v <- novel.lines.v[start:end]
        chapter.words.v <- tolower(paste(chapter.lines.v, collapse=" "))
        chapter.words.l <- strsplit(chapter.words.v, "\\W")
        chapter.word.v <- unlist(chapter.words.l)
        chapter.word.v <- chapter.word.v[which(chapter.word.v!="")] 
        chapter.freqs.t <- table(chapter.word.v)
        chapter.raws.l[[chapter.title]] <-  chapter.freqs.t
        chapter.freqs.t.rel <- 100*(chapter.freqs.t/sum(chapter.freqs.t))
        chapter.freqs.l[[chapter.title]] <- chapter.freqs.t.rel
    }
}

## Making corpora with package "tm"
library(tm)

fedpap.corp <- VCorpus(DirSource(directory = "./data"))

fedpap.corp <- tm_map(fedpap.corp, stripWhitespace)
fedpap.corp <- tm_map(fedpap.corp, content_transformer(tolower))
fedpap.corp <- tm_map(fedpap.corp, removeWords, stopwords("english"))
fedpap.corp <- tm_map(fedpap.corp, stemDocument)

for (i in 1:length(fedpap.auth)) {
    fedpap.auth[[i]] -> meta(fedpap.corp[[i]], "author", type="indexed")
}

fedpap.dtm <- TermDocumentMatrix(fedpap.corp)

