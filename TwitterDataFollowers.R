
#install the necessary packages (if you have not done so yet)
install.packages("devtools", dependencies = TRUE)
library(devtools)
install.packages("ROAuth", dependencies = TRUE)
devtools::install_version("httr", version="0.6.0", repos="http://cran.us.r-project.org")
install_github("mongosoup/rmongodb")
install_github("smappR", username="SMAPPNYU", dependencies=TRUE)

#library(twitteR)
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

bernfol<-getFollowers(screen_name = "Bern_Stadt", oauth_folder="~/Dropbox/Credentials")

i<-1
bernfr1<-data.frame(Source=character(), Target=character(), stringsAsFactors = FALSE)
bernfr<-data.frame(Source=character(length(fr)), Target=character(length(fr)), stringsAsFactors = FALSE)
fr<-getFriends(user_id = bernfol[i], oauth_folder="~/Dropbox/Credentials")
bernfr$Source<-bernfol[i]
bernfr$Target<-fr
bernfr1<-bernfr
p<-1

while(i<length(bernfol)){
  tryCatch({
    fr<-getFriends(user_id = bernfol[i], oauth_folder="~/Dropbox/Credentials", sleep = 4)
  }, error=function(e){i<-i+1
  p<-p+1})
  bernfr<-data.frame(Source=character(length(fr)), Target=character(length(fr)), stringsAsFactors = FALSE)
  bernfr$Source<-bernfol[i]
  bernfr$Target<-fr
  bernfr1<-rbind(bernfr1, bernfr)
  i<-i+1
}
