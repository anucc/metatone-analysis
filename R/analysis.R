library(dplyr)
library(ggplot2)
library(polr)

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
