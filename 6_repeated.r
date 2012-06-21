# split-apply-combine can also be a useful way to deal with repeated measures
# data, especially if you're new to or not using one of the time series data
# structures.


# Strings ain't factors
options(stringsAsFactors = FALSE)


library(plyr)
library(lme4)
library(ggplot2)
library(rbenchmark) # To see who is most fastest


# Using sleepstudy dataset included with the lme4 package
head(sleepstudy)

# For example, if you want to calculate time-to-time differences:
# I do this by subtracting the reaction time vector from itself: slap an NA
# on the front, since the first measure has no previous comparator, then...
# I'm not really sure how to explain how this works better than the code shows.
base.lap <- lapply(split(sleepstudy, f = sleepstudy$Subject), FUN = transform, 
    react.diff = c(NA, Reaction[-1] - Reaction[-length(Reaction)])
)

base.df <- do.call(rbind, base.lap)


plyr.df <- ddply(sleepstudy, .var = "Subject", .fun = mutate,
    react.diff = c(NA, Reaction[-1] - Reaction[-length(Reaction)])
)


# Check 'em out
base.lap[1]
head(base.df, 10)
head(plyr.df, 10)



ggplot(plyr.df, aes(x = Days, y = react.diff, color = Subject)) +
    geom_point() +
    geom_smooth(method = "lm", se = FALSE) +
    opts(title = "Hoooraaay")
