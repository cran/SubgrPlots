## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)


## ----eval=FALSE, include=TRUE--------------------------------------------
#  install.packages("SubgrPlots")

## ----eval=FALSE, include=TRUE--------------------------------------------
#  ## For dev version  needs devtools package
#  # install.packages("devtools")
#  devtools::install_github("nicoballarini/SubgrPlots")

## ---- fig.show='hold', out.width="50%", fig.width=5, fig.height=5, cache=TRUE----
# Loads the SubgrPlots package available as supplementary material from the 
# manuscript website. Install it first!!
library(SubgrPlots) 
library(dplyr) # For some data wrangling
# Load the dataset to be used
data(prca)
head(prca)

## ---- fig.show='hold', fig.align = "center", out.width="100%", fig.width=10, fig.height=6, cache=TRUE----
dat = prca
dat = dat %>%
  mutate(bm = factor(ifelse(bm == 0 , "No", "Yes")),
         hx = factor(ifelse(hx == 0 , "No", "Yes")))

## Figure 1. Forest Plot ------------------------------------------------------
main.title = list("", "Forest plot of subgroups",
                  "Kaplan-Meier curves\n by treatment group")
label.x = list("", "Log hazard ratio",
               "Time (days)")
plot_forest(dat,
            covari.sel = c(4, 5, 6, 7),
            trt.sel = 3,
            resp.sel = c(1, 2),
            outcome.type = "survival",
            size.shape = c(0.3, 6.5 / 4),
            font.size = c(1, 1, 1, .8),
            title = main.title,
            lab.x = label.x, time = 50, KM = TRUE,
            show.km.axis = TRUE,
            n.brk = 6, max.time = 70,
            widths = c(2, 1.5, 1))

## ---- fig.show='hold', fig.align = "center", out.width="75%", fig.width=6, fig.height=5, cache=TRUE----
library(UpSetR) # We use the UpSetR package for drawing the original upset plot
dat = prca
# We need the dataset in the upset format.
# First variable is treatment to be a labelled factor 
# Then all subgroup defining covariates.
# And finally, the response variable
prca.upset = data.frame(trt = factor(ifelse(prca$rx == 1, "Experimental", "Control")),
                        bm = 1 * (prca$bm == 1),
                        pf = 1 * (prca$pf == 1),
                        hx = 1 * (prca$hx == 1),
                        stage = 1 * (prca$stage == 4),
                        survtime = prca$survtime,
                        cens = prca$cens == 1)

## Figure 2. UpSet ------------------------------------------------------------
# Create a custom query to operate on the rows of the data and display colors by treatments
Myfunc = function(row, param1, param2) {
  data = (row["trt"] %in% c(param1, param2))
}
pal = c("#1f78b4", "#a6cee3")
upset(prca.upset,
      order.by = "freq",
      sets = c("bm",'pf',"hx",'stage'),
      nintersects = 14,
      text.scale = 1.4,
      queries = list(list(query = Myfunc,
                          params = c("Control", "Experimental"),
                          color = pal[2],
                          active = T,
                          query.name = "Control"),
                     list(query = Myfunc,
                          params = c("Experimental", "Experimental"),
                          color = pal[1],
                          active = T,
                          query.name = "Experimental")),
      query.legend = "top")

## ---- fig.show='hold', fig.align = "center", out.width="95%", fig.width=8, fig.height=8, cache=TRUE----
dat = prca
## Figure 3. SubgroUpSet -----------------------------------------------------
# We need the dataset in the upset format.
# First variable is treatment to be a labelled factor 
# Then all subgroup defining covariates.
# And finally, the response variable
dat = data.frame(trt = factor(ifelse(prca$rx == 1, "Experimental", "Control")),
                 bm = 1 * (prca$bm == 1),
                 pf = 1 * (prca$pf == 1),
                 hx = 1 * (prca$hx == 1),
                 survtime = prca$survtime,
                 cens = 1 * (prca$cens == 1))
