#code for the sentiment analysis of German texts with the SentiWS dictionary http://wortschatz.uni-leipzig.de/en/download/
#original SentiWS Paper http://www.lrec-conf.org/proceedings/lrec2012/pdf/327_Paper.pdf
#the base for the code taken from here https://stackoverflow.com/questions/22116938/twitter-sentiment-analysis-w-r-using-german-language-set-sentiws 

readAndflattenSentiWS <- function(filename) { 
  words = readLines(filename, encoding="UTF-8")
  words <- sub("\\|[A-Z]+\t[0-9.-]+\t?", ",", words)
  words <- unlist(strsplit(words, ","))
  words <- tolower(words)
  return(words)
}
pos.words <- readAndflattenSentiWS("SentiWS_v1.8c_Positive.txt")
neg.words <- readAndflattenSentiWS("SentiWS_v1.8c_Negative.txt")

score.sentiment = function(sentences, pos.words, neg.words, .progress='none')
{ 
  require(plyr)
  require(stringr)
  scores = laply(sentences, function(sentence, pos.words, neg.words) 
  {
    # clean up sentences with R's regex-driven global substitute, gsub():
    sentence = gsub('[[:punct:]]', '', sentence)
    sentence = gsub('[[:cntrl:]]', '', sentence)
    sentence = gsub('\\d+', '', sentence)
    # and convert to lower case:
    sentence = tolower(sentence)
    # split into words. str_split is in the stringr package
    word.list = str_split(sentence, '\\s+')
    # sometimes a list() is one level of hierarchy too much
    words = unlist(word.list)
    # compare our words to the dictionaries of positive & negative terms
    pos.matches = match(words, pos.words)
    neg.matches = match(words, neg.words)
    # match() returns the position of the matched term or NA
    # we just want a TRUE/FALSE:
    pos.matches = !is.na(pos.matches)
    neg.matches = !is.na(neg.matches)
    # and conveniently enough, TRUE/FALSE will be treated as 1/0 by sum():
    score = sum(pos.matches) - sum(neg.matches)
    return(score)
  }, 
  pos.words, neg.words, .progress=.progress )
  scores.df = data.frame(score=scores, text=sentences)
  return(scores.df)
}

sample <- c("ich liebe dich. du bist wunderbar",
            "Ich hasse dich, geh sterben!")
(test.sample <- score.sentiment(sample, 
                                pos.words, 
                                neg.words))


library(twitteR)

setup_twitter_oauth("xnEiBhUM5EWhny7nIacZny9lq", 
                    "T6OiSxKlNyEFVm7bFXXyDdXkquPAMnqi2BCzMo9X6fr9HlvoKr", 
                    access_token="1008711195724042240-aakFoyDxIox96pdD2rJomAu9HuQx4s", 
                    access_secret="L93LJAqU0i8uA76LiMJ37hgldE5dgzbuN6xqeddVHNlzt")

tweets1 <- userTimeline("SVPch", n=1000, includeRts=TRUE)


svp <- twListToDF(tweets1) 

svp<-svp[1:280,]
write.csv(svp, "svp_tweets_jan-aug2018.csv")


(svpsent <- score.sentiment(svp$text, 
                                pos.words, 
                                neg.words))


ggplot(svpsent, aes(x = score)) +
  geom_histogram()

svpsent$index<-svp$created
svpsent$index<-as.character(svpsent$index)
svpsent$index<-substr(svpsent$index, start = 7, stop = 10)

svpsent$index<-substr(svpsent$index, start = 1, stop = 1)

svpplot<-ggplot(svpsent, aes(index, score, fill=score)) +
  geom_col(show.legend = FALSE)



tweets2 <- userTimeline("AfD", n=3200, includeRts=TRUE)
afd <- twListToDF(tweets2)
afd$created<-as.character(afd$created)
#check which tweets were created in 2018
grep("2018", afd$created)

#ok, it's all of them, so no filtering

write.csv(afd, "afd_tweets_feb-aug2018.csv")

#we get an error because of some undesirable symbols, let's get rid of them
library(stringr)
Encoding(afd$text)<-"UTF-8"
afd$text <- iconv(afd$text, 'UTF-8')

#try again
(afdsent <- score.sentiment(afd$text, 
                            pos.words, 
                            neg.words))

ggplot(afdsent, aes(x = score)) +
  geom_histogram()

afdsent$index<-afd$created
afdsent$index<-as.character(afdsent$index)
afdsent$index<-substr(afdsent$index, start = 7, stop = 10)

afdsent<-na.omit(afdsent)

ggplot(afdsent, aes(x = score)) +
  geom_histogram()

ggplot(afdsent, aes(index, score, fill=score)) +
  geom_col(show.legend = FALSE)

afdsent$index<-substr(afdsent$index, start = 1, stop = 1)

afdplot<-ggplot(afdsent, aes(index, score, fill=score)) +
  geom_col(show.legend = FALSE)

install.packages("gridExtra")
library(gridExtra)
grid.arrange(svpplot, afdplot, nrow = 2)


#excercise: we have the data for SVP since January and for AfD since February. As we can not get more data for AfD, 
#remove the data for January from the SVP dataset (hint: you will need the grep function for that)
#and redo the graphs so that we have the SVP and AfD graphs matching by months and thus comparable
