# Getting and Cleaning Data Week 4 Homework Assignment
# 
#http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
#Here are the data for the project:
#  https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
#You should create one R script called run_analysis.R that does the following. 
#Merges the training and the test sets to create one data set.
#Extracts only the measurements on the mean and standard deviation for each measurement. 
#Uses descriptive activity names to name the activities in the data set
#Appropriately labels the data set with descriptive variable names. 
#From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Download the data
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
               destfile="./data/mov.zip", mode="wb")
unzip("./data/mov.zip", exdir="./data")
library(plyr)
# Read and clean features to use as column names
features = read.table("./data/uci/features.txt")
fclean=gsub("\\((.*)\\)","\\1",features$V2)
fclean=gsub("[^[:alnum:]]","_",fclean)

# Read test and train data
y_test=read.table("./data/uci/test/y_test.txt", sep=" ")
subject_test =read.table("./data/uci/test/subject_test.txt", sep=" ")
x_test=read.table("./data/uci/test/x_test.txt", colClasses = "numeric", col.names= fclean, strip.white = TRUE)
x_test$ActivityID = y_test$V1
x_test$SubjectID = subject_test$V1

y_train=read.table("./data/uci/train/y_train.txt", sep=" ")
subject_train =read.table("./data/uci/train/subject_train.txt", sep=" ")
x_train=read.table("./data/uci/train/x_train.txt", colClasses = "numeric", col.names= fclean, strip.white = TRUE)
x_train$ActivityID = y_train$V1
x_train$SubjectID = subject_train$V1

# Combine the data set
mergeds = rbind(x_test, x_train)
# Rename activity ids to corresponding activity names
# 1 WALKING
# 2 WALKING_UPSTAIRS
# 3 WALKING_DOWNSTAIRS
# 4 SITTING
# 5 STANDING
# 6 LAYING
mergeds$ActivityID = as.character(mergeds$ActivityID)
mergeds[mergeds$ActivityID == "1","ActivityID"] = "WALKING"
mergeds[mergeds$ActivityID == "2","ActivityID"] = "WALKING_UPSTAIRS"
mergeds[mergeds$ActivityID == "3","ActivityID"] = "WALKING_DOWNSTAIRS"
mergeds[mergeds$ActivityID == "4","ActivityID"] = "SITTING"
mergeds[mergeds$ActivityID == "5","ActivityID"] = "STANDING"
mergeds[mergeds$ActivityID == "6","ActivityID"] = "LAYING"

# Trim data to only include stddev and mean related data
merged_trim=mergeds[,grep("std|mean", features$V2)]
merged_trim$ActivityID = mergeds$ActivityID
merged_trim$SubjectID = mergeds$SubjectID
# Order Columns
merged_trim = select(merged_trim, SubjectID, ActivityID, tBodyAcc_mean_X:fBodyBodyGyroJerkMag_meanFreq)
# Create Summary Data Set
mt1 = group_by(merged_trim, SubjectID, ActivityID)
mt1 = summarize_all(mt1, mean)

#mt1 represents the tidy data set showing the mean of each remaining variable, grouped by Subject and Activity
