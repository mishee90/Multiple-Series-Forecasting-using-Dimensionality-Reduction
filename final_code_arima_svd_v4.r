library(forecast)
library(ggplot2)
library(plyr)
library(reshape)
library(tseries)
library(TSPred)

setwd("C:/Dhaval/Program Course Work/Time Series Analysis and Forecasting/Project/")

######################## Cleaned Loops for all the Departments

# Reading the Raw Data
raw.train <- function(){
  # Loads the training data with correct classes
  cls <- c('factor', 'factor', 'Date', 'numeric', 'logical')
  train <- read.csv('train.csv', 
                    colClasses=cls)
}

# Transposing the data to create a matrix of date by stores for each department
train_tr <- function(raw.train,dept){
  tr.data <- raw.train[raw.train$Dept==dept,c(3,1,4)]
  # Transpose to create a matrix of dates x stores with values populated as weekly sales
  train.processed <- cast(tr.data,Date ~ Store)
  return(train.processed)
}

# Calculating the SVD
preprocess.svd <- function(train,nu.arg = nrow(train),nv.arg = ncol(train)){
  # Filling in missing values with 0 for the SVD function to work
  train[is.na(train)] <- 0
  
  z <- svd(train[, 2:ncol(train)], nu=nu.arg, nv=nv.arg-1)
  return(z)
}


# Using Arima to do a univariate ts forecast on the reduced train data
forecast.reduced.arima <- function(reduced.train){
  c1 <- ts(reduced.train[,1],frequency = 7)
  c1.forecast <- auto.arima(c1,stepwise = F,approximation = F)
  c1.new <- c1.forecast$fitted
  c1.pred <- forecast(c1.forecast,h = 4)
  
  c2 <- ts(reduced.train[,2],frequency = 7)
  c2.forecast <- auto.arima(c2,stepwise = F,approximation = F)
  c2.new <- c2.forecast$fitted
  c2.pred <- forecast(c2.forecast,h = 4)
  
  c3 <- ts(reduced.train[,3],frequency = 7)
  c3.forecast <- auto.arima(c3,stepwise = F,approximation = F)
  c3.new <- c3.forecast$fitted
  c3.pred <- forecast(c3.forecast,h = 4)
  
  # Re-Creating the forecasted u dot product s
  reduced.train.forecast <- as.matrix(cbind(c1.new,c2.new,c3.new))
  
  reduced.train.pred <- as.matrix(cbind(summary(c1.pred)[,1],summary(c2.pred)[,1],summary(c3.pred)[,1]))
  return(list(reduced.train.forecast,reduced.train.pred))
  #return(reduced.train.forecast)
}

# Using the 3 components to create the reduced train data to forecast and return the forecasted train and test data
dept.forecast.arima <- function(train.processed){
  svd.result <- preprocess.svd(train.processed)
  S <- diag(svd.result$d,nrow = nrow(train.processed),ncol = ncol(train.processed)-1)
  us <- svd.result$u%*%S
  usvt <- us%*%t(svd.result$v)
  # Considering only the first 3 components since they explain 99% of variance
  reduced.train <- us[,1:3]
  
  # Running a arima forecast on the 3 columns of the u dot s
  arima.list <- forecast.reduced.arima(reduced.train)
  
  # THe Training data forecast from the model. A matrix of 3 columns
  reduced.train.forecast <- as.matrix(arima.list[[1]])

  # The forecasted test data for 4 future weeks
  reduced.train.pred <- as.matrix(arima.list[[2]])
  
  # Recosntructing back the forecasted matrix of weeks by stores - For Train Data
  us.forecast <- as.matrix(cbind(reduced.train.forecast,us[,4:ncol(us)]))
  dept.forecast <- us.forecast%*%t(svd.result$v)
  
  ### Prediction
  # Recosntructing back the forecasted matrix of weeks by stores - For Test Data
  us.predict <- as.matrix(cbind(reduced.train.pred,us[136:139,4:ncol(us)]))
  dept.pred <- us.predict%*%t(svd.result$v)
  
  return(list(dept.forecast,dept.pred))
}

# Reading the Raw Data

train.data <- raw.train()
train.data$Store = sprintf("%02d",train.data$Store)
train.data$Dept = sprintf("%02d",train.data$Dept)



################ Forecasting for Department 1

## ARIMA
# Preprocessing the data


train.tran <- train_tr(train.data,dept = "01")

train.processed <- train.tran[1:139,]
test <- train.tran[140:143,]


# Training for Dept 1 Sales
dept.1.list <- dept.forecast.arima(train.processed)
dept.1.forecast <- dept.1.list[[1]]
dept.1.pred <- dept.1.list[[2]]

## SMAPE For Train Data
sMAPE(as.vector(as.matrix(train.processed[,2:ncol(train.processed)])),as.vector(as.matrix(dept.1.forecast)))


## SMAPE for Test Data

sMAPE(as.vector(as.matrix(test[,2:ncol(train.processed)])),as.vector(as.matrix(dept.1.pred)))


######## DEPT 5

train.tran <- train_tr(train.data,dept = "05")

train.processed <- train.tran[1:139,]
test <- train.tran[140:143,]


# Training for Dept 1 Sales
dept.5.list <- dept.forecast.arima(train.processed)
dept.5.forecast <- dept.5.list[[1]]
dept.5.pred <- dept.5.list[[2]]

## SMAPE For Train Data
sMAPE(as.vector(as.matrix(train.processed[,2:ncol(train.processed)])),as.vector(as.matrix(dept.5.forecast)))

## Smape for Test Data
sMAPE(as.vector(as.matrix(test[,2:ncol(test)])),as.vector(as.matrix(dept.5.pred)))


#### The Forecast for each department can be created by looping through each of the departments from the data.
