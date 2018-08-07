# Introduction to R - additional part (data cleaning with dplyr)
# University of Bern, Fall 2018
# Aleksandra Urman
# some parts/ideas on the structure of the code were borrowed from Alexey Knorre's R crash course https://github.com/alexeyknorre/R_crash_course

#in the main part of the lecture we looked at basic data cleaning
#this part is an extension
#it shows different ways of data cleaning using "dplyr" package

#load out transformed training dataset on Zurich dogs
df <- read.csv("ZurichDogs2017_transformed.csv", stringsAsFactors = FALSE)


#install the package (if you have not done so yet)
install.packages("dplyr")


# load the package
library(dplyr)

# filter: finding observations that satisfy a certain condition
df_2005 <- filter(df, geburtsjahr_hund > 2005)
head(df_2005)

# select: selecting only certain variables (columns)
dplyr_sel <- select(df, rasse1, hundefarbe)
head(dplyr_sel)

# mutate: creating new variables out of old ones

df_newcolumn <- mutate(df, jahr = (2018-geburtsjahr_hund))

# arrange: sorting by a certain variable
# sorting by the age of dogs, ascending
df_arrange <- arrange(df_newcolumn, jahr)

# sorting by the age of dogs, descending
df_arrange <- arrange(df_newcolumn, desc(jahr))

# sorting by the age of dogs, descending, and then by the age of owner
df_arrange <- arrange(df_newcolumn, desc(jahr), desc(alter))

# recode: recoding the data
df_recode <- df
unique(df_recode$hundefarbe)

df_recode$hundefarbe <- recode(df$hundefarbe,
                                 "schwarz"="black",
                                 "weiss" = "white",
                                 "braun" = "brown")
unique(df_recode$hundefarbe)
head(df_recode)


