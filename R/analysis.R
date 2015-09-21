library(ggplot2)
library(MASS)
library(grid)
library(gridExtra)
library(reshape2)

chifig.3colours <- c("#e41a1c", "#377eb8", "#4daf4a")
chifig.2colours <- c("#984ea3", "#ff7f00")
chifig.5colours <- c("#e41a1c", "#377eb8", "#4daf4a", "#984ea3", "#ff7f00")
## time,filename,number_performers,performance_context,performance_type,instruments,notes,video_location,flux,number_performers,length_seconds,entropy,filename
#raw.performance.data <- read.csv("../metatone-performance-data-stochasticmatrices.csv")
raw.performance.data <- read.csv("../metatone-performance-data-normalmatrices.csv")
#raw.performance.data <- read.csv("../metatone-performance-data.csv")
raw.performance.data$time <- strptime(as.character(raw.performance.data$time), "%Y-%m-%d %H:%M:%S.%OS")
valid.sessions <- subset(raw.performance.data, performance_type %in% c("composition","improvisation"))
flux.entropy.ratings <- read.csv("../flux_entropy_ratings.csv")
#summary(raw.performance.data)
summary(valid.sessions)
## rehearsals/performances/studies only
perf.sessions <- subset(raw.performance.data, performance_context %in% c("rehearsal", "performance", "study"))
perf.sessions <- subset(perf.sessions, performance_type %in% c("composition","improvisation"))
summary(perf.sessions$performance_type) # Composition: 23 - Improvisation: 72
summary(perf.sessions)

format.seconds <- function(seconds){
return(paste(seconds %/% 3600, "H", (seconds %% 3600) %/% 60, "M", signif(seconds %% 60, 4), "S", sep = ""))
}
                                        # length data - total min median max
lengths <- perf.sessions$length_seconds
message(paste("Length",format.seconds(sum(lengths)),format.seconds(min(lengths)),format.seconds(median(lengths)),format.seconds(max(lengths)),sep = " & "))
message(paste("Participants",sum(perf.sessions$number_performers),min(perf.sessions$number_performers),median(perf.sessions$number_performers),max(perf.sessions$number_performers),sep = " & "))
message(paste("Flux", " " ,signif(min(valid.sessions$flux),4),signif(median(valid.sessions$flux),4),signif(max(valid.sessions$flux),4),sep = " & "))
message(paste("Entropy", " " ,signif(min(valid.sessions$entropy),4),signif(median(valid.sessions$entropy),4),signif(max(valid.sessions$entropy),4),sep = " & "))

# New long data frame for initial plots.
valid.sessions.long <- read.csv("../metatone-performance-data-normalmatrices.csv")
valid.sessions.long <- melt(valid.sessions.long,id.vars=c("time","performance_context","performance_type","instruments"),variable.name = "measure",measure.vars = c("flux","entropy"))
valid.sessions.long$time <- strptime(as.character(valid.sessions.long$time), "%Y-%m-%d %H:%M:%S.%OS")
valid.sessions.long <-  subset(valid.sessions.long, performance_type %in% c("composition","improvisation"))
summary(valid.sessions.long)

perf.sessions.long <- read.csv("../metatone-performance-data-normalmatrices.csv")
perf.sessions.long <- subset(perf.sessions.long, performance_context %in% c("rehearsal", "performance", "study"))
perf.sessions.long <- melt(perf.sessions.long,id.vars=c("time","performance_context","performance_type","instruments"),variable.name = "measure",measure.vars = c("flux","entropy"))
perf.sessions.long$time <- strptime(as.character(perf.sessions.long$time), "%Y-%m-%d %H:%M:%S.%OS")
perf.sessions.long <-  subset(perf.sessions.long, performance_type %in% c("composition","improvisation"))
summary(perf.sessions.long)