# We now used the function `subgroupset` from the SubgrPlots package 
# to display treatment effects
subgroupset(dat,
            order.by = "freq",
            empty.intersections = "on",
            sets = c("bm", 'pf', "hx"),
            text.scale = 1.5,
            mb.ratio = c(0.25, 0.45, 0.30),
            treatment.var = "trt",
            outcome.type = "survival",
            effects.summary = c("survtime", "cens"),
            query.legend = "top", icon = "pm", transpose = TRUE)

## ---- fig.show='hold', fig.align = "center", out.width="75%", fig.width=5/.7, fig.height=5, cache=TRUE----
dat = prca
dat = dat %>%
  mutate(bm = factor(ifelse(bm == 0 , "No", "Yes")),
         hx = factor(ifelse(hx == 0 , "No", "Yes")))
## Figure 4. Galbraith plot ----------------------------------------------------
p = ggplot_radial(dat,
                  covari.sel = c(4, 5, 6, 7),
                  trt.sel = 3,
                  resp.sel = c(1, 2),
                  outcome.type = "survival",
                  range.v = c(-8, 6),
                  font.size = 4,
                  lab.xy = "default",
                  ticks.length = 0.05)
p +
  ggplot2::theme(text = ggplot2::element_text(size = 14))

## ---- fig.show='hold', fig.align = "center", out.width="70%", fig.width=7, fig.height=5, cache=TRUE----
dat = prca

## Figure 5. STEPP Plot -------------------------------------------------------------
lab.y.title = paste("Treatment effect size (log-hazard ratio)");
setup.ss = c(30, 40)
sub.title = paste0("(Subgroup sample sizes are set to ", setup.ss[2], "; overlap of ", setup.ss[1], ")")
p = ggplot_stepp(dat,
           covari.sel = 8,
           trt.sel = 3,
           resp.sel = c(1, 2),
           outcome.type = "survival",
           setup.ss = setup.ss,
           alpha = 0.05,
           title = NULL,
           lab.y = lab.y.title,
           subtitle = sub.title)
p  +
  ggplot2::theme(text = ggplot2::element_text(size = 14))

## ---- fig.show='hold', out.width="50%", fig.width=5, fig.height=4, cache=TRUE----
dat = prca
setup.ss =  c(10, 60, 15, 30)
dat = dat %>%
  rename(Weight = weight,
         Age = age)

## Figure 6. Contour plot with sliding windows --------------------------------
plot_contour(dat,
             covari.sel = c(8, 9),
             trt.sel = 3,
             resp.sel = c(1, 2),
             outcome.type = "survival",
             setup.ss =  setup.ss,
             n.grid = c(100, 100),
             brk.es = seq(-4.5, 4.5, length.out = 101),
             n.brk.axis =  7,
             para.plot = c(0.5, 2, 6),
             font.size = c(1, 1, 1, 1, 1),
             title = NULL,
             strip = paste("Treatment effect size (log hazard ratio)"),
             show.overall = T, show.points = T,
             filled = T, palette = "hcl", col.power = 0.75)

## Contour plot with weighted local regression --------------------------------
plot_contour_localreg(dat,
                      covari.sel = c(8, 9),
                      trt.sel = 3,
                      resp.sel = c(1, 2),
                      n.grid = c(100, 100),
                      font.size = c(1, 1, 1, 1, 1),
                      brk.es = seq(-4.5, 4.5, length.out = 101),
                      n.brk.axis =  7,
                      strip = "Treatment effect size (log hazard ratio)",
                      outcome.type = "survival")

## ---- fig.show='hold', out.width="50%", fig.width=5, fig.height=4.5, cache=TRUE----
dat = prca
dat = dat %>%
  mutate(bm = factor(ifelse(bm == 0 , "No", "Yes")),
         hx = factor(ifelse(hx == 0 , "No", "Yes")))


# Figure A.1. Tree Plot
# Tree plot with y-axis separately for each layer ------------------------------
plot_tree(dat,
          covari.sel = c(4, 5, 7),
          trt.sel = 3,
          resp.sel = c(1, 2),
          outcome.type = "survival",
          add.aux.line = TRUE,
          font.size = c(12, 12, 0.8),
          title = NULL, text.shift = 0.01,
          lab.y = "Effect size (log hazard ratio)",
          keep.y.axis = FALSE)

