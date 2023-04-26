# DAL Library
# version 2.1

# depends dal_transform.R

### Balance Dataset

if (!exists("repos_name"))
  repos_name <<- getOption("repos")[1]

setrepos <- function(repos=repos) {
  repos_name <<- repos
}

loadlibrary <- function(packagename)
{
  if (!require(packagename, character.only = TRUE))
  {
    install.packages(packagename, repos=repos_name, dep=TRUE, verbose = FALSE)
    require(packagename, character.only = TRUE)
  }
}

plot.size <-function(width, height) {
  options(repr.plot.width=width, repr.plot.height=height)
}

plot.scatter <- function(series, label_series = "", label_x = "", label_y = "", colors = NULL) {
  grf <- ggplot(data=series, aes(x = x, y = value, colour=variable, group=variable)) + geom_point(size=1)
  if (!is.null(colors)) {
    grf <- grf + scale_color_manual(values=colors)
  }
  grf <- grf + labs(color=label_series)
  grf <- grf + xlab(label_x)
  grf <- grf + ylab(label_y)
  grf <- grf + theme_bw(base_size = 10)
  grf <- grf + theme(panel.grid.major = element_blank()) + theme(panel.grid.minor = element_blank())
  grf <- grf + theme(legend.position = "bottom") + theme(legend.key = element_blank())
  return(grf)
}

plot.points <- function(data, label_x = "", label_y = "", colors = NULL) {
  series <- melt(as.data.frame(data), id.vars = c(1))
  cnames <- colnames(data)[-1]
  colnames(series)[1] <- "x"
  grf <- ggplot(data=series, aes(x = x, y = value, colour=variable, group=variable)) + geom_point(size=1)
  if (!is.null(colors)) {
    grf <- grf + scale_color_manual(values=colors)
  }
  grf <- grf + labs(color=cnames)
  grf <- grf + xlab(label_x)
  grf <- grf + ylab(label_y)
  grf <- grf + theme_bw(base_size = 10)
  grf <- grf + theme(panel.grid.major = element_blank()) + theme(panel.grid.minor = element_blank())
  grf <- grf + theme(legend.title = element_blank()) + theme(legend.position = "bottom") + theme(legend.key = element_blank())
  return(grf)
}

plot.series <- function(data, label_x = "", label_y = "", colors = NULL) {
  series <- melt(as.data.frame(data), id.vars = c(1))
  cnames <- colnames(data)[-1]
  colnames(series)[1] <- "x"
  grf <- ggplot(data=series, aes(x = x, y = value, colour=variable, group=variable)) + geom_point(size=1.5) + geom_line(linewidth=1)
  if (!is.null(colors)) {
    grf <- grf + scale_color_manual(values=colors)
  }
  grf <- grf + labs(color=cnames)
  grf <- grf + xlab(label_x)
  grf <- grf + ylab(label_y)
  grf <- grf + theme_bw(base_size = 10)
  grf <- grf + theme(panel.grid.major = element_blank()) + theme(panel.grid.minor = element_blank())
  grf <- grf + theme(legend.title = element_blank()) + theme(legend.position = "bottom") + theme(legend.key = element_blank())
  return(grf)
}

plot.series_second_axis <- function(data, label_x = "", label_y = "", label_z = "", colors = c("blue", "red")) {
  loadlibrary("scales")

  series <- data[,1:3]
  cnames <- colnames(series)[-1]
  colnames(series) <- c("x", "y", "z")
  a <- range(series$y)
  b <- range(series$z)
  scale_factor <- diff(a)/diff(b)
  series$z <- ((series$z - b[1]) * scale_factor) + a[1]
  trans <- ~ ((. - a[1]) / scale_factor) + b[1]

  if (label_y =="")
    cnames[1] <- label_y
  if (label_z =="")
    cnames[2] <- label_z

  grf <- ggplot(data=series)
  grf <- grf + geom_point(aes(x, y), col=colors[1], size=1.5)
  grf <- grf + geom_point(aes(x, z), col=colors[2], size=1.5)
  if(is.factor(series$x)) {
    grf <- grf + geom_line(aes(as.integer(x), y), col=colors[1], linewidth=1)
    grf <- grf + geom_line(aes(as.integer(x), z), col=colors[2], linewidth=1)
  }
  else {
    grf <- grf + geom_line(aes(x, y), col=colors[1], size=1)
    grf <- grf + geom_line(aes(x, z), col=colors[2], size=1)
  }
  grf <- grf + theme_bw(base_size = 10)
  grf <- grf + labs(color=cnames)
  grf <- grf + xlab(label_x)
  grf <- grf + ylab(cnames[1])
  grf <- grf + scale_y_continuous(sec.axis = sec_axis(trans=trans, name=cnames[2]))
  grf <- grf + theme(panel.grid.major = element_blank()) + theme(panel.grid.minor = element_blank())
  grf <- grf + theme(legend.title = element_blank()) + theme(legend.position = "bottom")
  return(grf)
}