## Initial Plots
# cut out data_collection
#valid.sessions <- (subset(valid.sessions, performance_context != "data_collection"))
## plots
# Count of Session Data
ggplot(perf.sessions, aes(performance_context)) + geom_bar(aes(fill = performance_type)) + theme(plot.margin=unit(rep(0,4), "cm"), legend.position = "right", legend.box = "vertical") + scale_fill_manual(values=chifig.2colours) + scale_x_discrete("performance context") + scale_y_continuous("no. of sessions")
ggsave("../flux-entropy-paper/figures/sessions-count.pdf", width=5.4, height = 2)
#ggplot(perf.sessions, aes(performance_context)) + geom_bar(aes(fill = performance_type))
# Flux boxplot
#ggplot(valid.sessions, aes(performance_context, flux)) + geom_boxplot(aes(fill = performance_type)) + theme(plot.margin=unit(rep(0,4), "cm"), legend.position = "top", legend.box = "horizontal") + scale_fill_manual(values=chifig.2colours) + scale_x_discrete("performance context")
#quartz.save("../flux-entropy-paper/figures/flux-boxplot.pdf", type = "pdf")
# Entropy boxplot
#ggplot(valid.sessions, aes(performance_context, entropy)) +  geom_boxplot(aes(fill = performance_type))  + theme(plot.margin=unit(rep(0,4), "cm"), legend.position = "top", legend.box = "horizontal") + scale_fill_manual(values=chifig.2colours) + scale_x_discrete("performance context")
#quartz.save("../flux-entropy-paper/figures/entropy-boxplot.pdf", type = "pdf")
# Both Flux and Entropy Boxplot
ggplot(perf.sessions.long, aes(performance_context, value)) + geom_boxplot(aes(fill = performance_type)) + theme(plot.margin=unit(rep(0,4), "cm"), legend.position = "right", legend.box = "vertical") + scale_fill_manual(values=chifig.2colours) + scale_x_discrete("performance context") + scale_y_continuous("measure value") + facet_grid(measure~.,scales="free_y")
ggsave("../flux-entropy-paper/figures/context-flux-entropy-boxplot.pdf",width=5.9,height=3)

ggplot(valid.sessions, aes(performance_context, trace)) + geom_boxplot(aes(fill = performance_type))
ggplot(valid.sessions, aes(performance_context, norm)) + geom_boxplot(aes(fill = performance_type))
ggplot(perf.sessions, aes(performance_context, determinant)) + geom_boxplot(aes(fill = performance_type))
ggplot(valid.sessions, aes(performance_context, number_performers)) + geom_boxplot(aes(fill = performance_type))
ggplot(valid.sessions, aes(performance_context, length_seconds)) + geom_boxplot(aes(fill = performance_type))
# distribution of flux and entropy
ggplot((subset(valid.sessions, performance_context != "data_collection")), aes(flux, entropy)) + geom_point(aes(colour = performance_type, shape = instruments), alpha = 0.8)  + facet_wrap(~performance_context) + theme(plot.margin=unit(rep(0,4), "cm"), legend.position = "right", legend.box = "vertical") + scale_colour_manual(values=chifig.2colours)
quartz.save("../flux-entropy-paper/figures/flux-entropy-distribution.pdf", type = "pdf")
#ggplot(df, aes(flux, 2 ^ entropy)) + geom_point(aes(size = number_performers, colour = performance_type))
#ggplot(df, aes(flux, number_performers)) + geom_point(aes(colour = performance_type))
#ggplot(valid.session, aes(flux, exp(entropy))) + geom_point(aes(size = number_performers, colour = performance_context), alpha = 0.6)
# + facet_wrap(~performance_context)

# Flux through time.
#ggplot(valid.sessions, aes(time, flux)) + geom_point(aes(colour = performance_context,shape = performance_type), alpha = 0.8) + theme(plot.margin=unit(rep(0,4), "cm"), legend.position = "right", legend.box = "vertical") + scale_colour_manual(values=chifig.5colours)
#quartz.save("../flux-entropy-paper/figures/flux-through-time.pdf", type = "pdf")
# Entropy through time.
#ggplot(valid.sessions, aes(time, entropy)) + geom_point(aes(colour = performance_context,shape = performance_type), alpha = 0.8) + theme(plot.margin=unit(rep(0,4), "cm"), legend.position = "right", legend.box = "vertical") + scale_colour_manual(values=chifig.5colours)
#quartz.save("../flux-entropy-paper/figures/entropy-through-time.pdf", type = "pdf")
                                        # Flux and Entropy through time.
