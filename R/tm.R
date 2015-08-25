gestures <- c("N", # 0: Nothing
              "FT", # 1: Fast Taps
              "ST", # 2: Slow Taps
              "FS", # 3: Fast Swipes
              "FSA", # 4: Fast Swipes Accelerating
              "VSS", # 5: Very Slow Swirl
              "BS", # 6: Big Swirl
              "SS", # 7: Small Swirl
              "C" # 8: Combination of Swirl and Taps
              )

jumble.df <- function(df, cols.to.jumble){
    if(is.numeric(cols.to.jumble) && (TRUE %in% (cols.to.jumble < 0)))
        cols.to.jumble <- (1:dim(df)[2])[cols.to.jumble]
    for(c in cols.to.jumble){
        df[,c] <- df[sample.int(dim(df)[1]),c]
    }
    df
}

## transition matrices

## assumes single session-artist df
calculate.transitions <- function(df, left.stochastic=FALSE){
    if(dim(df)[1]<2)
        return(data.frame())
    trans <- data.frame(from = df$gesture[-length(df$gesture)],
                        to= df$gesture[-1])
    if(left.stochastic)
        res <- ddply(trans, .(from), function(x) ddply(x, .(to), function(y) data.frame(prob = length(y$to)/length(x$from))))
    else
        res <- ddply(trans, .(from), function(x) ddply(x, .(to), function(y) data.frame(prob = length(y$to)/length(trans$from))))
    data.frame(time = min(df$time), res)
}

## ## add together (and renormalise) TMs from different musicians
## group.transitions <- function(df){
##     ddply(df,
##           .(session, app, agent, time, from, to),
##           summarize,
##           blah...)
## }

transition.flux <- function(df){
    if(sum(df$prob)!=1)
        message("warning: prob sum isn't 1")
    on.diag.sum <- sum(df[df$from==df$to, "prob"])
    data.frame(flux = 1-on.diag.sum)
}

transition.entropy <- function(df){
    data.frame(entropy = -sum(df$prob*log2(df$prob)))
}

quantize.times <- function(time, delta.t){
    delta.t * (time %/% delta.t)
}

timeslice.df <- function(df, delta.t){
    mutate(df, time = quantize.times(time, delta.t))
}

timesliced.transitions <- function(df, delta.t){
    ddply(timeslice.df(df, delta.t),
          .(session, app, agent, musician, time),
          calculate.transitions,
          .progress = "text")
}

## flux.variance <- function(df){
##     res <- ddply(df,
##                  .(session, app, agent, musician, time),
##                  transition.flux)
##     ddply(res,
##           .(session, app, agent),
##           summarize,
##           flux.mean = mean(flux),
##           ## flux.median = median(flux),
##           flux.variance = sd(flux)
##           ## flux.mad = mad(flux)
##           )
## }

flux.variance <- function(df){
    ddply(df,
          .(session, app, agent, musician, time),
          transition.flux)
}

## entropy.variance <- function(df){
##     res <- ddply(df,
##                  .(session, app, agent, musician, time),
##                  transition.entropy)
##     ddply(res,
##           .(session, app, agent),
##           summarize,
##           entropy.mean = mean(entropy),
##           ## entropy.median = median(entropy),
##           entropy.variance = sd(entropy)
##           ## entropy.mad = mad(entropy)
##           )
## }

entropy.variance <- function(df){
    ddply(df,
          .(session, app, agent, musician, time),
          transition.entropy)
}

collapse.musicians <- function(df, collapse.function){
    ddply(df,
          intersect(c("session", "app", "agent", "time"), names(df)),
          numcolwise(collapse.function))
}

## plotting functions

plot.tm.heatmap <- function(df, colour.by, title = ""){
    ggplot(df, aes(y = from, x = to)) +
        geom_tile(aes_string(alpha = "prob", fill = colour.by)) +
            ## scale_fill_manual(values = c("blue", "darkgreen", "red")) +
                ## scale_fill_gradient(limits=fill.limits, low="#000080", high="#CD6600") +
                scale_x_discrete(drop = FALSE, limits = gestures) +
                    scale_y_discrete(drop = FALSE, limits = gestures) +
                        scale_alpha_continuous(limits = c(0,.5)) + # try 1 as well
                            coord_fixed() +
                                labs(title = title,
                                     x = "final state",
                                     y = "initial state",
                                     alpha = "transition\nprobability") +
                                         theme(axis.text.x = element_text(angle=90))
}

## ## jumbled data for sanity checks
## mtdfj <- mtdf
## mtdfj$gesture <- factor(sample(levels(mtdf$gesture), dim(mtdfj)[1], TRUE))

## CHI figures for publication

## taken from colorbrewer2.org
chifig.3colours <- c("#e41a1c", "#377eb8", "#4daf4a")
chifig.2colours <- c("#984ea3", "#ff7f00")