# Tree plot with consistent y-axis across layers ---------------------
plot_tree(dat,
          covari.sel = c(4, 5, 7),
          trt.sel = 3,
          resp.sel = c(1, 2),
          outcome.type = "survival",
          add.aux.line = TRUE,
          font.size = c(12, 12, 0.8),
          text.shift = 0.01,
          title = NULL,
          lab.y = "Effect size (log hazard ratio)",
          keep.y.axis = TRUE)



## ---- fig.show='hold', out.width="50%", fig.width=5, fig.height=5, cache=TRUE----
dat =  prca
levels(dat$age_group)    = c("Young", "Middle-aged", "Old")
levels(dat$weight_group) = c("Low", "Mid", "High")
names(dat)[c(14, 15)] = c("Age", "Weight")
strip.title = "Treatment effect size (log hazard ratio)"

## Figure A.2 Level plot -------------------------------------------------------
plot_level(dat,
           covari.sel = c(14, 15),
           trt.sel = 3,
           resp.sel = c(1, 2),
           outcome.type = "survival",
           ss.rect = FALSE,
           range.strip = c(-3, 3),
           n.brk = 31,
           n.brk.axis =  7,
           font.size = c(14, 12, 1, 14, 1),
           title = paste0("Total sample size = ", nrow(dat)),
           strip = strip.title, effect = "HR",
           show.overall = TRUE, palette = "hcl")

## Cells proportional to sample sizes -----------------------------------------
plot_level(dat,
           covari.sel = c(14, 15),
           trt.sel = 3,
           resp.sel = c(1, 2),
           outcome.type = "survival",
           ss.rect = TRUE,
           range.strip = c(-3, 3),
           n.brk = 31,
           n.brk.axis =  7,
           font.size = c(14, 12, 1, 14, 1),
           title = paste0("Total sample size = ", nrow(dat)),
           strip = strip.title, show.overall = TRUE, palette = "hcl")

## ---- fig.show='hold', out.width="50%", fig.width=5, fig.height=4.5, cache=TRUE----
dat = prca
levels(dat$age_group) = c("Young", "Middle-aged","Old")
levels(dat$weight_group)  = c("Low", "Mid", "High")
# Change variable names for better presentation
dat = dat %>%
  rename(`Bone Metastasis` = bm,
         `Performance rating` = pf,
         `History of cardiovascular events` = hx,
         Weight = weight_group,
         Age = age_group) 

# Figure A.3 Mosaic plot with two covariates ------------------------------------
plot_mosaic(dat = dat,
            covari.sel = c(14, 15),
            trt.sel = 3,
            resp.sel = c(1, 2),
            outcome.type =  "survival",
            range.v = NULL,
            adj.ann.subgrp = 4,
            range.strip = c(-3, 3),
            n.brk = 31,
            n.brk.axis = 7, sep. = 0.034,
            font.size = c(10, 12, 12, 10, 1),
            title = NULL, lab.xy = NULL,
            strip = "Treatment effect size (log-hazard ratio)",
            col.line = "white", lwd. = 2,
            effect = "HR", print.ss = FALSE, palette = "hcl")
# Mosaic plot with three covariates --------------------------------------------
plot_mosaic(dat = dat,
            covari.sel = c(5, 7, 4),
            trt.sel = 3,
            resp.sel = c(1, 2),
            outcome.type =  "survival",
            range.v = NULL, adj.ann.subgrp = 4,
            range.strip = c(-3, 3),
            n.brk = 31, n.brk.axis = 7,
            font.size = c(12, 12, 12, 10, 1),
            title = NULL, lab.xy = NULL,
            strip = "Treatment effect size (log-hazard ratio)",
            effect = "HR", palette = "hcl")

## ---- fig.show='hold', fig.align = "center", out.width="50%", fig.width=5, fig.height=5, cache=TRUE----
dat = prca
dat = dat %>%
  rename(Performance = pf,
         `Bone\nmetastasis` = bm,
         `History of\ncardiovascular\nevents` = hx)

## Figure A.4. Venn Diagram with three covariates -------------------------------
plot_venn(dat,
          covari.sel = c(5, 7, 4),
          cat.sel  = c(2, 2, 2),
          trt.sel  = 3,
          resp.sel = c(1, 2),
          outcome.type = "survival",
          fill      = FALSE,
          cat.dist  = c(0.03, 0.04, 0.08),
          font.size = c(1, 1.29, 1.4, 1, 1, 1))


