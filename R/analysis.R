library(dplyr)
library(ggplot2)

## time,filename,number_performers,performance_context,performance_type,instruments,notes,video_location,flux,number_performers,length_seconds,entropy,filename
df <- read.csv("../metatone-performance-data.csv")
df$time <- strptime(as.character(df$time), "%Y-%m-%d %H:%M:%S.%OS")
## rehearsals/performances only
reh.perf.df <- subset(df, performance_context %in% c("rehearsal", "performance", "study"))

summary(reh.perf.df$performance_type)

## plots

ggplot(reh.perf.df, aes(performance_type)) + geom_bar(aes(fill = performance_context))

ggplot(reh.perf.df, aes(performance_type, flux)) + geom_boxplot(aes(fill = performance_context))

ggplot(reh.perf.df, aes(performance_type, entropy)) + geom_boxplot(aes(fill = performance_context))

ggplot(df, aes(performance_context, flux)) + geom_boxplot()

ggplot(df, aes(flux, entropy)) + geom_point(aes(size = number_performers, colour = performance_type))

ggplot(df, aes(flux, number_performers)) + geom_point(aes(colour = performance_type))

ggplot(df, aes(flux, entropy)) + geom_point(aes(size = number_performers, colour = performance_type)) + facet_wrap(~performance_context)

ggplot(df, aes(time, flux)) + geom_point(aes(size = number_performers, colour = performance_type))

## stats

aov(flux~performance_context*performance_type, reh.perf.df)
aov(entropy~performance_context*performance_type, reh.perf.df)
