


# Strings ain't factors
options(stringsAsFactors = FALSE)

# Load in some TB surveillance data
tb <- read.csv("tbdata.csv", na.string = "Suppressed")

# Set up a directory for output to keep things tidy
dir.create("outdir")

# Write some csv files out.  Note that I'm not assigning this to anything,
# and it just returns NULL
d_ply(tb, 
      .var = "state", 
      .fun = function(x)  # an anonymous function - could be more complex
      write.csv(x, 
                file = file.path("outdir", paste(x$state[1], ".csv", sep = "")),
                row.names = FALSE)
)


# Read back in - first, get a list of the filepaths
# full.names = TRUE ensures that you get the actual path of the file,
# not just its name
statefiles <- list.files(path = "outdir", full.names = TRUE)

# In base, you've got to use do.call() to get to a data.frame
tb.baselist <- lapply(statefiles, read.csv)
tb.basedf <- do.call(rbind, tb.baselist)

# plyr style
tb.plyrdf <- ldply(statefiles, read.csv)


benchmark(
    base.list = lapply(statefiles, read.csv),
    base.df = do.call(rbind, lapply(statefiles, read.csv)),
    plyr.df = ldply(statefiles, read.csv),

    columns = c("test", "replications", "elapsed", "relative"),
    order = NULL
)