## ---- fig.show='hold', out.width="50%", fig.width=5, fig.height=4, cache=TRUE----
dat = prca
dat = dat %>%
  rename(Stage = stage,
         Performance = pf,
         `Bone\nmetastasis` = bm,
         `History of\ncardiovascular\nevents` = hx)
## Venn Diagram with four covariates ------------------------------------------
plot_venn(dat,
          covari.sel = c(4, 6, 7, 5),
          cat.sel = c(2, 2, 2, 2),
          trt.sel = 3,
          resp.sel = c(1, 2),
          outcome.type = "survival",
          fill = TRUE,
          range.strip = c(-3, 3),
          n.brk = 31, n.brk.axis = 7,
          font.size = c(0.5, 1.1, 1.4, 1, 1, 1),
          strip = paste("Treatment effect size (log hazard ratio)"),
          palette = "hcl",
          cat.dist = c(0.22, 0.22, 0.11, 0.16))

#-------------------------------------------------------------------------------
dat =  prca
dat = dat %>%
  rename(Stage = stage,
         Performance = pf,
         `Bone\nmetastasis` = bm,
         `History of\ncardiovascular events` = hx)
## Venn Diagram with three covariates (proportional area) ---------------------
plot_venn(dat,
          covari.sel = c(5, 7, 4),
          cat.sel = c(2, 2, 2),
          trt.sel = 3,
          resp.sel = c(1, 2),
          outcome.type = "survival",
          fill = TRUE,
          range.strip = c(-3, 3),
          n.brk = 31, n.brk.axis = 7,
          font.size = c(1, 1.29, 1.4, 1, 1, 1),
          strip = paste("Treatment effect size (log hazard ratio)"),
          palette = "hcl", prop_area = TRUE)

## ---- fig.show='hold', fig.align = "center", out.width="50%", fig.width=5, fig.height=5, cache=TRUE----
dat = prca
levels(dat$age_group)     = c("Young", "Middle-aged", "Old")
levels(dat$weight_group)  = c("Low", "Mid", "High")
names(dat)[c(14, 15)]      = c("Age", "Weight")

## Figure A.5. Bar chart --------------------------------------------------------
plot_barchart(dat,
              covari.sel = c(14, 15),
              trt.sel = 3,
              resp.sel = c(1, 2),
              outcome.type = "survival",
              font.size = c(12, 12, 12, 1), time = 50,
              lab.y = "Treatment effect size (RMST difference)")

## ---- fig.show='hold', fig.align = "center", out.width="75%", fig.width=5.5/.7, fig.height=5, cache=TRUE----
dat = prca
dat = dat %>%
  mutate(bm = factor(ifelse(bm == 0 , "No", "Yes")),
         hx = factor(ifelse(hx == 0 , "No", "Yes")))

## Figure A.6. Labbe Plot -------------------------------------------------------
lab.xy = list("Control Group Estimate", "Treatment Group Estimate")
plot_labbe(dat = dat,
           covari.sel = c(4, 5, 6, 7),
           trt.sel = 3,
           resp.sel = c(1, 2),
           outcome.type = "survival",
           effect = "RMST",
           lab.xy = lab.xy,
           size.shape = 0.2,
           adj.ann.subgrp = 1 / 30,
           font.size = c(1, 1, 0.85, 1),
           time = 50, show.ci = FALSE, legend.position = "outside")

## ---- fig.show='hold', fig.align = "center", out.width="50%", fig.width=5, fig.height=5, cache=TRUE----
dat =  prca
levels(dat$age_group)    = c("Young", "Middle-aged", "Old")
levels(dat$weight_group) = c("Low", "Mid", "High")
dat = dat %>%
  rename(Age = age_group,
         Weight = weight_group)