plot.bar <- function(data, label_x = "", label_y = "", colors = NULL, alpha=1) {
  series <- as.data.frame(data)
  if (!is.factor(series[,1]))
    series[,1] <- as.factor(series[,1])
  grf <- ggplot(series, aes_string(x=colnames(series)[1], y=colnames(series)[2]))
  if (!is.null(colors)) {
    grf <- grf + geom_bar(stat = "identity", fill=colors, alpha=alpha)
  }
  else {
    grf <- grf + geom_bar(stat = "identity", alpha=alpha)
  }
  grf <- grf + theme_bw(base_size = 10)
  grf <- grf + theme(panel.grid.minor = element_blank())
  grf <- grf + theme(legend.title = element_blank()) + theme(legend.position = "bottom")
  grf <- grf + xlab(label_x)
  grf <- grf + ylab(label_y)
  return(grf)
}

plot.groupedbar <- function(data, label_x = "", label_y = "", colors = NULL, alpha=1) {
  cnames <- colnames(data)[-1]
  series <- melt(as.data.frame(data), id.vars = c(1))
  colnames(series)[1] <- "x"
  if (!is.factor(series$x))
    series$x <- as.factor(series$x)

  grf <- ggplot(series, aes(x, value, fill=variable))
  grf <- grf + geom_bar(stat = "identity",position = "dodge", alpha=alpha)
  if (!is.null(colors)) {
    grf <- grf + scale_fill_manual(cnames, values = colors)
  }
  grf <- grf + theme_bw(base_size = 10)
  grf <- grf + theme(panel.grid.minor = element_blank())
  grf <- grf + theme(legend.title = element_blank()) + theme(legend.position = "bottom")
  grf <- grf + xlab(label_x)
  grf <- grf + ylab(label_y)
  return(grf)
}

plot.stackedbar <- function(data, label_x = "", label_y = "", colors = NULL, alpha=1) {
  cnames <- colnames(data)[-1]
  series <- melt(as.data.frame(data), id.vars = c(1))
  colnames(series)[1] <- "x"
  if (!is.factor(series$x))
    series$x <- as.factor(series$x)

  grf <- ggplot(series, aes(x=x, y=value, fill=variable)) + geom_bar(stat="identity", colour="white")
  if (!is.null(colors)) {
    grf <- grf + scale_fill_manual(cnames, values = colors)
  }
  grf <- grf + theme_bw(base_size = 10)
  grf <- grf + theme(panel.grid.minor = element_blank())
  grf <- grf + theme(legend.title = element_blank()) + theme(legend.position = "bottom")
  grf <- grf + scale_x_discrete(limits = unique(series$x))
  grf <- grf + xlab(label_x)
  grf <- grf + ylab(label_y)
  return(grf)
}

plot.radar <- function(data, label_x = "", label_y = "", colors = NULL)  {
  series <- as.data.frame(data)
  if (!is.factor(series[,1]))
    series[,1] <- as.factor(series[,1])
  series$group <- 1
  grf <- ggplot(series, aes_string(x=colnames(series)[1], y=colnames(series)[2], group="group"))
  grf <- grf + geom_point(size=2, color=colors)
  grf <- grf + geom_polygon(size = 1, alpha= 0.1, color=colors)
  grf <- grf + theme_light()
  grf <- grf + coord_polar()
  return(grf)
}

plot.lollipop <- function(data, colors, xlabel = "", ylabel = "", size_text=3, size_ball=8, alpha_ball=0.2, min_value=0, max_value_gap=1, flip = TRUE) {
  cnames <- colnames(data)[-1]
  series <- melt(as.data.frame(data), id.vars = c(1))
  colnames(series)[1] <- "x"
  if (!is.factor(series$x))
    series$x <- as.factor(series$x)
  series$value <- round(series$value)

  grf <- ggplot(data=series, aes(x=x, y=value, label=value)) +
    geom_segment(aes(x=x, xend=x, y=min_value, yend=(value-max_value_gap)), color=colors, size=1) +
    geom_text(color="black", size=size_text) +
    geom_point(color=colors, size=size_ball, alpha=alpha_ball) +
    theme_light() +
    theme(
      panel.grid.major.y = element_blank(),
      panel.border = element_blank(),
      axis.ticks.y = element_blank()
    ) +
    ylab(xlabel) + xlab(xlabel)
  if (flip)
    grf <- grf + coord_flip()

  return(grf)
}

