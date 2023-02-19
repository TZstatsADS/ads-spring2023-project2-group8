library(dplyr)

data = read.csv("./data/Affordable_Housing_Production_by_Building.csv")

summary(data)

data <- na.omit(data)

summary(data)

data$Project.Start.Date <- as.Date(data$Project.Start.Date, "%m/%d/%Y")

data$Start.Year <- as.numeric(format(data$Project.Start.Date,'%Y'))

data$StartYear <- data$Start.Year

df <- data[,c("Studio.Units","X1.BR.Units","X2.BR.Units","X3.BR.Units", "X4.BR.Units", "X5.BR.Units", "X6.BR..Units","Total.Units", "Start.Year", "Latitude", "Longitude")] 
names(df)[7] = "X6.BR.Units"
names(df) = c("Studio_Units","One_Bedroom_Units","Two_Bedroom_Units","Three_Bedroom_Units", "Four_Bedroom_Units", "Five_Bedroom_Units", "Six_Bedroom_Units","Total_Units", "Start Year", "Latitude", "Longitude")


write.csv(df, file = "./out/units_cleaned.csv", row.names = FALSE)

