
# 1 loading more datasets

# meta: 
#browseURL("https://archive.ics.uci.edu/ml/datasets/STUDENT+ALCOHOL+CONSUMPTION")

# read the math class questionaire data
math <- read.table("../datasets/student-mat.csv",sep=";",header=TRUE)

# look at the column names
colnames(math)

# read the portuguese class questionaire data
por <- read.table("../datasets/student-por.csv",sep=";",header=TRUE)

# look at the column names
colnames(por)

# 2 joining two datasets

# common columns to merge the datasets by
join_by <- c("school","sex","age","address","famsize","Pstatus","Medu","Fedu","Mjob","Fjob","reason","nursery","internet")

# access the dplyr library
library(dplyr)

# join the two datasets by selected common variables
math_por <- inner_join(math, por, by = join_by, suffix = c(".math", ".por"))

# see the new column names
colnames(math_por)


# 3 glimpse at the joined dataset

# access the dplyr library
library(dplyr)

# glimpse at the new data
glimpse(math_por) 


# 4 Transforming by looping

join_by <- c("school","sex","age","address","famsize","Pstatus","Medu","Fedu","Mjob","Fjob","reason","nursery","internet")

# which columns in the datasets were not used for joining the data
notjoined_columns <- colnames(math)[!colnames(math) %in% join_by]

# create a new data frame with the common columns
alc <- select(math_por, one_of(join_by))

# access the dplyr library
library(dplyr)

# average/combine the rest of the columns
for(column_name in notjoined_columns) {
  
  df <- select(math_por, starts_with(column_name))
  
  if(is.numeric(select(df, 1))) {
    alc[column_name] <- rowMeans(df)
  } else {
    alc[column_name] <- select(df, 1)
  }
}

# final column names of the data
colnames(alc)

## 5 Mutating and exploring

library(dplyr)
library(ggplot2)

## combine weekday and weekend alcohol use into alc_use
alc <- mutate(alc, alc_use = (Dalc + Walc) / 2)

## draw a histogram of alcohol use
qplot(alc_use, data = alc, bins = 10, main = "Student alcohol consumption")

# 6 Binarizing a variable

# transform alc_use into a binary (T, F) variable high_use
alc$high_use <- alc$alc_use > 2

# draw a bar plot
qplot(high_use, data = alc)

# save the data
# write.table(file = "../datasets/alc.txt", alc, sep = ",", row.names = F)

# 7 exploring relationships with cross tables

library(descr)

crosstab(alc$sex, alc$high_use, prop.c = T, prop.r = T)

crosstab(alc$failures, alc$high_use, prop.c = T, prop.r = T)

# 8 comparisons with box plots
library(ggplot2)
p <- ggplot(alc, aes(x = high_use, y = absences))
p + geom_boxplot() 

# Logistic regression
# -------------------

## 9 fitting a logistic regression model
m1 <- glm(high_use ~ sex + failures + absences, data = alc, family = binomial)

# print out a summary of the model
summary(m1)

## print out the coefficients
m1

## print out the exponentiated coefficients
exp(coefficients(m1))

## 10 model performance: prediction accuracy

# predict the response
alc$prediction <- predict(m1, type = "response")

head(select(alc, high_use, prediction))

## 11 model performance: cross-validation


# cost function
cost <- function(class, prediction) mean(abs(class - prediction) > 0.5)

# k-fold cross-validation
library(boot)
cv <- cv.glm(data = alc, cost = cost, glmfit = m1, K = 10)

# print out the average number of wrong predictions in the cross validation
cv$delta[1]