plot.pieplot <- function(data, label_x = "", label_y = "", colors = NULL, textcolor="white", bordercolor="black") {
  prepare.pieplot <- function(series) {
    colnames(series) <- c("x", "value")
    if (!is.factor(series$x)) {
      series$x <- as.factor(series$x)
    }

    series$colors <- colors

    series <- series %>%
      arrange(desc(x)) %>%
      mutate(prop = value / sum(series$value) *100) %>%
      mutate(ypos = cumsum(prop)- 0.5*prop) %>%
      mutate(label = paste(round(value / sum(value) * 100, 0), "%"))
    return(series)
  }
  series <- prepare.pieplot(data)

  # Basic piechart
  grf <- ggplot(series, aes(x="", y=prop, fill=x)) + geom_bar(width = 1, stat = "identity", color=bordercolor)
  grf <- grf + theme_minimal(base_size = 10)
  grf <- grf + coord_polar("y", start=0)
  grf <- grf + geom_text(aes(y = ypos, label = label), size=6, color=textcolor)
  if (!is.null(colors))
    grf <- grf + scale_fill_manual(series$x, values = colors)
  grf <- grf + theme(panel.grid.minor = element_blank()) + theme(legend.position = "bottom")
  grf <- grf + xlab(label_x)
  grf <- grf + ylab(label_y)
  grf <- grf + theme(axis.text.x=element_blank(), legend.title = element_blank(), axis.ticks = element_blank(), panel.grid = element_blank())
  return(grf)
}


plot.dotchar <- function(data, colors, colorline = "lightgray", xlabel = "", ylabel = "", sorting="ascending") {
  loadlibrary("ggpubr")
  cnames <- colnames(data)[-1]
  series <- data
  colnames(series)[1] <- "x"
  if (!is.factor(series$x))
    series$x <- as.factor(series$x)
  series <- melt(as.data.frame(series), id.vars = c(1))

  grf <- ggdotchart(series, x = "x", y = "value",
                    color = "variable", size = 3,
                    add = "segment",
                    sorting = sorting,
                    add.params = list(color = colorline, size = 1.5),
                    position = position_dodge(0.3),
                    palette = colors,
                    ggtheme = theme_pubclean(), xlab = xlabel, ylab=ylabel)
  grf <- ggpar(grf,legend.title = "")
  grf <- grf + theme(legend.position = "bottom")
  return(grf)
}

plot.hist <-  function(data, label_x = "", label_y = "", color = 'white', alpha=0.25) {
  cnames <- colnames(data)[1]
  series <- melt(as.data.frame(data))
  series <- series %>% filter(variable %in% cnames)
  tmp <- hist(series$value, plot = FALSE)
  grf <- ggplot(series, aes(x=value))
  grf <- grf + geom_histogram(breaks=tmp$breaks,fill=color, alpha = alpha, colour="black")
  grf <- grf + xlab(label_x)
  grf <- grf + ylab(label_y)
  grf <- grf + theme_bw(base_size = 10)
  grf <- grf + scale_fill_manual(name = cnames, values = color)
  grf <- grf + theme(panel.grid.major = element_blank()) + theme(panel.grid.minor = element_blank()) + theme(legend.position = "bottom")
  return(grf)
}

plot.boxplot <- function(data, label_x = "", label_y = "", colors = NULL, barwith=0.25) {
  cnames <- colnames(data)
  series <- melt(as.data.frame(data))
  grf <- ggplot(aes(y = value, x = variable), data = series)
  if (!is.null(colors)) {
    grf <- grf + geom_boxplot(fill = colors, width=barwith)
  }
  else {
    grf <- grf + geom_boxplot(width=barwith)
  }
  grf <- grf + labs(color=cnames)
  if (!is.null(colors)) {
    grf <- grf + scale_fill_manual(cnames, values = colors)
  }
  grf <- grf + theme_bw(base_size = 10)
  grf <- grf + theme(panel.grid.minor = element_blank()) + theme(legend.position = "bottom")
  grf <- grf + xlab(label_x)
  grf <- grf + ylab(label_y)
  return(grf)
}


plot.boxplot.class <- function(data, class_label, label_x = "", label_y = "", colors = NULL) {
  data <- melt(data, id=class_label)
  colnames(data)[1] <- "x"
  if (!is.factor(data$x))
    data$x <- as.factor(data$x)
  grf <- ggplot(data=data, aes(y = value, x = x))
  if (!is.null(colors)) {
    grf <- grf + geom_boxplot(fill=colors)
  }
  else {
    grf <- grf + geom_boxplot()
  }
  grf <- grf + labs(color=levels(data$x))
  if (!is.null(colors)) {
    grf <- grf + scale_fill_manual(levels(data$x), values = colors)
  }
  grf <- grf + theme_bw(base_size = 10)
  grf <- grf + theme(panel.grid.minor = element_blank()) + theme(legend.position = "bottom")
  grf <- grf + xlab(label_x)
  grf <- grf + ylab(label_y)
  return(grf)
}


