rm(list=ls())

library(Rtsne) 
library(ggplot2) 
library(cluster)
library(Metrics)
library(tibble)
library(lubridate)
library(stats)
library(dplyr)
library(kernlab)
library(caret)
library(e1071)
library(neuralnet)

taxi_trips <- read.csv("Taxi_120117.csv")

taxi_trips <- taxi_trips[sample(nrow(taxi_trips), 1000), ]

taxi_trips$tpep_dropoff_datetime <- as.character(taxi_trips$tpep_dropoff_datetime)
taxi_trips$tpep_pickup_datetime <- as.character(taxi_trips$tpep_pickup_datetime)

taxi_trips$tpep_dropoff_datetime <- as.POSIXct(taxi_trips$tpep_dropoff_datetime, format='%Y-%m-%d %H:%M:%S')
taxi_trips$tpep_pickup_datetime  <- as.POSIXct(taxi_trips$tpep_pickup_datetime, format='%Y-%m-%d %H:%M:%S')

# Because IDs are not in a quantitative relation, we convert their values into factors
taxi_trips$PULocationID <- as.factor(taxi_trips$PULocationID)
taxi_trips$DOLocationID <- as.factor(taxi_trips$DOLocationID)

taxi_trips <- select(taxi_trips,"mph","PULocationID","DOLocationID")

#boxplot(taxi_trips$mph)

#cut out outliers w.r.t. mph
taxi_trips <- subset(taxi_trips, mph < 30 & mph >= 0)

gower_dist <- daisy(taxi_trips,metric = "gower",type = list(logratio = 3))

#output most similar trip
gower_mat <- as.matrix(gower_dist)

taxi_trips[which(gower_mat == min(gower_mat[gower_mat != min(gower_mat)]),
        arr.ind = TRUE)[1, ], ]

#output most dissimilar trip
taxi_trips[which(gower_mat == max(gower_mat[gower_mat != max(gower_mat)]),
        arr.ind = TRUE)[1, ], ]

# Calculate silhouette width for many k using PAM

#sil_width <- c(NA)

#for(i in 2:10){
  
#  pam_fit <- pam(gower_dist,diss = TRUE,k = i)
  
#  sil_width[i] <- pam_fit$silinfo$avg.width
  
#}

# Plot sihouette width (higher is better)
#plot(1:10, sil_width,xlab = "Number of clusters",ylab = "Silhouette Width")
#lines(1:10, sil_width)

#assuming we take k = 5 as a reasonable amount of clusters
pam_fit <- pam(gower_dist, diss = TRUE, k = 5)

pam_results <- taxi_trips %>%
  mutate(cluster = pam_fit$clustering) %>%
  group_by(cluster) %>%
  do(the_summary = summary(.))

pam_results$the_summary



