"Getting and Cleaning Data"
=======================================
This repository contains the scripts and markdown files required for the course project submission to "Getting and Cleaning Data" course in coursera. 


### How to run the analysis

First of all source download and source run_analysis.R file in your R session:

**source("run_analysis.R")**

Triggere the analysis by calling the run_analysis function:

**run_analysis()**

__run_analysis()__ is the main function which call other helpful functions to download, extract, clean the data and write a tidy file.


### Helper functions called by the run_analysis() internally are explained below:

**prepare_data():** Checks presence of "data" folder  and UCI data set directory inside "data" folder". When these are not                    present it will create "data" folder downloads the zip from                      
                https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" and extracts it   
                inside "data" folder to create ./data/UCI HAR Dataset. 

**load_data():** load the data downloaded as part of prepare_data() in all the relevant files, subject ids, activity ids,    
            merging the activity labels and selecting the "*-std()" and "*-mean()" columns. 
            Then merge both the training and testing data sets, returning the result sorted by "Subject".descriptive_names

**descriptive_names(colNames):**Input for this is column names of dataset from load_data(). 
                            It uses regular expressions to add descriptive names to the colNames provided as input and
                            returns the colNames with descriptive names. 

**clean_data():** The sorted data set obtained from loaddata(). 
              Add descriptive column names to the dataset passing colNames to descriptive_names function.
              The loop through the subject-activity combinations, taking the means of the resulting selections. 
              Return tidy data frame,  with subjectID, activity and all columns containing  Mean and StdDev (which are  
              descriptive_names for mean and std in input data.).

**save_data(clean_data, file_name):** Gets input clean dataset from clean_data() as clean_data and file name to save it 
                                to as file_name and save the clean data frame using the write.table() function as asked 
                                for by the project requirement.