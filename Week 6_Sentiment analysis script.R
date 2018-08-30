#Basics of sentiment analysis
#We are going to use Syuzhet package https://cran.r-project.org/web/packages/syuzhet/syuzhet.pdf
#also, tidytext https://cran.r-project.org/web/packages/tidytext/tidytext.pdf


#main resource https://www.tidytextmining.com/sentiment.html

library(stringr)
library(plyr)
library(dplyr)
library(ggmap)
library(wordcloud)
library(tm)
library(httr)
library(SnowballC)
library(syuzhet)
library(tidyr)
library(tidytext)

#reading the data with #fakenews hashtag
alltweets<-read.csv("alltweets.csv", stringsAsFactors = FALSE)

#first we clean the data - create a corpus of tweets and remove links, special characters, etc
myCorpus <- Corpus(VectorSource(alltweets$text))
removeURL <- function(x) gsub("http[^[:space:]]*", "", x)
myCorpus <- tm_map(myCorpus, content_transformer(removeURL))
removeNumPunct <- function(x) gsub("[^[:alpha:][:space:]]*", "", x)
myCorpus <- tm_map(myCorpus, content_transformer(removeNumPunct))
myCorpus <- tm_map(myCorpus, stripWhitespace)
myCorpus <- tm_map(myCorpus, tolower)
myCorpusCopy <- myCorpus
#could also use stemming, but its applicability depends on the data. For our dataset I would prefer not to apply it
#myCorpus <- tm_map(myCorpus, stemDocument)

myCorpus <- Corpus(VectorSource(myCorpus))

#for the further analysis we create a term-document matrix
#it's a 2-dimensional matrix where one column is terms (words fromt the corpus above)
#the second column are documents (in our case, corresponding tweets)
wordFreq <- function(corpus, word) {
  results <- lapply(corpus,
                    function(x) { grep(as.character(x), pattern=paste0("\\<",word)) }
  )
  sum(unlist(results))
}
tdm <- TermDocumentMatrix(myCorpus,control = list(wordLengths = c(1, Inf)))
tdm

#now let's find out what are the most frequent terms in our dataset
(freq.terms <- findFreqTerms(tdm, lowfreq = 100))

#as you can see, there are many "useless" words. Let's remove them
#we have a default stopwords list (you can check it out below)
#we also add some of the words that frequently occur in the tdm, but are useless and are not in the default stopwords list



#removing the stopwords
myCorpus <- tm_map(myCorpus, removeWords, stopwords("english"))
myCorpus <- tm_map(myCorpus, removeWords, c("a", "about", "an", "as", "de","di","e","es","el","il","i","in","it","its","be","by","how","have","le","les","are","q","will","with","you", "leaderfufuuffufuubafufuubcorrupt", "when", "the"))


#let's make a wordcloud out of our corpus now
wordcloud(myCorpus, max.words=100, min.freq=3, scale=c(4,.5), colors=palette())
#ok, it's not perfect, could add more stopwords manually, but works fine

#let's look at the frequency list now
tdm <- TermDocumentMatrix(myCorpus,control = list(wordLengths = c(1, Inf)))
tdm

(freq.terms <- findFreqTerms(tdm, lowfreq = 50))


#now let's plot the most frequent terms
term.freq <- rowSums(as.matrix(tdm))
term.freq <- subset(term.freq, term.freq >= 150)
df2 <- data.frame(term = names(term.freq), freq = term.freq)
ggplot(df2, aes(x=term, y=freq)) + geom_bar(stat="identity") +xlab("Terms") + ylab("Count") + coord_flip() +theme(axis.text=element_text(size=7))


#now let's move on to sentiment analysis


library(SnowballC)
library(twitteR)

#for this we will user different data

#collect recent 200 tweets from Donald Trump

setup_twitter_oauth("xnEiBhUM5EWhny7nIacZny9lq", 
                    "T6OiSxKlNyEFVm7bFXXyDdXkquPAMnqi2BCzMo9X6fr9HlvoKr", 
                    access_token="1008711195724042240-aakFoyDxIox96pdD2rJomAu9HuQx4s", 
                    access_secret="L93LJAqU0i8uA76LiMJ37hgldE5dgzbuN6xqeddVHNlzt")

tweets <- userTimeline("realDonaldTrump", n=200)
trump <- twListToDF(tweets) 
write.csv(trump, "Trump28Aug.csv")
head(trump)


#and first will again remove all the unnecessary symbols and characters
tweets.df2 <- gsub("http.*","",trump$text)
tweets.df2 <- gsub("https.*","",tweets.df2)
tweets.df2 <- gsub("#.*","",tweets.df2)
tweets.df2 <- gsub("@.*","",tweets.df2)
tweets.df2 <- gsub("\n","",tweets.df2)
head(tweets.df2)

