---
title: "CodeBook.md"
author: "MichaelRZander"
date: "Saturday, February 21, 2015"
output: html_document
---

#Codebook.md
##Getting and Cleaning Data - Course Project
### Michael R Zander

The raw dataset was created by the UCI Machine Learning Repository [http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones]

Source:

Jorge L. Reyes-Ortiz(1,2), Davide Anguita(1), Alessandro Ghio(1), Luca Oneto(1) and Xavier Parra(2)
1 - Smartlab - Non-Linear Complex Systems Laboratory
DITEN - Università degli Studi di Genova, Genoa (I-16145), Italy. 
2 - CETpD - Technical Research Centre for Dependency Care and Autonomous Living
Universitat Politècnica de Catalunya (BarcelonaTech). Vilanova i la Geltrú (08800), Spain
activityrecognition '@' smartlab.ws 

##Study Design:

The experiments were carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, they captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments were video-recorded to label the data manually. The obtained dataset was randomly partitioned into two sets, where 70% of the volunteers were selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain.

A video of the experiment including an example of the 6 recorded activities with one of the participants can be seen in the following link: [https://www.youtube.com/watch?v=XOEN9W05_4A]

NOTE: In order to have a consistent dataset for this Coursera class, all students sourced the identical dataset from this link [https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip]

##After the file is unzipped, the dataset includes the following files. 
###Subfolders are shown with a /:

- 'subject_test.txt': Participants in the experiment selected for the test subset.
- 'subject_train.txt': Participants in the experiment selected for the training subset.
- 'features_info.txt': Shows information about the variables used on the feature vector.
- 'features.txt': List of all features.
- 'activity_labels.txt': Links the class labels with their activity name.
- 'train/X_train.txt': Training set.
- 'train/y_train.txt': Training labels.
- 'test/X_test.txt': Test set.
- 'test/y_test.txt': Test labels.

##Data Objective:
A R script called run_analysis.R is used to accomplish the following. 
1.Merge the training and the test sets to create one data set.
2.Extracts only the measurements on the mean and standard deviation for each measurement. 
3.Uses descriptive activity names to name the activities in the data set
4.Appropriately labels the data set with descriptive variable names. 
5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject. This data set is called "tidy_data_set.txt"

##Instruction set:
Data transformation steps.
### Assumes a previous install of reshape2 is available for loading, from the local user library
> library(reshape2)
> 
> ### Read and load 3 text files into 3 data.frame object(s); the subject_test, x_test and y_test files from the test subfolder
> ### Rows are interpreted as observations. Columns are interpreted as variables.
> subject_test <- read.table("test/subject_test.txt")
> X_test <- read.table("test/X_test.txt")
> y_test <- read.table("test/y_test.txt")
> 
> ### Repeat for the training data
> subject_train <- read.table("train/subject_train.txt")
> X_train <- read.table("train/X_train.txt")
> y_train <- read.table("train/y_train.txt")
> 
> ### Repeat for the activity names in order to link the class labels with their activity name: "Laying; Sitting; etc"
> activity_labels <- read.table("activity_labels.txt")
> 
> ### Repeat for the feature names. These are all available parameters from each observation using the Samsung's accelerometer and gyroscope
> features <- read.table("features.txt")

> ### Load the second column into a vector to be used as column headers for the tidy dataset.
> headers <- features[,2]
> 
> ### Add the column names for the test and train features (variables)
> names(X_test) <- headers
> names(X_train) <- headers
> 
> ### Use the function grepl to select only headers that contain the text string mean or std
> ### This generates a TRUE or FALSE logical into the vector
> ### Objective 2 - This is used to reduce the final data.frame to only have variables that analyze mean and standard deviation of observations
> mean_or_std <- grepl("mean\\(\\)|std\\(\\)", headers)
> 
> ### Use the columns filter logical test = TRUE to select (by column subset) only mean and std columns from the test and train data.frame(s)
> X_test_mean_or_std <- X_test[,mean_or_std]
> X_train_mean_or_std <- X_train[,mean_or_std]
> 
> ### Objective 1: Prepare to merge the training and test data sets to create one data set
> subject_all <- rbind(subject_test, subject_train)
> X_all <- rbind(X_test_mean_or_std, X_train_mean_or_std)
> y_all <- rbind(y_test, y_train)
> 
> ### Objective 1 and 4: Combine all vectors/data.frames into one data.frame. Apply descriptive variable names to columns 1 and 2
> merged <- cbind(subject_all, y_all, X_all)
> names(merged)[1] <- "SubjectID"
> names(merged)[2] <- "Activity"
> 
> ### Objective 5: Use the (a)aggregate function to (b) calculate the mean by the (c) SubjectID and Activity factor subsets using (d) the data.frame "merged"
> agg_all <- aggregate(. ~ SubjectID + Activity, data=merged, FUN = mean)
> 
> ### Objective 3: Provide descriptive names to the activities using the factor function for one of the 6 categorical names in column 2 of activity_labels
> agg_all$Activity <- factor(agg_all$Activity, labels=activity_labels[,2])
> 
> ### Objective 5: From the data set in step 4, create an independent tidy data set with the average of each variable for each activity and each subject.
> write.table(agg_all, file="./tidy_data_set.txt", sep="\t", row.names=FALSE)
