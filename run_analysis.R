
library(data.table)
library(dplyr)

#Setting the working directory
setwd("C:\\Users\\Dell\\Desktop\\datasciencecoursera")

#Downloading UCI data files from the web, unzip them, and specify time/date settings
URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destFile <- "C:\\Users\\Dell\\Desktop\\datasciencecoursera\\CourseDataset.zip"
if (!file.exists(destFile)){
  download.file(URL, destfile = destFile, mode='wb')
}
if (!file.exists("C:\\Users\\Dell\\Desktop\\datasciencecoursera\\CourseDataset.zip\\UCI_HAR_Dataset")){
  unzip(destFile)
}
dateDownloaded <- date()

#reading files
setwd("C:\\Users\\Dell\\Desktop\\datasciencecoursera\\UCI_HAR_Dataset")

features= read.table("features.txt", col.names = c("n", "functions"))
activity= read.table("activity_labels.txt", col.names = c("code","activities"))
x_test= read.table("test\\X_test.txt", col.names = features$functions)
subject_test <- read.table("test\\subject_test.txt", col.names = "subject")
y_test <- read.table("test\\y_test.txt", col.names = "code")
subject_train <- read.table("train\\subject_train.txt", col.names = "subject")
x_train <- read.table("train\\X_train.txt", col.names = features$functions)
y_train <- read.table("train\\y_train.txt", col.names = "code")



#Merging the training and testing dataset to form one dataset
x=rbind(x_train,x_test)
y=rbind(y_train,y_test)
subject=rbind(subject_train,subject_test)
data=cbind(subject,y,x)

#Extracting only the mean and standard deviation of each measurement
selected_data= data %>% select(subject,code,contains(c("mean", "std")))

#Replacing the activity numbers with their respective descriptive names
selected_data$code=activity[selected_data$code,2]

#Using descriptive names for variables
names(selected_data) <- make.names(names(selected_data))
names(selected_data) <- gsub('Acc',"Acceleration",names(selected_data))
names(selected_data) <- gsub('GyroJerk',"AngularAcceleration",names(selected_data))
names(selected_data) <- gsub('Gyro',"AngularSpeed",names(selected_data))
names(selected_data) <- gsub('Mag',"Magnitude",names(selected_data))
names(selected_data) <- gsub('^t',"TimeDomain.",names(selected_data))
names(selected_data) <- gsub('^f',"FrequencyDomain.",names(selected_data))
names(selected_data) <- gsub('\\.mean',".Mean",names(selected_data))
names(selected_data) <- gsub('\\.std',".StandardDeviation",names(selected_data))
names(selected_data) <- gsub('Freq\\.',"Frequency.",names(selected_data))
names(selected_data) <- gsub('Freq$',"Frequency",names(selected_data))

#Creating an independent dataset with the average of each variable for subject and code
Data2<-aggregate(. ~subject + code, selected_data, mean)
Data2<-Data2[order(Data2$subject,Data2$code), ]

#Creating the tidy dataset from write.table function
tidyData=write.table(Data2, file = "tidyData.txt", row.names = FALSE )
