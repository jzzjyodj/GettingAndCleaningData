# You should create one R script called run_analysis.R that does the following. 
# 
# Merges the training and the test sets to create one data set.
# 
# Extracts only the measurements on the mean and standard deviation for each measurement. 
# 
# Uses descriptive activity names to name the activities in the data set
# 
# Appropriately labels the data set with descriptive variable names. 
# 
# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

#integrate packages and read data
packages <- c("data.table", "reshape2")
sapply(packages, require, character.only=TRUE, quietly=TRUE)
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")


#get train data

xtrain<-read.table('./UCI HAR Dataset/train/X_train.txt', header=FALSE)
xtrain
ytrain<-read.table('./UCI HAR Dataset/train/y_train.txt', header=FALSE)
ytrain

#test data
xtest<-read.table('./UCI HAR Dataset/test/X_test.txt', header=FALSE)
ytest<-read.table('./UCI HAR Dataset/test/y_test.txt', header=FALSE)

#activity data
activity<-read.table('./UCI HAR Dataset/activity_labels.txt', header=FALSE)
activity
#features data
features<-read.table('./UCI HAR Dataset/features.txt', header=FALSE)

#subject data
subtrain<-read.table('./UCI HAR Dataset/train/subject_train.txt', header=FALSE)
subtrain<-subtrain%>%
  rename(subjectID=V1)
subtest<-read.table('./UCI HAR Dataset/test/subject_test.txt', header=FALSE)
subtest<-subtest%>%
  rename(subjectID=V1)

#add col names to both train and test data sets
features<-features[,2]
features
#transpose data set
feat_transpose <- t(features)

colnames(xtrain)<-feat_transpose
colnames(xtest)<-feat_transpose
# rename activity columns to id and action
library(dplyr)
colnames(activity)<-c('id','actions')
activity

#bind to row xtrain and xtest
combine_X <- rbind(xtrain,xtest)
#bind to row ytrain and ytest
combine_Y <- rbind(ytrain,ytest)
combine_Y
#bind to row subject train and test
combine_Subj <- rbind(subtrain,subtest)

#combine all combines
final_combine <- cbind(combine_X,combine_Y,combine_Subj)
head(final_combine)

#merge table above with activity 
df<-merge(final_combine, activity,by.x = 'V1',by.y = 'id')
df

#get mean and stdev

colNames <- colnames(df)
df2 <- df %>%
  select(actions, subjectID, grep("\\bmean\\b|\\bstd\\b", colNames))

#transform activity to a factor variable 
df2$actions <- as.factor(df2$actions)

View(df2)

colnames(df2)<-gsub("^t", "time", colames(df2))
colnames(df2)<-gsub("^f", "frequency", colnames(df2))
colnames(df2)<-gsub("Acc", "Accelerometer", colnames(df2))
colnames(df2)<-gsub("Gyro", "Gyroscope", colnames(df2))
colnames(df2)<-gsub("Mag", "Magnitude", colnames(df2))
colnames(df2)<-gsub("BodyBody", "Body", colnames(df2))

df2

df3<-aggregate(. ~subjectID + actions, df2, mean)
df3

View(df3)
#Write to text file

write.table(df3, file = "tidydata.txt",row.name=FALSE)