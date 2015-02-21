# All data sets are sourced from the "Human Activity Recognition Using Smartphones Dataset - Version 1"
# Jorge L. Reyes-Ortiz et al
#
# Data analysis objective(s):
# Create one R script called run_analysis.R that provides the following 5 deliverables.
# 1.Merges the training and the test sets to create one data set.
# 2.Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3.Uses descriptive activity names to name the activities in the data set
# 4.Appropriately labels the data set with descriptive variable names. 
# 5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
# 
# This data analysis is accomplished with the R base package and optional package installs and/or loads
#
# Assumes a previous install of reshape2 is available for loading, from the local user library
library(reshape2)

# Read and load 3 text files into 3 data.frame object(s); the subject_test, x_test and y_test files from the test subfolder
# Rows are interpreted as observations. Columns are interpreted as variables.
subject_test <- read.table("test/subject_test.txt")
X_test <- read.table("test/X_test.txt")
y_test <- read.table("test/y_test.txt")

# Repeat for the training data
subject_train <- read.table("train/subject_train.txt")
X_train <- read.table("train/X_train.txt")
y_train <- read.table("train/y_train.txt")

# Repeat for the activity names in order to link the class labels with their activity name: "Laying; Sitting; etc"
activity_labels <- read.table("activity_labels.txt")

# Repeat for the feature names. These are all available parameters from each observation using the Samsung's accelerometer and gyroscope
features <- read.table("features.txt")
# Load the second column into a vector to be used as column headers for the tidy dataset.
headers <- features[,2]

# Add the column names for the test and train features (variables)
names(X_test) <- headers
names(X_train) <- headers

# Use the function grepl to select only headers that contain the text string mean or std
# This generates a TRUE or FALSE logical into the vector
# Objective 2 - This is used to reduce the final data.frame to only have variables that analyze mean and standard deviation of observations
mean_or_std <- grepl("mean\\(\\)|std\\(\\)", headers)

# Use the columns filter logical test = TRUE to select (by column subset) only mean and std columns from the test and train data.frame(s)
X_test_mean_or_std <- X_test[,mean_or_std]
X_train_mean_or_std <- X_train[,mean_or_std]

# Objective 1: Prepare to merge the training and test data sets to create one data set
subject_all <- rbind(subject_test, subject_train)
X_all <- rbind(X_test_mean_or_std, X_train_mean_or_std)
y_all <- rbind(y_test, y_train)

# Objective 1 and 4: Combine all vectors/data.frames into one data.frame. Apply descriptive variable names to columns 1 and 2
merged <- cbind(subject_all, y_all, X_all)
names(merged)[1] <- "SubjectID"
names(merged)[2] <- "Activity"

# Objective 5: Use the (a)aggregate function to (b) calculate the mean by the (c) SubjectID and Activity factor subsets using (d) the data.frame "merged"
agg_all <- aggregate(. ~ SubjectID + Activity, data=merged, FUN = mean)

# Objective 3: Provide descriptive names to the activities using the factor function for one of the 6 categorical names in column 2 of activity_labels
agg_all$Activity <- factor(agg_all$Activity, labels=activity_labels[,2])

# Objective 5: From the data set in step 4, create an independent tidy data set with the average of each variable for each activity and each subject.
write.table(agg_all, file="./tidy_data_set.txt", sep="\t", row.names=FALSE)
