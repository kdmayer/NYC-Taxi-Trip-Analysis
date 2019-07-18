rm(list=ls())

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

taxi_trips <- taxi_trips[sample(nrow(taxi_trips), 10000), ]

taxi_trips$tpep_dropoff_datetime <- as.character(taxi_trips$tpep_dropoff_datetime)
taxi_trips$tpep_pickup_datetime <- as.character(taxi_trips$tpep_pickup_datetime)

taxi_trips$tpep_dropoff_datetime <- as.POSIXct(taxi_trips$tpep_dropoff_datetime, format='%Y-%m-%d %H:%M:%S')
taxi_trips$tpep_pickup_datetime  <- as.POSIXct(taxi_trips$tpep_pickup_datetime, format='%Y-%m-%d %H:%M:%S')

# IDs are not in a quantitative relation
taxi_trips$PULocationID <- as.factor(taxi_trips$PULocationID)
taxi_trips$DOLocationID <- as.factor(taxi_trips$DOLocationID)

sum_taxi_trips <- select(taxi_trips,"trip_duration","passenger_count","trip_distance","payment_type","total_amount")

# provides a summary statistic for specific features
summary(sum_taxi_trips)

# predict estimated travel time based on pick up ID, pick up date time, drop off ID, and trip distance
taxi_model1_SVM <- select(taxi_trips, "tpep_pickup_datetime", "trip_distance","PULocationID","DOLocationID", "trip_duration")

# create training and testing data sets (70% of data for training)
train_sample <- sample(10000,7000)
summary(taxi_model1_SVM)

#boxplot(taxi_model1_SVM$trip_duration)

travel_time_train <- taxi_model1_SVM[train_sample,]
travel_time_train <- subset(travel_time_train, trip_duration < 5000 & trip_duration > 0)
travel_time_test <- taxi_model1_SVM[-train_sample,]
travel_time_test <- subset(travel_time_test, trip_duration < 5000 & trip_duration > 0)

# build SVM wit linear kernel
travel_time_model <- ksvm(trip_duration ~ ., data = travel_time_train, 
                          kernel = "rbfdot")
travel_time_pred <- predict(travel_time_model,travel_time_test)

summary(travel_time_pred)

summary(travel_time_test[,5])

# evaluate results based on MSE

plot(travel_time_test$trip_duration, travel_time_pred)

MAE(travel_time_pred, travel_time_test$trip_duration)

cor(travel_time_pred, travel_time_test$trip_duration)
