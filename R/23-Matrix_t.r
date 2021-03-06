## Sets up data for matrix layout and adjusts names of sets if they are too small
## Essentially strips uneeded columns, converts data to matrix, and adjusts the labels to appropriate length
## i.e. if the labels were one letter each, appropriate space is added to make it fit and look neat
Create_matrix <- function(data){
  Matrix_setup <- as.matrix(t(data[ , 1:(length(data) -3)]))
  names <- rownames(Matrix_setup)
  max <- max(nchar(names))
  if( max < 7)
  {
    Spaces <- list()
    rownames(Matrix_setup) <- gsub(x = rownames(Matrix_setup), pattern = "\\.", replacement = " ")
  }
  return(Matrix_setup)
}

## Take adjusted (if they needed to be) names of sets for matrix y-axis tick labels
## Used to add set names to matrix ggplot
Make_labels <- function(setup){
  names <- rownames(setup)
  return(names)
}

## Takes matrix setup data and turns it into grid format (binary)
## 1's represent dark circles, 0's light, and if x-value has multiple 1's they are connected.
Create_layout <- function(setup, mat_color, mat_col, matrix_dot_alpha){
  Matrix_layout <- expand.grid(y=seq(nrow(setup)), x=seq(ncol(setup)))
  Matrix_layout <- data.frame(Matrix_layout, value = as.vector(setup))
  Matrix_layout$shape <- 19
  Matrix_layout$dots <- 19
  for(i in 1:nrow(Matrix_layout)){
    if(Matrix_layout$value[i] > as.integer(0)){
      Matrix_layout$color[i] <- mat_color
      Matrix_layout$alpha[i] <- 1
      Matrix_layout$Intersection[i] <- paste(Matrix_layout$x[i], "yes", sep ="")
      Matrix_layout$pm[i]   <- 43
      # if(Matrix_layout$value[i] == 2) Matrix_layout$shape[i] <- 3
      if(Matrix_layout$value[i] == 2) Matrix_layout$color[i] <- "gray83"
      if(Matrix_layout$value[i] == 2) Matrix_layout$pm[i] <- 32
    }
    else{
      Matrix_layout$pm[i]   <- 45
      Matrix_layout$color[i] <- "gray83"
      Matrix_layout$alpha[i] <- matrix_dot_alpha
      Matrix_layout$Intersection[i] <- paste(i, "No", sep = "")
    }
  }
  if(is.null(mat_col) == F){
    for(i in 1:nrow(mat_col)){
      mat_x <- mat_col$x[i]
      mat_color <- as.character(mat_col$color[i])
      for(i in 1:nrow(Matrix_layout)){
        if((Matrix_layout$x[i] == mat_x) && (Matrix_layout$value[i] != 0)){
          Matrix_layout$color[i] <- mat_color
        }
      }
    }
  }
  Matrix_layout$pm.circle = Matrix_layout$pm
  return(Matrix_layout)
}

## Create data set to shade matrix
MakeShading <- function(Mat_data, color){
  y <- unique(Mat_data$y)
  y <- (y[which(y %% 2 != 0)])
  data <- data.frame(cbind(y))
  data$min <- 0
  data$max <- (max(Mat_data$x) + 1)
  for( i in 1:length(y)){
    data$y_min[i] <- ((y[i]) - 0.5)
    data$y_max[i] <- ((y[i]) + 0.5)
  }
  data$shade_color <- color
  return(data)
}

## Generate matrix plot
Make_matrix_plot_t <- function(Mat_data,Set_size_data, Main_bar_data, point_size, line_size, text_scale, labels,
                             shading_data, shade_alpha, icon){

  if(length(text_scale) == 1){
    name_size_scale <- text_scale
  }
  if(length(text_scale) > 1 && length(text_scale) <= 6){
    name_size_scale <- text_scale[5]
  }

  Mat_data$x = max(Mat_data$x) - Mat_data$x + 1

  Matrix_plot <- (ggplot()
                  + theme(panel.background = element_rect(fill = "white"),
                          axis.ticks.y = element_blank(),
                          axis.ticks.x = element_blank(),
                          axis.text.y = element_blank(),
                          axis.text.x = element_text(colour = "gray0",
                                                     size = 7*name_size_scale, hjust = 0.5),
                          panel.grid.major = element_blank(),
                          panel.grid.minor = element_blank())
                  + xlab(NULL) + ylab("   ")
                  + scale_y_continuous(breaks = c(1:nrow(Set_size_data)),
                                       limits = c(0.5,(nrow(Set_size_data) + 0.5)),
                                       labels = labels, expand = c(0,0),
                                       position = "right")
                  + scale_x_continuous(limits = c(0,(nrow(Main_bar_data)+1 )), expand = c(0,0))
                  + geom_rect(data = shading_data, aes_string(xmin = "min", xmax = "max",
                                                              ymin = "y_min", ymax = "y_max"),
                              fill = shading_data$shade_color, alpha = shade_alpha)
                  + coord_flip()
                  + scale_color_identity())
  if (icon == "value"){
    Matrix_plot = Matrix_plot +
      geom_text(data = Mat_data[which(Mat_data$value != 2),],
                aes_string(x= "x", y= "y"), colour = "gray23",
                label = Mat_data[which(Mat_data$value != 2),][[icon]],
                size= 2*point_size, alpha = 1)
  }
  if (icon == "pm"){
    Matrix_plot = Matrix_plot +
      geom_point(data= Mat_data, aes_string(x= "x", y= "y"), colour = "gray23",
                 shape = Mat_data[[icon]],
                 size= 2*point_size, alpha = 1)
  }
  if (icon == "pm.circle"){
    Matrix_plot = Matrix_plot +
      geom_point(data= Mat_data, aes_string(x= "x", y= "y"), colour = "gray85",
                 shape = 19,
                 size= 1.75*point_size) +
      geom_point(data= Mat_data, aes_string(x= "x", y= "y"), colour = "gray23",
                 shape = Mat_data[[icon]],
                 size= 2*point_size, alpha = 1)
  }
  if (icon == "dots"){
    Matrix_plot = Matrix_plot +
      geom_point(data= Mat_data, aes_string(x= "x", y= "y"), colour = Mat_data$color,
                 shape = Mat_data[[icon]],
                 size= point_size, alpha = Mat_data$alpha) +
      geom_point(data= Mat_data[which(Mat_data$value == 2), ],
                 aes_string(x= "x", y= "y"), colour = "gray23",
                 shape = 19,
                 size= 0.25*point_size, alpha = 1)
  }
  Matrix_plot <- ggplotGrob(Matrix_plot)
  return(Matrix_plot)
}
