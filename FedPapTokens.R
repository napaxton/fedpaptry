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
     xlab="Top Fifteen Words", ylab="Percentage of Full text", xaxt="n")
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
library(proxy)

# fedpap.vcorp <- VCorpus(DirSource(directory = "./data"))
fedpap.corp <- Corpus(DirSource(directory = "./data"))


for (i in 1:length(fedpap.auth)) {
    fedpap.auth[[i]] -> meta(fedpap.corp[[i]], "author", type="indexed")
}

fedpap.corp <- tm_map(fedpap.corp, stripWhitespace)
fedpap.corp <- tm_map(fedpap.corp, content_transformer(tolower))
fedpap.corp <- tm_map(fedpap.corp, removeWords, stopwords("english"))
fedpap.corp <- tm_map(fedpap.corp, stemDocument)


fedpap.tdm <- TermDocumentMatrix(fedpap.corp)
fed.dtm <- DocumentTermMatrix(fedpap.corp)

# derived from https://eight2late.wordpress.com/2015/07/22/a-gentle-introduction-to-cluster-analysis-using-r/

fed.dtm.m <- as.matrix(fed.dtm)
rownames(fed.dtm.m) <- paste(rownames(fed.dtm.m),fedpap.auth)
feddissim <- dist(fed.dtm.m)
fed.hclust <- hclust(feddissim)
# feddissim.m <- as.matrix(feddissim)
fed.wardhclust <- hclust(feddissim, method="ward.D")

# kmeans(fedpap.tdm, k=2) -> fedpap.2kmeans
# kmeans(fedpap.tdm, k=5) -> fedpap.5kmeans
library(cluster)   
(fed.kfit <- kmeans(feddissim.m, 2))
plot(fed.dtm.m,fed.kfit$cluster, color=T)