word.df <- as.vector(tweets.df2)


#for the analysis itself we are going to use nrc sentiment lexicon https://www.cs.uic.edu/~liub/FBS/sentiment-analysis.html
#it categorizes words in a binary fashion ("yes"/"no") into categories of positive, negative, anger, anticipation, disgust, fear, joy, sadness, surprise, and trust
#it is one of the most popular lexicons, is included into syuzhet and tidytext packages

emotion.df <- get_nrc_sentiment(word.df)
emotion.df2 <- cbind(tweets.df2, emotion.df) 
head(emotion.df2)


sent.value <- get_sentiment(word.df)

most.positive <- word.df[sent.value == max(sent.value)]

most.positive
most.negative <- word.df[sent.value <= min(sent.value)] 
most.negative 


positive.tweets <- word.df[sent.value > 0]
head(positive.tweets)

negative.tweets <- word.df[sent.value < 0]
head(negative.tweets)

neutral.tweets <- word.df[sent.value == 0]
head(neutral.tweets)

#see how Trump's tweets are distributed by sentiment - just a general overview
trump$score<-sent.value
library(ggplot2)
ggplot(trump, aes(x = score)) +
  geom_histogram()

#now let's take a closer look at Trump's tweets

library(tidytext)
#trump<-read.csv("Trump28Aug.csv")
#trump$text<-as.character(trump$text)


#first we divide each tweet into separate words
trump1<- trump %>%
  unnest_tokens(word, text) 

#now with the nrc sentiment dictionary we can look at the words that are used to express joy/anger/other emotions in our dataset
nrc_joy <- get_sentiments("nrc") %>% 
  filter(sentiment == "joy")

trump_joy<-trump1 %>%
  inner_join(nrc_joy) %>%
  count(word, sort = TRUE)

nrc_joy <- get_sentiments("nrc") %>% 
  filter(sentiment == "joy")

trump_anger<-trump1 %>%
  inner_join(nrc_anger) %>%
  count(word, sort = TRUE)

nrc_disgust <- get_sentiments("nrc") %>% 
  filter(sentiment == "disgust")

trump_disgust<-trump1 %>%
  inner_join(nrc_disgust) %>%
  count(word, sort = TRUE)


#now let's look at how the way positive/negative sentiments in Trump's tweets change with time

library(tidyr)

#first we are going to use the same nrc dictionary we used before
trump_sentiment <- trump1 %>%
  inner_join(get_sentiments("nrc")) %>%
  count(word, index = created, sentiment) %>%
  spread(sentiment, n, fill = 0) %>%
  mutate(sentiment = positive - negative)

ggplot(trump_sentiment, aes(index, sentiment, fill=sentiment)) +
  geom_col(show.legend = FALSE)

#ok, it looks a bit strange, so let's just format the index field to represent particular dates (instead of having long lines)
trump_sentiment$index<-as.character(trump_sentiment$index)
trump_sentiment$index<-substr(trump_sentiment$index, start = 9, stop = 10)

#now run the plot again
ggplot(trump_sentiment, aes(index, sentiment, fill=sentiment)) +
  geom_col(show.legend = FALSE)

#now let's compare the three dictionaries we have
#the first one is afinn - http://www2.imm.dtu.dk/pubdb/views/publication_details.php?id=6010
#assigns words with a score that runs between -5 and 5, with negative scores indicating negative sentiment and positive scores indicating positive sentiment.

afinn <- trump1 %>% 
  inner_join(get_sentiments("afinn")) %>% 
  group_by(index = created) %>% 
  summarise(sentiment = sum(score)) %>% 
  mutate(method = "AFINN")

#and format our index to represent the days
afinn$index<-as.character(afinn$index)
afinn$index<-substr(afinn$index, start = 9, stop = 10)

#also, we have nrc (see above) and bing https://www.cs.uic.edu/~liub/FBS/sentiment-analysis.html
# bing categorizes words in a binary fashion into positive and negative categories

bing_and_nrc <- bind_rows(trump1 %>% 
                            inner_join(get_sentiments("bing")) %>%
                            mutate(method = "Bing et al."),
                          trump1 %>% 
                            inner_join(get_sentiments("nrc") %>% 
                                         filter(sentiment %in% c("positive", 
                                                                 "negative"))) %>%
                            mutate(method = "NRC")) %>%
  count(method, index = created, sentiment) %>%
  spread(sentiment, n, fill = 0) %>%
  mutate(sentiment = positive - negative)

#again, format the index
bing_and_nrc$index<-as.character(bing_and_nrc$index)
bing_and_nrc$index<-substr(bing_and_nrc$index, start = 9, stop = 10)

bind_rows(afinn, 
          bing_and_nrc) %>%
  ggplot(aes(index, sentiment, fill = method)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~method, ncol = 1, scales = "free_y")
