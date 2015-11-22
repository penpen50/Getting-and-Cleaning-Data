#https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

setwd("J:/Cousera/Getting and Cleaning Data")

#Download Data file
fileURL="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" 
download.file(fileURL,"Dataset.zip")
dateDownloaded=date()

unzip("Dataset.zip", exdir = "Dataset")

# Look for directory

path=file.path("./Dataset" , "UCI HAR Dataset")
files=list.files(path, recursive=TRUE)
files

#Read the Activity files

dataActivityTest  <- read.table(file.path(path, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path, "train", "Y_train.txt"),header = FALSE)

#Read Subject files
dataSubjectTrain <- read.table(file.path(path, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path, "test" , "subject_test.txt"),header = FALSE)

#read Feature File
dataFeaturesTest  <- read.table(file.path(path, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path, "train", "X_train.txt"),header = FALSE)

#check dimensions
str(dataActivityTest)
str(dataActivityTrain)
str(dataSubjectTrain)
str(dataSubjectTest)
str(dataFeaturesTest)
str(dataFeaturesTrain)

#Merge training data and test data
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

#Set names to variables
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path, "features.txt"),head=FALSE) #Get features
names(dataFeatures)<- dataFeaturesNames$V2

#combine dataSubject,dataActivity and features to one data frame
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)


#####Part 2
#Extracts only the measurements on the mean and standard deviation for each measurement. 

subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]t 

#Subset by feature
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)

str(Data)

#####Part 3
#Uses descriptive activity names to name the activities in the data set

ActivityLabels <- read.table(file.path(path, "activity_labels.txt"),header = FALSE)

#Factorize Activity and subject
Data$activity <- factor(Data$activity, levels = ActivityLabels[,1], labels = ActivityLabels[,2])
Data$subject <- as.factor(Data$subject)

head(Data$activity,30)


#####Part 4
#Appropriately labels the data set with descriptive variable names. 
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

names(Data)

#####Part 5
#From the data set in step 4, creates a second, independent tidy data set with 
#the average of each variable for each activity and each subject.
library(plyr);
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)

#Produce cookbook
install.packages("knitr")
library(knitr)
knit2html("Codebook.Rmd")