ggplot(perf.sessions.long, aes(time, value)) + geom_point(aes(colour = performance_context,shape = performance_type), alpha = 0.8) + theme(plot.margin=unit(rep(0,4), "cm"), legend.position = "right", legend.box = "vertical") + scale_colour_manual(values=chifig.5colours) + labs(x="", y="measure value") +  facet_grid(measure~.,scales="free_y")
ggsave("../flux-entropy-paper/figures/flux-entropy-through-time.pdf", width=6,height=3.2)


## stats
## Question: Do Performance Type and Context have a significant effect on Flux and Entropy?
summary(aov(flux~performance_context*performance_type*instruments, perf.sessions))
summary(aov(entropy~performance_context*performance_type*instruments, perf.sessions))
summary(aov(norm~performance_context*performance_type*instruments, perf.sessions))
summary(aov(determinant~performance_context*performance_type*instruments, perf.sessions))
summary(aov(trace~performance_context*performance_type*instruments, perf.sessions))

summary(aov(length_seconds~performance_context*performance_type*instruments, perf.sessions))
summary(aov(number_performers~performance_context*performance_type*instruments, perf.sessions))

                                        # yes! this is a result.
# performance_type and performance_type:instruments both have significant effects
summary(aov(flux~performance_context*performance_type*instruments, valid.sessions))
summary(aov(entropy~performance_context*performance_type*instruments, valid.sessions))
# entropy has another main effect for performance_context!
summary(aov(entropy~performance_context, valid.sessions))

# worst plot ever.
#ggplot(perf.sessions, aes(performance_context, flux, colour = performance_type, shape = instruments, fill = instruments)) + geom_violin()+ geom_boxplot() + geom_point(alpha = 0.5, position = position_jitter(w = 0.1, h = 0))  + scale_fill_manual(values = chifig.3colours) +scale_color_manual(values = chifig.2colours) + stat_summary(fun.data = "mean_cl_boot", position=position_jitter(w = 0.2, h=0))

# Potential POLR stuff.
flux.entropy.ratings <- read.csv("../flux_entropy_ratings.csv")
head(flux.entropy.ratings)
summary(aov(rating ~ flux, data = flux.entropy.ratings))
summary(aov(rating ~ entropy, data = flux.entropy.ratings))
mod <- polr(factor(rating) ~ flux, data = flux.entropy.ratings)
## get a p-value. this is filthy, but MM said it was ok.  so blame him.
message(paste("($t = ", format(summary(mod)$coefficients[1,3], digits = 3), ", df = ", format(mod$edf, digits = 3), ", p = ", format(pt(summary(mod)$coefficients[1,3], mod$edf, lower.tail = FALSE), digits = 2), "$)", sep = ""))
ggplot(flux.entropy.ratings, aes(as.factor(rating),flux)) + geom_point() + geom_boxplot()
ggplot(flux.entropy.ratings, aes(flux,rating)) + geom_smooth(method=lm) + geom_point()


#######
## time-window chunking (beginning-middle-end)
#######
library("plyr")
library("stringr")
library("ggplot2")
library("grid")
source("tm.R")

metadata <- read.csv("../metatone-performance-information.csv")[,1:10]
metadata$time <- strptime(as.character(metadata$time), "%Y-%m-%d %H:%M:%S.%OS")
metadata$number_performers <- as.numeric(metadata$number_performers)
metadata$length_seconds <- as.numeric(metadata$length_seconds)
metadata$notes <- as.character(metadata$notes)

process_session <- function(filename, session_df){
    ## assume first column is filename, second is time
    t <- as.numeric(strptime(as.character(session_df$time), "%Y-%m-%d %H:%M:%S"))
    ## normalise the time variable into [0,1]
    session_df$time <- (t-min(t))/(max(t)-min(t))
    melt(cbind(filename, session_df), id.vars = 1:2, variable.name = "musician", value.name = "gesture")
}