set.seed(55643)
# Figure A.7. Chord diagram -----------------------------------------------------
plot_circle(dat,
            covari.sel = c(14, 15),
            trt.sel = 3,
            resp.sel = c(1, 2),
            outcome.type = "survival",
            range.v = NULL, adj.ann.subgrp = 4,
            range.strip = c(-3, 3),
            n.brk = 31,
            n.brk.axis = 7,
            font.size = c(1, 1, 1, 1, 1),
            title = NULL, lab.xy = NULL,
            strip = "Treatment effect size (log hazard ratio)",
            effect = "HR",
            equal.width = FALSE,
            show.KM = FALSE,
            show.effect = TRUE,
            conf.int = FALSE, palette = "hcl")

## ---- fig.show='hold', fig.align = "center", out.width="50%", fig.width=6, fig.height=5, cache=TRUE----
dat = prca
vars = data.frame(variable = names(dat), index = 1:length(names(dat)))
levels(dat$age_group) = c("Young", "Middle-aged", "Old")
levels(dat$weight_group) = c("Low", "Mid", "High")
names(dat)[c(14, 15)] = c("Age", "Weight")
strip.title = "Treatment effect size (log hazard ratio)"
## Figure A.8. Coxcomb plot
plot_nightingale_effect(dat,
                       covari.sel = c(14, 15),
                       trt.sel = 3,
                       resp.sel = c(1, 2),
                       outcome.type = "survival",
                       seq_by = 50,
                       range.strip = c(-3, 3),
                       n.brk = 31,
                       n.brk.axis =  7,
                       title = "Total sample size = 475",
                       strip = strip.title, effect = "HR",
                       show.overall = TRUE, palette = "hcl")

## ---- fig.show='hold', fig.align = "center", out.width="60%", fig.width=5.5, fig.height=5.5, cache=TRUE----
dat = prca
dat = dat %>%
  mutate(bm = factor(ifelse(bm == 0 , "No", "Yes")),
         hx = factor(ifelse(hx == 0 , "No", "Yes")))
## Figure S1.1 Galbraith plot ---------------------------------------------------
p = ggplot_radial2(dat,
              covari.sel = c(4, 5, 6, 7),
              trt.sel = 3,
              resp.sel = c(1, 2),
              outcome.type = "survival",
              range.v = c(-11, 9),
              font.size = 4,
              lab.xy = "default",
              ticks.length = 0.05)
p +
  ggplot2::theme(text = ggplot2::element_text(size = 14))

## ---- fig.show='hold', fig.align = "center", out.width="50%", fig.width=5, fig.height=5, cache=TRUE----
dat = prca
 
## Figure 5. STEPP Plot -------------------------------------------------------------
lab.y.title = paste("Treatment effect size (log-hazard ratio)");
setup.ss = c(30, 40)
sub.title = paste0("(Subgroup sample sizes are set to ", setup.ss[2],
                   "; overlap of ", setup.ss[1], ")")
plot_stepp(dat,
           covari.sel = 8,
           trt.sel = 3,
           resp.sel = c(1, 2),
           outcome.type = "survival",
           setup.ss = setup.ss,
           alpha = 0.05,
           title = NULL,
           lab.y = lab.y.title,
           subtitle = sub.title)

## ---- fig.show='hold', fig.align = "center", out.width="50%", fig.width=5, fig.height=5, cache=TRUE----
dat = prca
dat = dat %>%
  mutate(bm = factor(ifelse(bm == 0 , "No", "Yes")),
         hx = factor(ifelse(hx == 0 , "No", "Yes")),
         Treatment = factor(ifelse(rx == 0 , "Ctrl", "Exp")),
         Survival = factor(ifelse(survtime > 24 , "Yes", "No"),  
                           levels = c("Yes", "No")))
levels(dat$age_group) = c("Young", "Middle-aged", "Old")
levels(dat$weight_group)  = c("Low", "Mid", "High")
vars = data.frame(variable = names(dat), index = 1:length(names(dat)))
# Change variable names
dat = dat %>%
  rename(`Bone Metastasis` = bm,
         `Performance rating` = pf,
         `History of cardiovascular events` = hx,
         `2-year survival` = Survival,
         Weight = weight_group,
         Age = age_group)

