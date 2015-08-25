library(ggplot2)

library(MASS)

## time,filename,number_performers,performance_context,performance_type,instruments,notes,video_location,flux,number_performers,length_seconds,entropy,filename
df <- read.csv("../metatone-performance-data.csv")
df$time <- strptime(as.character(df$time), "%Y-%m-%d %H:%M:%S.%OS")
summary(df)

## rehearsals/performances/studies only
reh.perf.studies.df <- subset(df, performance_context %in% c("rehearsal", "performance", "study"))
reh.perf.studies.df <- subset(reh.perf.studies.df, performance_type %in% c("composition","improvisation"))
summary(reh.perf.studies.df$performance_type)
summary(reh.perf.studies.df)
## plots

ggplot(reh.perf.studies.df, aes(performance_type)) + geom_bar(aes(fill = performance_context))
ggplot(reh.perf.studies.df, aes(performance_type, flux)) + geom_boxplot(aes(fill = performance_context))
ggplot(reh.perf.studies.df, aes(performance_type, entropy)) + geom_boxplot(aes(fill = performance_context))


ggplot(df, aes(flux, entropy)) + geom_point(aes(colour = instruments)) + facet_wrap(~instruments)
ggplot(df, aes(flux, entropy)) + geom_point(aes(size = number_performers, colour = performance_type))
ggplot(df, aes(flux, number_performers)) + geom_point(aes(colour = performance_type))
ggplot(df, aes(flux, exp(entropy))) + geom_point(aes(size = number_performers, colour = performance_context))

+ facet_wrap(~performance_context)
ggplot(df, aes(time, flux)) + geom_point(aes(size = number_performers, colour = performance_type))

## stats

## Question: Do Performance Type and Context have a significant effect on Flux and Entropy?
summary(aov(flux~performance_context*performance_type*instruments, reh.perf.studies.df))
summary(aov(entropy~performance_context*performance_type*instruments, reh.perf.studies.df))

ggplot(reh.perf.studies.df,aes(performance_type,flux)) + geom_boxplot(aes(fill=instr))

ggplot(reh.perf.studies.df,aes(performance_type,flux)) + geom_boxplot()

+ geom_boxplot(aes(fill=performance_context))


ggplot(reh.perf.studies.df,aes(performance_type,entropy)) + geom_boxplot() + geom_point()
ggplot(reh.perf.studies.df,aes(performance_type,flux)) + geom_boxplot() + geom_point()

ggplot(reh.perf.studies.df, aes(performance_context, flux)) + geom_boxplot()
ggplot(reh.perf.studies.df, aes(performance_context, entropy)) + geom_boxplot()

ggplot(reh.perf.studies.df, aes(instruments, flux)) + geom_boxplot()
ggplot(reh.perf.studies.df, aes(instruments, entropy)) + geom_boxplot()

library("AER")
flux.entropy.ratings <- read.csv("../flux_entropy_ratings.csv")
flux.entropy.ratings

summary(aov(rating ~ flux, data = flux.entropy.ratings))
summary(aov(rating ~ entropy, data = flux.entropy.ratings))
mod <- polr(response ~ entropy, data = subset(stats.of.df, question=="Q3"))

## get a p-value. this is filthy, but MM said it was ok.  so blame him.
message(paste("($t = ", format(summary(mod)$coefficients[1,3], digits = 3), ", df = ", format(mod$edf, digits = 3), ", p = ", format(pt(summary(mod)$coefficients[1,3], mod$edf, lower.tail = FALSE), digits = 2), "$)", sep = ""))

ggplot(flux.entropy.ratings, aes(as.factor(rating),flux)) + geom_point() + geom_boxplot()
ggplot(flux.entropy.ratings, aes(flux,rating)) + geom_smooth(method=lm)

## time-window chunking (beginning-middle-end)

library("plyr")
library("reshape2")

filenames <- llply(list.files("../data"),
                  function(x) c(x, names(read.csv(paste("../data/", x, sep = "")))))

process_session <- function(filename, session_df){
    ## assume first column is filename, second is time
    t <- as.numeric(strptime(as.character(session_df$time), "%Y-%m-%d %H:%M:%S"))
    ## normalise the time variable into [0,1]
    session_df$time <- (t-min(t))/(max(t)-min(t))
    melt(cbind(filename, session_df), id.vars = 1:2, variable.name = "musician", value.name = "gesture")
}

df <- ldply(list.files("../data"),
            function(x) {
                filename <- paste("../data/", x, sep = "")
                process_session(x, read.csv(filename))
            })
## get all the column classes right
df$gesture <- factor(df$gesture)
## add time-windowed chunk section
df$section <- ordered(c("beginning", "middle", "end"), levels = c("beginning", "middle", "end"))[as.integer(df$time*3)+1]