df <- ldply(list.files("../data", pattern = "-posthoc-gestures\\.csv$"),
            function(x) {
                filename <- paste("../data/", x, sep = "")
                process_session(x, read.csv(filename))
            })
## get all the column classes right
df$gesture <- ordered(gestures[df$gesture+1], levels = gestures)
## add time-windowed chunk section
df$section <- ordered(c("beginning", "middle", "end"), levels = c("beginning", "middle", "end"))[as.integer(df$time*3)+1]
## return filename to "base" filename
df$filename <- str_replace(df$filename, "-touches-posthoc-gestures.csv", "")

## Transition Matrices
tm <- ddply(df, .(filename, musician, section), calculate.transitions)
## add flux, entropy
tm <- ddply(tm, .(filename, musician, section),
            function(x){
                data.frame(flux = transition.flux(x),
                           entropy = transition.entropy(x))
            })
## average flux/entropy over whole group
tm <- ddply(tm, .(filename, section), summarise, flux = mean(flux), entropy = mean(entropy))
tm <- merge(tm, metadata, by = "filename", all.x = TRUE)
## remove data which doesn't make sense in a  beginning-middle-end sense
tm <- subset(tm, performance_type!="fail")
tm <- subset(tm, performance_context %in% c("performance", "rehearsal", "study"))

improvisation.sections <- subset(tm, performance_type == "improvisation")
composition.sections <- subset(tm, performance_type == "composition")

## Models

# Kruskal Wallis tests on performance type sections.
kruskal.test(improvisation.sections$flux~improvisation.sections$section)
kruskal.test(improvisation.sections$entropy~improvisation.sections$section)
kruskal.test(composition.sections$flux~composition.sections$section)
kruskal.test(composition.sections$entropy~composition.sections$section)

#TukeyHSD(aov(flux~section, data=improvisation.sections))
#TukeyHSD(aov(entropy~section, data=improvisation.sections))
#pairwise.t.test(improvisation.sections$flux,improvisation.sections$section,p.adjust.method="bonferroni")
                                        #pairwise.t.test(improvisation.sections$entropy,improvisation.sections$section,p.adjust.method="bonferroni")

# Considering just performances:
performances <- subset(improvisation.sections,performance_context == "performance")
pairwise.t.test(performances$entropy,performances$section,p.adjust.method="bonferroni")
summary(aov(entropy~section+Error(section/filename),data=performances))
summary(performances)
kruskal.test(performances$entropy~performances$section)
#summary(aov(flux~section + Error(section/filename), data = tm)) 
#TukeyHSD(aov(flux~section + Error(section/filename), data=improvisation.sections))
#pairwise.t.test(improvisation.sections$flux,improvisation.sections$section,p.adjust.method="bonferroni")
#summary(aov(entropy~performance_type*section, tm))
#pairwise.t.test(tm$entropy,tm$section,p.adjust.method="bonferroni")

## plotting
# todo: make long data frames and produce faceted plots.

# Jitter Plots Section x Flux and type
ggplot(tm,aes(section,flux))  + facet_wrap(~performance_type) + geom_jitter(alpha=.5,size=3, position = position_jitter(w = 0.1, h = 0), aes(colour=section)) + scale_colour_manual(values=chifig.3colours) + stat_smooth(aes(group=1),method="lm",size=2) + theme(plot.margin=unit(rep(0,4), "cm"), legend.position = "none", legend.box = "horizontal")
ggsave("../flux-entropy-paper/figures/type-section-flux-lm.pdf")
# Jitter Plots Section x Entropy and type
ggplot(tm,aes(section,entropy))  + facet_wrap(~performance_type) + geom_jitter(alpha=.5,size=3, position = position_jitter(w = 0.1, h = 0), aes(colour=section)) + scale_colour_manual(values=chifig.3colours) + stat_smooth(aes(group=1),method="lm",size=2) + theme(plot.margin=unit(rep(0,4), "cm"), legend.position = "none", legend.box = "horizontal")
ggsave("../flux-entropy-paper/figures/type-section-entropy-lm.pdf")
# Jitter Plots Section x Flux and context
ggplot(improvisation.sections,aes(section,flux))  + facet_wrap(~performance_context) + geom_jitter(alpha=.5,size=3, position = position_jitter(w = 0.1, h = 0), aes(colour=section)) + scale_colour_manual(values=chifig.3colours) + stat_smooth(aes(group=1),method="lm",size=2) + theme(plot.margin=unit(rep(0,4), "cm"), legend.position = "none", legend.box = "horizontal")
ggsave("../flux-entropy-paper/figures/context-section-flux-lm.pdf")
# Jitter Plots Section x Entropy and context
ggplot(improvisation.sections,aes(section,entropy))  + facet_wrap(~performance_context) + geom_jitter(alpha=.5,size=3, position = position_jitter(w = 0.1, h = 0), aes(colour=section)) + scale_colour_manual(values=chifig.3colours) + stat_smooth(aes(group=1),method="lm",size=2) + theme(plot.margin=unit(rep(0,4), "cm"), legend.position = "none", legend.box = "horizontal")
ggsave("../flux-entropy-paper/figures/context-section-entropy-lm.pdf")


