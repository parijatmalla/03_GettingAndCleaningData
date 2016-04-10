##
## This script contains the submission for course procjects for the
## course 03_GettingAndCleaningData to generate a 'tidy' dataset .
## source("run_analysis.R")
## call function run_analysis() after sourcing the R script.
## The input will be downloaded in the ./data directory of the current directory;
## The output tidy file will be created as "./data/tidy_uci_std_mean_average.txt"


## download_and_extract_dataset:
##     This functions checks if the data directory has all the data required to run the analysis.
##      If not present it will create the necessary directory and extract necessary data

prepare_data <- function () {
  setwd(".")
  zip_file_url <-
    "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  uci_data_directory <- "./data/UCI HAR Dataset"
  uci_zipfile <- "./data/uci_dataset.zip"
  ## check if the data directory is present, if not present create it.
  if (!file.exists("./data")) {
    message("./data directory not found. Creating ./data directory")
    dir.create("./data")
  }
  ##  check if the uci data directory is present in ./data, otherwise download and extract the data.
  if (!file.exists(uci_data_directory)) {
    message("UCI data directory not found. Downloading and extracting")
    download.file(zip_file_url, destfile = uci_zipfile, method = "curl")
    unzip(uci_zipfile, exdir = "./data")
  }
}


## Load the files related to  labels, subject ids, datasets in the uci data directory and return combined dataset
load_data <- function () {
  ## load the activity label names
  activity_labels <- read.table(
    "./data/UCI HAR Dataset/activity_labels.txt",
    header = FALSE,
    col.names = c("activity_id", "Activity"),
    colClasses = c("numeric", "character")
  )
  ##load features names
  features <- read.table(
    "./data/UCI HAR Dataset/features.txt",
    header = FALSE,
    col.names = c("feature_id", "Feature"),
    colClasses = c("numeric", "character")
  )
  
  ## Selecting the relevant columns (which include "mean" as well as "std", but without the "meanFreq" case (i.e. followed by the
  ## "(" punctuation)
  selected_labels <- grep("mean[[:punct:]]|std[[:punct:]]",
                          features[, 2], value = TRUE)
  
  ## load train data, set the column names and selecting the relevant columns from features data
  train_data <-
    read.table("./data/UCI HAR Dataset/train/X_train.txt", header = FALSE)
  names(train_data) <- features[, 2]
  ## subset the train_data with selected_labels
  train_data <- subset(train_data, select = selected_labels)
  ## load subject into train_data
  train_data$Subject <-
    read.table(
      "./data/UCI HAR Dataset/train/subject_train.txt",
      header = FALSE,
      col.names = "subject_id"
    )[, 1]
  ## load activity id to the train_data
  train_data$activity_id <-
    read.table(
      "./data/UCI HAR Dataset/train/y_train.txt",
      header = FALSE,
      col.names = "activity_id"
    )[, 1]
  
  
  ## load the test data, set the column names and selecting the relevant columns
  test_data <-
    read.table("./data/UCI HAR Dataset/test/X_test.txt", header = FALSE)
  names(test_data) <- features[, 2]
  test_data <- subset(test_data, select = selected_labels)
  
  test_data$Subject <-
    read.table(
      "./data/UCI HAR Dataset/test/subject_test.txt",
      header = FALSE,
      col.names = "subject_id"
    )[, 1]
  test_data$activity_id <-
    read.table(
      "./data/UCI HAR Dataset/test/y_test.txt",
      header = FALSE,
      col.names = "activity_id"
    )[, 1]
  
  ## Bind the two datasets together and merge them with the
  ## labels frame, thus pulling in the descriptive names
  train_data <- merge(train_data, activity_labels)
  test_data <- merge(test_data, activity_labels)
  merged_data <- rbind(train_data, test_data)
  
  ## We turn the Activity column into a factor
  ##merged_data$Activity <- factor(merged_data$Activity)
  
  ## order the data by subject id
  sorted_merged_data <- merged_data[order(merged_data$Subject),]
  ## return sorted merged data
  sorted_merged_data
}

#Clean up the variable Names
descriptive_names <- function (colNames) {
  # Cleaning up the variable names
  for (i in 1:length(colNames))
  {
    colNames[i] = gsub("\\()", "", colNames[i])
    colNames[i] = gsub("-std$", "StdDev", colNames[i])
    colNames[i] = gsub("-mean", "Mean", colNames[i])
    colNames[i] = gsub("^(t)", "time", colNames[i])
    colNames[i] = gsub("^(f)", "freq", colNames[i])
    colNames[i] = gsub("([Gg]ravity)", "Gravity", colNames[i])
    colNames[i] = gsub("([Bb]ody[Bb]ody|[Bb]ody)", "Body", colNames[i])
    colNames[i] = gsub("[Gg]yro", "Gyro", colNames[i])
    colNames[i] = gsub("AccMag", "AccMagnitude", colNames[i])
    colNames[i] = gsub("([Bb]odyaccjerkmag)", "BodyAccJerkMagnitude", colNames[i])
    colNames[i] = gsub("JerkMag", "JerkMagnitude", colNames[i])
    colNames[i] = gsub("GyroMag", "GyroMagnitude", colNames[i])
  }
  colNames
}
## Generate a tidy dataset with the averages of the two variable types,
## sorted by the subject and the activity
clean_data <- function (sorted_data) {
  # Appropriately label the data set with descriptive activity names.
  # Reassigning the new descriptive column names to the finalData set
  colnames(sorted_data) = descriptive_names(colnames(sorted_data))
  clean_data <- data.frame()
  mean_std_labels <-
    grep("Mean|StdDev", colnames(sorted_data), value = TRUE)
  ## walk through the possible subject-activity combinations,
  ## taking the means of the columns.
  for (subject in unique(sorted_data$Subject)) {
    for (activity in unique(sorted_data$Activity)) {
      tmp_frame <- data.frame("Subject" = subject,
                              "Activity" = activity)
      for (label in mean_std_labels) {
        data_slice <- sorted_data[sorted_data$Subject == subject &
                                    sorted_data$Activity == activity, label]
        tmp_frame[[label]] <- mean(data_slice, na.rm = TRUE)
      }
      clean_data <- rbind(clean_data, tmp_frame)
    }
  }
  
  colnames(clean_data) <- c("Subject", c("Activity", mean_std_labels))
  
  clean_data
}

# saves date to file
save_data <- function (clean_data, file_name) {
  write.table(clean_data, file = file_name, row.names = FALSE)
}

## main function that starts the analaysis and writes the file
## ./data/tidy_uci_std_mean_average.txt
run_analysis <- function () {
  tidy_file <- "./data/tidy_uci_std_mean_average.txt"
  prepare_data()
  sorted_data <- load_data()
  tidy_data <- clean_data(sorted_data)
  save_data(tidy_data, tidy_file)
  message(paste("Tidy file saved at : " , tidy_file))
  
}