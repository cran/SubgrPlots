% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/09-stepp-plot-function.r
\name{plot_stepp}
\alias{plot_stepp}
\title{STEPP for subgroup effect size}
\usage{
plot_stepp(
  dat,
  covari.sel,
  trt.sel,
  resp.sel,
  outcome.type,
  setup.ss,
  alpha,
  font.size = c(1.2, 1, 1, 0.85),
  title = NULL,
  lab.y = NULL,
  subtitle = NULL
)
}
\arguments{
\item{dat}{a data set}

\item{covari.sel}{a vector of indices of the two covariates}

\item{trt.sel}{a variate index specifying the treatment code}

\item{resp.sel}{a variate index specifying the response variable}

\item{outcome.type}{a string specifying the type of the response variable, it can be "continuous", or "binary" or  "survival".}

\item{setup.ss}{a vector specifying the approximate overlap size (N2) and subgroup sample size (N1).}

\item{alpha}{the type I error rate}

\item{font.size}{a vector specifying the size of labels and text; the first element is for main titles, the second is for
for x-axis and y-axis labels; the thrid is for the text in the legend; the fourth is for the subtitle.}

\item{title}{a string specifying the main title.}

\item{lab.y}{a string specifying the labels of the y-axis.}

\item{subtitle}{strings specifying the subtitle}
}
\description{
this function produces a plot of using the approach "Subpopulation Treatment Effect Pattern Plot". It shows the treatment effect
size of subgroups, where subgruops are defined by certain ranges of a continuous covariate; each subgroup has a sample size close
to a pre-specified value (N2) and any neighboring subgroups have an overlap size near another pre-specified value (N1). The plot
shows the 95% mariginal C.I. for each subgroup, the 95% simultaneous C.I. for all subgroups and the overall effect (represented by
a horizontal line). The y-coordinate of a point indicates the effect size within the corresponding subgroup; the x-coordinate shows
the lower bound of the range which defines the subgroup. If part of the horizontal line is out of the simultaneous C.I., it may
reveal hetergeneity across subgroup effects with repective to the overall effect. In addition, one can control the width of the C.I.
by controlling Type I error rate in one of the function arguments. Note that the function uses log odd ratio and log hazard ratio
for displaying subgroup effect sizes in binary and survival data, respectively. The actual subgroup sample sizes over the covariate
are shown on the console window as well.
}
\details{
Contrary to \code{\link{ggplot_stepp}}, \code{plot_stepp} implements an x-axis where each midpoint of the subgroups is drawn equidistant.
}
\examples{
# Load the data to be used
data(prca)
dat <- prca

## 9. stepp Plot -----------------------------------------------------------
lab.y.title = paste("Treatment effect size (log-hazard ratio)");
setup.ss = c(30,40)
sub.title = paste0("(Subgroup sample sizes are set to ", setup.ss[2],
                   "; overlap sizes are set to ", setup.ss[1], ")" )
plot_stepp(dat,
           covari.sel = 8,
           trt.sel = 3,
           resp.sel = c(1, 2),
           outcome.type = "survival",
           setup.ss = c(30,40),
           alpha = 0.05,
           font.size = c(0.9, 1, 1, 1),
           title = NULL,
           lab.y = lab.y.title,
           subtitle = sub.title)

}
\seealso{
\code{\link{ggplot_stepp}}
}
