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

Inorder to skip building a number of different individual TimeSeries models and reduce the overhead of managing severall models we explored how dimensionality reduction techniques like SVD can be used to shrink the number of series that are to be predicted

# Singular Value Decomposition - Revisiting the Basics

A singular value decomposition (SVD) of an n x d matrix A expresses the matrix as the product of three simple matrices such that:

A = U . S . V^T

Where:

1. U =  n x d orthogonal matrix 
2. S = n x d diagonal matrix with nonnegative entries, and diagonal entries sorted from high to low
3. V = d x d orthogonal matrix

![alt text](https://github.com/mishee90/Multiple-Series-Forecasting-using-Dimensionality-Reduction/blob/main/SVD.jpg)

Note that A does not has to be a square matrix for SVD decomposition. The columns of matrxi U are the left singular vectors of A. The columns of V are right singular vectors 
of A and the diagonal of S are the singular values of A.

# Low Rank Representation from SVD

After calculating the U, S, V of the SVD, we need to choose the principal components to forecast i.e. minimum number of components of A that explain maximum variance.
1. The matrix of principal component columns is calculated as UᐧS (dim nxd)
2. Analyzing the explained variance ratio of these components with a scree plot of d, we identify that the first 3 components account for 99% of the total variance of the data set.
3. Now we can use the first 3 principal component columns of UᐧS as the time series to forecast.

# Forecast Using Principal Components

Using ARIMA, we forecast the top 3 principal component columns for each department
1. The overall complexity has been reduced to 3 models per department (instead of 45)
* 81 departments x 3 PC = 243 models, down from 3331 total department-store TS

# Recreating the original Time Series (Matrix A) after forecasting using ARIMA

After forecasting the first 3 columns of UᐧS, we need to  recompose the principal component forecasts back to the original 45 stores sales.
1. The UᐧS matrix is extended by the h steps forecasted.
2. The forecasted values are placed in the first 3 columns of the n+1 to n+h rows.
3. The remaining values of the forecasted rows are filled with the values from the nth (last known) row.
4. The original A (plus forecast) is then reconstructed with the dot product A = UᐧSᐧV^T



# Model Evaluation

The decomposed ARIMA model was evaluated using SMAPE - Symetric Mean Absolute Percent Error

![alt text](https://github.com/mishee90/Multiple-Series-Forecasting-using-Dimensionality-Reduction/blob/main/SMAPE.jpg)

Here A is the actual value and F is the forecasted value

The decomposed model performed well when compared with forecasting individual series for each store-department combination using ARIMA. The loss in accuracy with SVD based forecasting model was ~13% across the 5 departments where we tested the model.

![alt text](https://github.com/mishee90/Multiple-Series-Forecasting-using-Dimensionality-Reduction/blob/main/SVD_Arima_Results.PNG)


# Resources and Credits

Many thanks to the following Stanford University lecture notes on SVD:
1. The Singular Value Decomposition (SVD) and Low-Rank Matrix ApproximationsStanford University, April 27, 2015. Tim Roughgarden & Gregory Valianthttp://theory.stanford.edu/~tim/s15/l/l9.pdf
2. This work was performed as a group with equal contribution from Karthik Subramanian and Audery Salerno from The University of Chicago
