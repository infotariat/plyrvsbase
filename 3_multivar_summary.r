# We often want to aggregate more than one variable per group - that's easily
# done.  Switching to a custom function actually grants a bit more control over
# what the functions return (though the returned objects are still going to be
# in lists pretty often



# Strings ain't factors
options(stringsAsFactors = FALSE)

library(plyr)
library(rbenchmark) 

# Load in some TB surveillance data
tb <- read.csv("tbdata.csv", na.string = "Suppressed")

# Convert these columns to numerics
tb$n.tx.comp.12mo <- as.numeric(tb$n.tx.comp.12mo)
tb$n.elig.tx.comp.12mo <- as.numeric(tb$n.elig.tx.comp.12mo)


# Sometimes, you want to do some really heavy-duty aggregation, with basically
# arbitrary aggregation functions

################################################################################

# Past a certain point of complexity, it's easier to define a function to pass
# than to use anonymous functions
aggfun <- function(x){data.frame( 
    total.cases = sum(x$n, na.rm = TRUE),
    n.forborn = sum(x$n[x$origin %in% "Foreign - Born"], na.rm = TRUE),
    prop.forborn = sum(x$n[x$origin %in% "Foreign - Born"], na.rm = TRUE) / 
                   sum(x$n, na.rm = TRUE),
    n.hiv.pos = sum(x$n[x$hiv %in% "Positive"], na.rm = TRUE),
    prop.hiv.pos = sum(x$n[x$hiv %in% "Positive"], na.rm = TRUE) / 
                   sum(x$n, na.rm = TRUE),
    prop.tx.comp.12mo = sum(x$n.tx.comp.12mo, na.rm = TRUE) / 
                        sum(x$n.elig.tx.comp.12mo, na.rm = TRUE)
    )
}


################################################################################

# lapply and sapply
# Note that aggfun is passed just as sum was
base.lap <- lapply(split(tb, f = tb$state), FUN = aggfun)
base.sap <- sapply(split(tb, f = tb$state), FUN = aggfun)

# Because aggfun builds a data.frame, lapply returns a list of one-row 
# data.frames. That's pretty easy to convert into one data.frame:
base.lap
do.call(what = rbind, args = base.lap)


# sapply simplifies into a data.frame automatically - but it's transposed 
# from the one that do.call() creates
base.sap


################################################################################

base.by <- by(data = tb, 
   INDICES = tb$state,
   FUN = aggfun
)

# That weird by object again
base.by

# Also easier as a data.frame
do.call(what = rbind, args = base.by)

################################################################################

# aggregate - I couldn't get this to work! Members at the meetup suggested
# that I'd need to write a different aggfun
# base.agg <- aggregate(. ~ state,
                      # data = tb,
                      # FUN = aggfun)

################################################################################

# plyr - just the ddply, you know what dlply does by now
# This is where summarise begins to make sense - you can pass arbitrary
# named arguments and get those back as summary measures.
# ddply() could take aggfun, as well, but this is how I typically 
# do these things
plyr.df <- ddply(.data = tb, .var = "state", .fun = summarise,
    total.cases = sum(n, na.rm = TRUE),
    n.forborn = sum(n[origin %in% "Foreign - Born"], na.rm = TRUE),
    prop.forborn = sum(n[origin %in% "Foreign - Born"], na.rm = TRUE) / 
                   sum(n, na.rm = TRUE),
    n.hiv.pos = sum(n[hiv %in% "Positive"], na.rm = TRUE),
    prop.hiv.pos = sum(n[hiv %in% "Positive"], na.rm = TRUE) / 
                   sum(n, na.rm = TRUE),
    prop.tx.comp.12mo = sum(n.tx.comp.12mo, na.rm = TRUE) / 
                        sum(n.elig.tx.comp.12mo, na.rm = TRUE)
)


# Time it
benchmark(
    base.lap = lapply(split(tb, f = tb$state), FUN = aggfun),

    base.sap = sapply(split(tb, f = tb$state), FUN = aggfun),

    base.by = by(data = tb, 
       INDICES = tb$state,
       FUN = aggfun),

    plyr.df = ddply(.data = tb, .var = "state", .fun = summarise,
        total.cases = sum(n, na.rm = TRUE),
        n.forborn = sum(n[origin %in% "Foreign - Born"], na.rm = TRUE),
        prop.forborn = sum(n[origin %in% "Foreign - Born"], na.rm = TRUE) / 
                       sum(n, na.rm = TRUE),
        n.hiv.pos = sum(n[hiv %in% "Positive"], na.rm = TRUE),
        prop.hiv.pos = sum(n[hiv %in% "Positive"], na.rm = TRUE) / 
                       sum(n, na.rm = TRUE),
        prop.tx.comp.12mo = sum(n.tx.comp.12mo, na.rm = TRUE) / 
                            sum(n.elig.tx.comp.12mo, na.rm = TRUE)),

          columns = c("test", "replications", "elapsed", "relative"),
          order = NULL
)


rm(list = ls())
