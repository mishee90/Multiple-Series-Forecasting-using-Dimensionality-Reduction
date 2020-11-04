# Multiple-Series-Forecasting-using-Dimensionality-Reduction
Forecasting multiple related time series, such as store and department-level sales, can require numerous different time series models to forecast each individual time series. Using data from the Walmart Recruiting Stores Sales Forecasting Challenge, can we find successful methods of reducing the dimensionality of the forecasting task and limit the number of total models necessary to accurately forecast the individual store/department level sales?

# Data

* 45 Walmart Stores
* 81 Departments (not all stores have every department)
* Weekly sales for each store/department (recorded on Fridays)
* Training data from February 5, 2010 - September 28, 2012 across all 45 stores on weekly basis
* Forecast 4 weeks of sales, October 5 - October 26, 2012 
* Focus on the first 5 departments for now
* Additional dimensions used for ensemble method later, such as Store, Department, isHoliday, Size, Temperature, Markdown
* Departments had unique trends and seasonality patterns

# MODEL APPROACHE

**We will evaluate dimensionality-reduction-based modelling approaches to forecast the next 4 weeks of weekly store sales per department:**
1. AUTO ARIMA on each individual store per department.  This will be our baseline to evaluate the effectiveness of the subsequent dimensionality reduction approaches.
2. AUTO ARIMA on the top 3 principal components from SVD (per department) as individual univariate time series and then recomposing back to the original stores.

# Challenge of Forecasting Individual Series

**Why  not model individual stores and departments?**
* That would require 3331 individual time series models! 
**Why 3331 time series models?**
* Since we have 45 stores and each store can be in different region with their own demand variability it is imperative we create individual forecasts for each of these stores.
* Each department are also very different from each other and have their own variations and seasonality and hence have to be modeled individually.
* Keeping these two pointers in mind that puts the total number of models to 45 (# of stores) x 81 (# of Depts) = 3645. However, in reality not all stores will have all the departments and hence the actual number of models will be lesser than 3645 and which in this case was 3331

# Why Dimensionality Reduction

Inorder to skip building a number of different individual TimeSeries models and reduced the overhead of managing severall models we explored how dimensionality reduction techniques like SVD can help
