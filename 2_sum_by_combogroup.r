# Sometimes you want to group by multiple variables - all of these functions
# can do that, but the returned objects start to vary a bit more this way.



# Strings ain't factors
options(stringsAsFactors = FALSE)

library(plyr)
library(rbenchmark) 

# Load in some TB surveillance data
tb <- read.csv("tbdata.csv", na.string = "Suppressed")



################################################################################

# For lapply and sapply, things get a bit uglier;
# split() just pastes the two factors together
base.lap <- lapply(X = split(x = tb$n, f = list(tb$state, tb$origin)),
                   FUN = sum, na.rm = TRUE)

base.sap <- sapply(X = split(x = tb$n, f = list(tb$state, tb$origin)),
                   FUN = sum, na.rm = TRUE)

# ... such that you have to use regex to get state-specific variables
base.lap[grep(names(base.lap), pattern = "Colorado")]
base.sap[grep(names(base.lap), pattern = "Colorado")]

################################################################################

# by is also... peculiar
base.by <- by(data = tb$n, 
              INDICES = list(tb$state, tb$origin),
              FUN = sum, na.rm = TRUE
)

base.by
str(base.by) 
# The grouping factors are in there, 
# but I couldn't figure out how to use them.  The code for print.by suggests
# it isn't exactly easy...
print.by

################################################################################

# aggregate <3
base.agg <- aggregate(formula = n ~ state + origin, 
                      data = tb,
                      FUN = sum)

base.agg
# That's the stuff - a nice data.frame, still-useful grouping vars

subset(base.agg, state %in% "Colorado")

################################################################################

# ddply is similarly nice
plyr.df <- ddply(.data = tb,
                 .var = c("state", "origin"),
                 .fun = summarise,
                 n = sum(n, na.rm = TRUE)
)

subset(plyr.df, state %in% "Colorado")
# BUT!  Includes a zero for the Colorado: Not Reported group

plyr.list <- dlply(.data = tb,
                .var = c("state", "origin"),
                .fun = summarise,
                n = sum(n, na.rm = TRUE)
)

# Lists just aren't the right thing if you want to use the grouping variables
plyr.list[grep(names(plyr.list), pattern = "Colorado")]



rm(list = ls())