# Boxplot of Flux by section and context
ggplot(improvisation.sections, aes(section, flux)) + geom_boxplot(aes(fill=section)) + facet_wrap(~performance_context) + scale_fill_manual(values=chifig.3colours) + theme(plot.margin=unit(rep(0,4), "cm"), legend.position = "none", legend.box = "horizontal")
ggsave("../flux-entropy-paper/figures/context-section-flux.pdf")
# Box plot of Entropy by section and context
ggplot(improvisation.sections, aes(section, entropy)) + geom_boxplot(aes(fill=section)) + facet_wrap(~performance_context) + scale_fill_manual(values=chifig.3colours) + theme(plot.margin=unit(rep(0,4), "cm"), legend.position = "none", legend.box = "horizontal")
ggsave("../flux-entropy-paper/figures/context-section-entropy.pdf")
# Boxplot of Flux by section and type
ggplot(tm, aes(section, flux)) + geom_boxplot(aes(fill=section)) + facet_wrap(~performance_type) + scale_fill_manual(values=chifig.3colours) + theme(plot.margin=unit(rep(0,4), "cm"), legend.position = "none", legend.box = "horizontal")
ggsave("../flux-entropy-paper/figures/type-section-flux.pdf")
# Box plot of Entropy by section and type
ggplot(tm, aes(section, entropy)) + geom_boxplot(aes(fill=section)) + facet_wrap(~performance_type) + scale_fill_manual(values=chifig.3colours) + theme(plot.margin=unit(rep(0,4), "cm"), legend.position = "none", legend.box = "horizontal")
ggsave("../flux-entropy-paper/figures/type-section-entropy.pdf")

## Boxplots for flux and entropy by section.
## faceted by section and measure (flux and entropy)
improvisation.sections.long <- melt(improvisation.sections,id.vars=c("section","performance_context","performance_type","instruments"),variable.name = "measure",measure.vars = c("flux","entropy"))
ggplot(improvisation.sections.long, aes(section, value)) + geom_boxplot(aes(fill=section)) + facet_grid(measure~performance_context, scales="free_y") + scale_fill_manual(values=chifig.3colours) + theme(plot.margin=unit(rep(0,4), "cm"), legend.position = "none", legend.box = "horizontal") + scale_x_discrete("") + scale_y_continuous("measure value")
ggsave("../flux-entropy-paper/figures/context-section-flux-entropy.pdf", width=6, height = 3.6)
tm.long <- melt(tm,id.vars=c("section","performance_context","performance_type","instruments"),variable.name = "measure",measure.vars = c("flux","entropy"))
ggplot(tm.long, aes(section, value)) + geom_boxplot(aes(fill=section)) + facet_grid(measure~performance_type, scales="free_y") + scale_fill_manual(values=chifig.3colours) + theme(plot.margin=unit(rep(0,4), "cm"), legend.position = "none", legend.box = "horizontal") + scale_x_discrete("") + scale_y_continuous("measure value")
ggsave("../flux-entropy-paper/figures/type-section-flux-entropy.pdf", width=6, height = 3.6)
