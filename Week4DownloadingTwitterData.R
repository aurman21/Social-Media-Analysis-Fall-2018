
#Accessing Twitter API and getting the data
#Social Media Analysis Using R, University of Bern,  Fall 2018
# Aleksandra Urman


#install the necessary packages (if you have not done so yet)
install.packages("devtools", dependencies = TRUE)
library(devtools)
install.packages("ROAuth", dependencies = TRUE)
install.packages("twitteR")
devtools::install_version("httr", version="0.6.0", repos="http://cran.us.r-project.org")
install_github("mongosoup/rmongodb")
install_github("smappR", username="SMAPPNYU", dependencies=TRUE)

library(httr)
library(smappR)
library(ROAuth)


#set a new working directory to where you will be saving credentials for downloading data
setwd(~/Dropbox/Credentials)

#now create multiple credentials and save them

requestURL <- "https://api.twitter.com/oauth/request_token"
accessURL <- "https://api.twitter.com/oauth/access_token"
authURL <- "https://api.twitter.com/oauth/authorize"

#credentials 1

consumerKey <- ""
consumerSecret <- ""
my_oauth <- OAuthFactory$new(consumerKey=consumerKey, consumerSecret=consumerSecret, 
                             requestURL=requestURL, accessURL=accessURL, authURL=authURL)
my_oauth$handshake(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))
save(my_oauth, file="my_oauth")

#credentials 2

consumerKey <- ""
consumerSecret <- ""
my_oauth <- OAuthFactory$new(consumerKey=consumerKey, consumerSecret=consumerSecret, 
                             requestURL=requestURL, accessURL=accessURL, authURL=authURL)
my_oauth$handshake(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))
save(my_oauth, file="my_oauth1")

#create as many credentials as you can/want

#getting followers of the city of Bern's official twitter account (https://twitter.com/Bern_Stadt)

bernfol<-getFollowers(screen_name = "Bern_Stadt", oauth_folder="~/Credentials")

write.csv(bernfol, "BernStadtFollowers.csv")

#now get the accounts for the first follower of Bern_Stadt

fr<-getFriends(user_id = bernfol[i], oauth_folder="~/Credentials")


#now let's get recent tweets with #fakenews hashtag
# https://rpubs.com/cosmopolitanvan/twitternetworks


#there are things for which twitteR works better - like collection of tweets, not data on followers
detach("package:smappR", unload=TRUE)
library(twitteR)


setup_twitter_oauth("", 
                    "", 
                    access_token="", 
                    access_secret="")

#collect recent 5000 tweets with #fakenews
alltweets <- twListToDF(searchTwitter("#fakenews", n=5000, lang=NULL,since=NULL, until=NULL,locale=NULL, geocode=NULL, sinceID=NULL, maxID=NULL,resultType=NULL, retryOnRateLimit=120))

#let's save our collection of tweets, we will need it later for network analysis
write.csv(alltweets, "alltweets.csv")

alltweets<-read.csv("alltweets.csv")


#now let's collect a thousand of most recent tweets by Donald Trump
#we are collecting them without the retweets - we are interested only in stuff written by Trump himself
#keep in mind, the maximum number of tweets you can collect is 3200 due to Twitter API limits
tweets <- userTimeline("realDonaldTrump", n=1000, includeRts=FALSE)

#as you can see, the collected data is a list. Let's convert it to a dataframe
trump <- twListToDF(tweets)

#task: collect Trump's tweets WITH RT
#how different are the two datasets (with and without RTs)?
#now save both of the datasets of Trump's tweets