# Figure S1.2. Mosaic plot -------------------------------------------------------
plot_mosaic(dat,
            covari.sel = c(14, 16, 17),
            trt.sel = 3,
            resp.sel = c(1, 2),
            outcome.type =  "survival",
            range.v = NULL, adj.ann.subgrp = 4,
            range.strip = c(-3, 3),
            n.brk = 7,
            font.size = c(12, 12, 12, 12, 0.7),
            title = NULL, lab.xy = NULL, sep. = 0.03,
            strip = "Treatment effect size",
            effect = "HR", show.effect = FALSE)

## ---- fig.show='hold', fig.align = "center", out.width="50%", fig.width=5, fig.height=5, cache=TRUE----
dat = prca
levels(dat$age_group) = c("Young", "Middle-aged", "Old")
levels(dat$weight_group)  = c("Low", "Mid", "High")
comb_levels = c("Young - Low", "Young - Mid", "Young - High",
                "Middle-aged - Low", "Middle-aged - Mid", "Middle-aged - High",
                "Old - Low", "Old - Mid", "Old - High")
dat = dat %>%
  mutate(AgeWeight = factor(sprintf("%s - %s", age_group, weight_group),
                            levels = comb_levels))  %>%
  mutate(survival = factor(ifelse(survtime > 24 , "Yes", "No"),
                           levels = c("No", "Yes"))) %>% 
  mutate(rx = factor(rx, labels = c("Control", "Treatment")))


## Figure S1.3. Coxcomb Plot 2
plot_nightingale(dat = dat,
                 covari.sel = 16,
                 resp.sel = 17, 
                 strip = "2-year survival")

## ---- fig.show='hold', fig.align = "center", out.width="100%", fig.width=10, fig.height=5, cache=TRUE----

## Figure S1.4. Coxcomb Plot 2 separate arms
plot_nightingale(dat = dat, trt.sel = 3, 
                 covari.sel = 16, 
                 resp.sel = 17,  
                 seq_by = 50,
                 strip = "2-year survival")

## ---- fig.show='hold', out.width="50%", fig.width=5, fig.height=5, cache=TRUE----
dat = prca
dat = dat %>%
  mutate(survival = factor(ifelse(survtime > 24 , "Yes", "No"), levels = c("No", "Yes")),
         trt = rx)
alldat = dat %>%
  dplyr::select(trt, bm, hx, pf, survival) %>%
  dplyr::group_by(trt, bm, hx, pf, survival) %>%
  dplyr::summarise(Freq = n()) 
alldat = alldat %>%
  ungroup() %>%
  mutate(trt = ifelse(trt == 0 , "Control", "Treatment"),
         bm = ifelse(bm == 0 , "No", "Yes"),
         hx = ifelse(hx == 0 , "No", "Yes"))

# Figure S1.5. Alluvial diagram by survival --------------------------------------
plot_alluvial(alldat[, c(5, 1, 3, 2, 4)], freq = alldat$Freq,
              xw = 0.2, cw = 0.12, cex = 1,
              alpha  = 0.8,
              col = ifelse(alldat$survival  == "Yes",
                           ifelse(alldat$trt  == "Treatment", "#80b1d3", "#d5e2eb"),
                           ifelse(alldat$trt  == "Treatment", "#faa8d2", "#fbe0ee")),
              layer = alldat$trt  == 1, rotate = 90, las = 2, bottom.mar = 5)


# ------------------------------------------------------------------------------
dat = prca
dat$trt = dat$rx
alldat = dat %>%
  dplyr::select(trt, bm, hx, pf) %>%
  dplyr::group_by(trt, bm, hx, pf) %>%
  dplyr::summarise(Freq = n())
alldat = alldat %>%
  ungroup() %>%
  mutate(trt = ifelse(trt == 0 , "Control", "Treatment"),
         bm = ifelse(bm == 0 , "No", "Yes"),
         hx = ifelse(hx == 0 , "No", "Yes"))

# Figure S1.6. Alluvial diagram by treatment arms --------------------------------
plot_alluvial(alldat[, c(1, 3, 2, 4)], freq = alldat$Freq,
              xw = 0.2, cw = 0.12, cex = 1,
              alpha  = 0.8,
              col=ifelse(alldat$trt == "Treatment", "#1f78b4", "#a6cee3"),
              layer = alldat$trt  == 1, rotate = 90)

