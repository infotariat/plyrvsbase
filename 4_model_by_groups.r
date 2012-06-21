# Returned objects can be more complex than vectors, lists and data.frames, too.
# Model objects are a good example.  Most modeling functions return relatively
# complex objects.  Storing them in a list makes it a breeze to apply a function
# across all of your models.
# Whether this is good statistical practice is left to the reader...


# Strings ain't factors
options(stringsAsFactors = FALSE)

library(plyr)
library(rbenchmark) 


# The built-in esoph dataset is a bit easier to work with for this part

# lapply
base.lap <- lapply(split(esoph, f = esoph$agegp), 
                   FUN = glm, 
                         formula = cbind(ncases, ncontrols) ~ alcgp, 
                         family = binomial
)

# by
base.by <- by(esoph, 
              INDICES  = esoph$agegp, 
              FUN = glm, 
                    formula = cbind(ncases, ncontrols) ~ alcgp, 
                    family = binomial
)


# plyr
plyr.list <- dlply(.data = esoph,
                   .var = "agegp",
                   .fun = glm, 
                          formula = cbind(ncases, ncontrols) ~ alcgp, 
                          family = binomial
)


# Lists are nice for comparing many objects of the same type
# Summarizing the models
lapply(plyr.list, summary)

# ldply won't work here - the summary() return is too complex to fit easily 
# into a data.frame
ldply(plyr.list, summary) 

# llply is fine, though
llply(plyr.list, summary)

# Getting model AICs
lapply(plyr.list, AIC) # a list
sapply(plyr.list, AIC) # a vector
ldply(plyr.list, AIC) # a data.frame

# Getting a nice data.frame of the model coefficients
do.call(rbind, lapply(plyr.list, coef))
ldply(plyr.list, coef)


# Time it
benchmark(
    base.lap = lapply(split(esoph, f = esoph$agegp), 
                      FUN = glm, 
                            formula = cbind(ncases, ncontrols) ~ alcgp, 
                            family = binomial),

    base.by = by(esoph, 
                 INDICES  = esoph$agegp, 
                 FUN = glm, 
                       formula = cbind(ncases, ncontrols) ~ alcgp, 
                       family = binomial),

    plyr.list = dlply(.data = esoph,
                      .var = "agegp",
                      .fun = glm, 
                             formula = cbind(ncases, ncontrols) ~ alcgp, 
                             family = binomial),

          columns = c("test", "replications", "elapsed", "relative"),
          order = NULL
)


rm(list = ls())
