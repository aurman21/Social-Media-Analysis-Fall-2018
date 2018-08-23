# Introduction to R
#Social Media Analysis Using R, University of Bern,  Fall 2018
# Aleksandra Urman
# some parts/ideas on the structure of the code were borrowed from Alexey Knorre's R crash course https://github.com/alexeyknorre/R_crash_course


# R as a calculator

2 + 2
56 * 32
45 ^ 55

## Variables and assignment of variables

# Number
i <- 23
i

# String
s <- 'Hello, world!'
s

# logical (boolean) TRUE/FALSE
b <- TRUE
b

i * 10

## Data structures

# vector
# way to merge data into a vector
v <- c(145, 167, 176, 123, 150)
v
# show observations 1 and 2 from vector v
v[1:2]


# dataframe

years <- c(1980, 1985, 1990)
scores <- c(34, 44, 83)
df <- data.frame(years, scores)
df[,1]
df$years

## control flow

# if-then

a <- 66
if (a > 55) {
  print("Variable a is bigger than 55")
} else {
  print("Variable a is smaller than or equal to 55")
}

# for
mylist <- c(55, 66, 77, 88, 99)
for (value in mylist) {
  print(value)
}

# Functions
hello <- "Hello, my name is "
name <-"_put_your_name_in_here_"
paste0(hello, name)

height <- c(145, 167, 176, 123, 150)
mean(height)
summary(height)


# Let's create our own function
our.mean <- function(x){
  return(sum(x) / length(x))
}

our.mean(height)

# Excercise: write a function, the only argument of which
# is a string containing one's name, and the result -
# string "Hello, my name is [name]"


# rep: repetition of a variable:

rep(name, 10)

# Creating a sequence of numbers:

seq(1,10)
seq(5,9)
seq(3,9) * 3

# Help on function seq:
help(seq)

### Installation of packages and libraries
# Installation
install.packages("dplyr")
# Activating package in the current session
library("dplyr")
# you can install more than one package at a time
install.packages(c("smappR","igraph","ggplot2", "stringr", "httr", "readxl"))


###    data cleaning

# reading files, importing them as dataframes

#reading excel file from url to R
library(readxl)
library(httr)
#the part on excel is taken from ecpr 2018 basic R course by Akos Mate https://github.com/aakosm/r_basics_ecpr18/blob/master/01_02_data_import.Rmd
# this is the url where I have uploaded the Excel file. We store it in the url object to use it with the GET function
url <- "https://rawgit.com/aakosm/r_basics_ecpr18/master/qog_bas_cs_jan18.xlsx"

# we download the file at the url, and write it into a new file with the write_dist argument.
GET(url, write_disk("qog_excel.xlsx", overwrite=TRUE))
# after we are done, let's load the excel file with the `read_excel` function.
qog_excel <- read_excel("qog_excel.xlsx")

#this was just a test, we now can remove the excel dataframe as we are not going to use it
rm(qog_excel)



#reading csv file into R
# data about dogs in Zurich in 2017, downloaded from Kaggle https://www.kaggle.com/kmader/dogs-of-zurich
setwd("~/Course Materials/Week 2 - Introduction to R")

df <- read.csv("ZurichDogs2017.csv", stringsAsFactors = FALSE)



# So, how does our dataframe look like?
str(df)

# Top 6 observations
head(df)

# if you want to set how many rows to see, just specify it directly.
head(df, 3)

# let's check the end of our data
tail(df)

#overview of the data
summary(df)

# Variable names
names(df)
# ï..HALTER_ID - owner id
# ALTER - owner's age
# GESCHLECHT - owner's sex
# STADTKREIS - city region
# STADTQUARTIER - city district
# RASSE1 - dog's breed
# RASSENTYP - ?
# GEBURTSJAHR_HUND - the dog's birthyear
# GESCHLECHT_HUND - dog's sex
# HUNDEFARBE - dog's color


#we are not really interested in RASSENTYP, because we have not really figured out what it is
df$RASSENTYP<-NULL



#ok, all our variable names are capslock, that's not very convenient, let's tranform them
library(stringr)
colnames(df)<-tolower(colnames(df))

#let's save our dataframe, now without the RASSENTYP and with transformed column names
write.csv(df, "ZurichDogs2017_transformed.csv")

#let's take a look at the unique breeds in our dataset
unique(df$rasse1)

# Excercise:
# How do we know HOW MANY unique observations there are?



## Basic data filtering
# Let's choose only the observations for the dogs born after 2012
df_2012 <- df[df$geburtsjahr_hund > 2012,]
head(df_2012)

#and now only black dogs
df_black <- df[df$hundefarbe == "schwarz",]
head(df_black)

# Let's get both - born after 2012 AND black
df_both <- df[df$geburtsjahr_hund > 2012 & df$hundefarbe == "schwarz",]
nrow(df_both)

#and now either - born after 2012 OR black 
df_either <- df[df$geburtsjahr_hund > 2012 | df$hundefarbe == "schwarz",]
nrow(df_either)