plot.density <-  function(data, label_x = "", label_y = "", colors = NULL, bin = NULL, alpha=0.25) {
  grouped <- ncol(data) > 1
  cnames <- colnames(data)
  series <- melt(as.data.frame(data))
  if (grouped) {
    grf <- ggplot(series, aes(x=value,fill=variable))
    if (is.null(bin))
      grf <- grf + geom_density(alpha = alpha)
    else
      grf <- grf + geom_density(binwidth = bin, alpha = alpha)
  }
  else {
    grf <- ggplot(series, aes(x=value))
    if (is.null(bin)) {
      if (!is.null(colors))
        grf <- grf + geom_density(fill=colors, alpha = alpha)
      else
        grf <- grf + geom_density(alpha = alpha)
    }
    else {
      if (!is.null(colors))
        grf <- grf + geom_density(binwidth = bin,fill=colors, alpha = alpha)
      else
        grf <- grf + geom_density(binwidth = bin, alpha = alpha)
    }
  }
  grf <- grf + theme_bw(base_size = 10)
  grf <- grf + xlab(label_x)
  grf <- grf + ylab(label_y)
  if (!is.null(colors))
    grf <- grf + scale_fill_manual(name = cnames, values = colors)
  grf <- grf + theme(panel.grid.major = element_blank()) + theme(panel.grid.minor = element_blank())
  grf <- grf + theme(legend.title = element_blank(), legend.position = "bottom")
  return(grf)
}

plot.density.class <-  function(data, class_label, label_x = "", label_y = "", colors = NULL, bin = NULL, alpha=0.5) {
  data <- melt(data, id=class_label)
  colnames(data)[1] <- "x"
  if (!is.factor(data$x))
    data$x <- as.factor(data$x)
  grf <- ggplot(data=data, aes(x = value, fill = x))
  if (is.null(bin))
    grf <- grf + geom_density(alpha = alpha)
  else
    grf <- grf + geom_density(binwidth = bin, alpha = alpha)
  grf <- grf + theme_bw(base_size = 10)
  grf <- grf + xlab(label_x)
  grf <- grf + ylab(label_y)
  if (!is.null(colors))
    grf <- grf + scale_fill_manual(name = levels(data$x), values = colors)
  grf <- grf + theme(panel.grid.major = element_blank()) + theme(panel.grid.minor = element_blank())
  grf <- grf + theme(legend.title = element_blank(), legend.position = "bottom")
  return(grf)
}

###

plot.correlation <- function(data, colors="") {
  if (colors == "")
    colors <- brewer.pal(n=8, name="RdYlBu")
  loadlibrary("corrplot")
  series <-cor(data)
  corrplot(series, type="upper", order="hclust", col=colors)
}



plot.norm_dist <- function(vect, label_x = "", label_y = "",  colors)  {
  data <- data.frame(value = vect)
  grf <- ggplot(data, aes(sample = value)) +
    stat_qq(color=colors) + xlab(label_x) + ylab(label_y) +
    theme_bw(base_size = 10) +
    stat_qq_line(color=colors)
  return (grf)
}


plot.pair <- function(data, cnames, title = NULL, clabel = NULL, colors) {
  loadlibrary("WVPlots")
  grf <- PairPlot(data, cnames, title, group_var = clabel, palette=NULL) + theme_bw(base_size = 10)
  if (is.null(clabel))
    grf <- grf + geom_point(color=colors)
  else
    grf <- grf + scale_color_manual(values=colors)
  return (grf)
}

plot.pair.adv <- function(data, cnames, title = NULL, clabel= NULL, colors) {
  loadlibrary("GGally")
  if (!is.null(clabel)) {
    data$clabel <- data[,clabel]
    cnames <- c(cnames, 'clabel')
  }

  icol <- match(cnames, colnames(data))
  icol <- icol[!is.na(icol)]

  if (!is.null(clabel)) {
    grf <- ggpairs(data, columns = icol, aes(colour = clabel, alpha = 0.4)) + theme_bw(base_size = 10)

    for(i in 1:grf$nrow) {
      for(j in 1:grf$ncol){
        grf[i,j] <- grf[i,j] +
          scale_fill_manual(values=colors) +
          scale_color_manual(values=colors)
      }
    }
  }
  else {
    grf <- ggpairs(data, columns = icol, aes(colour = colors))  + theme_bw(base_size = 10)
  }
  return(grf)
}
