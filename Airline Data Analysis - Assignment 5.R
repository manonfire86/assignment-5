### Load tidyr and dplyr

library(tidyr)
library(dplyr)

### Load Data after placing the csv into your working directory

airlinedata = read.csv('Airline Data.csv')

### This section parses the data frame removing all NA rows and maintaining only complete cases. The columns are then renamed for the purpose of tidying the data frame.

airlinedata = airlinedata[complete.cases(airlinedata),]
colnames(airlinedata) = c("State","Flight Status","Flight LA","Flight PH","Flight SD","Flight SF","Flight SEA")

## This section converts empty rows to NA and down fills those rows so that all rows have respective state values. This is necessary for tidying the data frame later in the process.

airlinedata$State[as.character(airlinedata$State) == ""] = NA
airlinedata = airlinedata %>% fill(State)

## Using the newly filled 'State' column and the 'Flight Status' column, I create a unique key in order to allow for the creation of a long format tidy data frame.

airlinedata$Key = paste(airlinedata$State,airlinedata$`Flight Status`,sep="_")

## The first two columns are removed to eliminate redundancy and create a concise data frame.

airlinedata = airlinedata[,-1:-2]

### In this section, I tidy the data by filtering only for Delay times and then I convert the data frame to a long format and then a wide format using gather and spread. This allows for the creation of a unique data frame that has each flight's delay time, for each airport, adjacent to each other.

delaytrans = airlinedata %>%
  filter(Key == "ALASKA_delayed" | Key == "AM WEST_delayed") %>%
  gather(Destination,Delay,`Flight LA`:`Flight SEA`) %>%
  spread(key = Key,value =Delay)

## I calculate the absolute difference and create a flag indicating which airport has quicker flights. Looking at the two columns, you can determine the absolute time advantage that one airport has over the other.

delaytrans$Delay_Difference = abs(delaytrans$ALASKA_delayed - delaytrans$`AM WEST_delayed`)
delaytrans$Speed_Status = if_else(delaytrans$ALASKA_delayed>delaytrans$`AM WEST_delayed`,"AM is Faster","Alaska is Faster")

## Print Results
print(delaytrans)

## Conclusion: 80% of the flights from the Alaska Airport have a shorter delay time than the AM West Airport. On average, the delay time for Alaska is 100.2 Minutes where as the delay time on average for AM West is 157.4.

averagedelayAlaska = sum(delaytrans$ALASKA_delayed)/length(delaytrans$ALASKA_delayed)
averagedelayAMWest = sum(delaytrans$`AM WEST_delayed`)/length(delaytrans$`AM WEST_delayed`)

print(paste("The Delay Time for Alaska Airport is:",averagedelayAlaska,"minutes",sep = " "))
print(paste("The Delay Time for AM West Airport is:",averagedelayAMWest,"minutes",sep = " "))
