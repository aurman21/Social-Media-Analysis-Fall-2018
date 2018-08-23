#Introduction to R - ggplot2
#Uni Bern, Fall 2018, Social Media Analysis Using R
#tutorial by Andrew Yue Xie, adjusted a bit, from here https://www.kaggle.com/andyxie/beginner-ggplot2-tutorial/notebook

library(ggplot2)
head(diamonds)

#basic plots - based on mtcars dataset included in R by default

mtcars<-mtcars

ggplot(mtcars, aes(x=wt, y=mpg, shape=factor(gear))) + 
  geom_point()

ggplot(mtcars, aes(x=wt, y=mpg, group=factor(gear))) + 
  geom_point()

ggplot(mtcars, aes(x=wt, y=mpg, group=factor(cyl), colour=gear)) + 
  geom_point()

#more beautiful plots

# First plot - diamond dataset included with ggplot2 package
p1 <- ggplot(diamonds, aes(x=carat, y=price, colour=color, group=color)) +
  geom_point(alpha=0.3) +
  ggtitle("Diamonds Price v.s. Carat")

p1

# Second plot - ChickWeight dataset included with ggplot2 package
head(ChickWeight)
chick<-ChickWeight

p2 <- ggplot(ChickWeight, aes(x=Time, y=weight, colour=Diet)) +
  geom_point(alpha=.3) +
  geom_smooth(alpha=.2, size=1) +
  ggtitle("Fitted growth curve per diet")

p2

# Third plot
p3 <- ggplot(subset(ChickWeight, Time==21), aes(x=weight, colour=Diet)) +
  geom_density() +
  ggtitle("Final weight, by diet")

p3

# Fourth plot
p4 <- ggplot(subset(ChickWeight, Time==21), aes(x=weight, fill=Diet)) +
  geom_histogram(colour="black", binwidth=50) +
  facet_grid(Diet ~ .) +
  ggtitle("Final weight, by diet") +
  theme(legend.position="none")        # No legend (redundant in this graph)  

p4

multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}

multiplot(p1, p2, p3, p4, cols=2)


ggplot(mtcars, aes(x=wt, y=mpg, shape=factor(gear))) + 
  geom_point()

ggplot(mtcars, aes(x=wt, y=mpg, group=factor(gear))) + 
  geom_point()