## ---- fig.show='hold', out.width="49%", fig.width=5, fig.height=5, cache=TRUE----
dat = prca


## Figure S1.7. Overlap plots

## Figure S1.7.a Overlap plot ----------------------------------------------------
plot_overlap(dat = dat,
             covari.sel = c(6, 5, 4, 7),
             para = c(0.1, 0.5, 1),
             font.size = c(1.2, 1.2, 0.8),
             title = NULL)
## Figure S1.7.b Overlap alternative plot ----------------------------------------
plot_overlap_alternative(dat = dat,
                         covari.sel = c(6, 5, 4, 7),
                         mode = 1,
                         para = c(0, 0.6, 1),
                         font.size = c(1.2, 1.2, 0.8),
                         title = NULL)
## Figure S1.7.c Network plot ----------------------------------------------------
plot_network(dat = dat,
             covari.sel = c(6, 5, 4, 7),
             para = c(0.1, 0.5, 1),
             font.size = c(1.2, 1.2, 0.8),
             title = NULL)
## Figure S1.7.d Matrix Overlap plot ---------------------------------------------
plot_matrix_overlap(dat,
                    covari.sel = c(6, 5, 4, 7),
                    mode = 1,
                    font.size = c(1.5, 1.25, 0.8),
                    title = NULL)
## Figure S1.7.e dissimilarity plot ----------------------------------------------
plot_dissimilarity(dat = dat,
                   covari.sel = c(4, 5, 6),
                   mode = 3,
                   range.ds = c(0, 1),
                   font.size = c(1, 0.9, 1, 0.7),
                   title = NULL,
                   lab.x = "Dissimilarity distance")
## Figure S1.7.f dissimilarity alternative plot ----------------------------------
plot_dissimilarity_alternative(dat = dat,
                               covari.sel = c(4, 5, 6),
                               mode = 2,
                               range.ds = c(0, 1),
                               font.size = c(1, 1, 0.7),
                               title = NULL,
                               lab.y = "Similarity distance")

## ---- fig.show='hold', out.width="100%", fig.width=10, fig.height=5, cache=TRUE----
dat = prca
set.seed(12)
## Figure S1.8. Overlap plots
plot_circle2(dat,
             covari.sel = c(4, 5, 6, 7),
             trt.sel = 3,
             resp.sel = c(1, 2),
             outcome.type = "survival",
             range.v = NULL,
             adj.ann.subgrp = 4,
             range.strip = c(-3, 3),
             n.brk = 31,
             n.brk.axis = 7,
             font.size = c(1, 1, 1.75, 0.85, 1),
             title = NULL, lab.xy = NULL,
             strip = "Treatment effect size (log hazard ratio)",
             effect = "HR",
             equal.width = FALSE,
             show.KM = FALSE,
             show.effect = TRUE,
             conf.int = FALSE, palette = "hcl")

## ---- fig.show='hold', out.width="100%", fig.width=10, fig.height=5, cache=TRUE----
dat = prca
set.seed(12)
## Figure S1.9. Overlap plots
plot_circle2(dat,
             covari.sel = c(4, 5, 6, 7),
             trt.sel = 3,
             resp.sel = c(1, 2),
             outcome.type = "survival",
             range.v = NULL, adj.ann.subgrp = 4,
             range.strip = c(-3, 3),
             n.brk = 31,
             n.brk.axis = 7,
             font.size = c(1, 1, 1.75, 0.85, 1),
             title = NULL, lab.xy = NULL,
             strip = "Treatment effect size (log hazard ratio)",
             effect = "HR",
             equal.width = TRUE,
             show.KM = FALSE,
             show.effect = TRUE,
             conf.int = FALSE, palette = "hcl")

## ---- fig.show='hold', out.width="100%", fig.width=7, fig.height=5, cache=TRUE----
dat = prca
## Figure S1.10. Overlap plots
plot_overlap2(dat = dat,
              covari.sel = c(6, 5, 4, 7),
              para = c(0.05, 0.75, 1),
              font.size = c(1.2, 1.2, 0.8),
              title = NULL)

## ---- fig.show='hold', out.width="100%", fig.width=7, fig.height=5, cache=TRUE----
sessionInfo()

