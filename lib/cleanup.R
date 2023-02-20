library('dplyr')
Housing_Maintenance_df = read.table("./data/Housing_Maintenance_Code_Complaints.csv",sep=',',header=T)
Housing_Maintenance_df=Housing_Maintenance_df[c("BoroughID","Zip","ReceivedDate","StatusID","StatusDate")]
#add year to dataset
Housing_Maintenance_df$year=substr(Housing_Maintenance_df$ReceivedDate,7,10)
Housing_Maintenance_df$year=as.integer(Housing_Maintenance_df$year)

#Use data from 2014-2022
Housing_Maintenance_after2014_df= filter(Housing_Maintenance_df, year>=2014)
Housing_Maintenance_after2014_df= filter(Housing_Maintenance_after2014_df,year<2023)

#count complaints by year
year_complaint_df_b=Housing_Maintenance_after2014_df %>% count(year, BoroughID) #return a df with columns year and n (nummber of complaints)
years_b=year_complaint_df_b$year
BoroughID_b = year_complaint_df_b$BoroughID
num_of_complaints_b =year_complaint_df_b$n
write.csv(year_complaint_df_b, file = "./out/year_borough_complaint_df.csv", row.names = FALSE)

year_complaint_df=Housing_Maintenance_after2014_df %>% count(year) #return a df with columns year and n (nummber of complaints)
years=year_complaint_df$year
num_of_complaints=year_complaint_df$n
write.csv(year_complaint_df, file = "./out/year_complaint_df.csv", row.names = FALSE)


#create a finished df
Housing_Maintenance_after2014_finished_df=filter(Housing_Maintenance_after2014_df,StatusID==2)
year_complaint_finished_df_b =Housing_Maintenance_after2014_finished_df %>% count(year, BoroughID)
num_of_finished_complaints_b =year_complaint_finished_df_b$n
finished_rate_b =num_of_finished_complaints_b/num_of_complaints_b
year_borough_finished_rate_df=data.frame(cbind(years, BoroughID_b, finished_rate_b))
names(year_borough_finished_rate_df)[2] = 'BoroughID'
names(year_borough_finished_rate_df)[3] = 'finished_rate'
write.csv(year_borough_finished_rate_df, file = "./out/year_borough_finished_rate_df.csv", row.names = FALSE)

Housing_Maintenance_after2014_finished_df=filter(Housing_Maintenance_after2014_df,StatusID==2)
year_complaint_finished_df=Housing_Maintenance_after2014_finished_df %>% count(year)
num_of_finished_complaints=year_complaint_finished_df$n
finished_rate=num_of_finished_complaints/num_of_complaints
year_finished_rate_df=cbind(years, finished_rate)
write.csv(year_finished_rate_df, file = "./out/year_finished_rate_df.csv", row.names = FALSE)

# add finished_days
Housing_Maintenance_after2014_finished_df$ReceivedDate=as.Date(Housing_Maintenance_after2014_finished_df$ReceivedDate,"%m/%d/%Y")
Housing_Maintenance_after2014_finished_df$StatusDate=as.Date(Housing_Maintenance_after2014_finished_df$StatusDate,"%m/%d/%Y")
Housing_Maintenance_after2014_finished_df$finish_days=difftime(Housing_Maintenance_after2014_finished_df$StatusDate,Housing_Maintenance_after2014_finished_df$ReceivedDate,units = "days")

year_BoroughID_finished_days_df <- Housing_Maintenance_after2014_finished_df %>% group_by(year, BoroughID) %>% 
  summarise(mean_days=mean(finish_days),
            .groups = 'drop')  

year_finished_days_df <- Housing_Maintenance_after2014_finished_df %>% group_by(year) %>% 
  summarise(mean_days=mean(finish_days),
            .groups = 'drop')  
write.csv(year_BoroughID_finished_days_df, file = "./out/year_BoroughID_finished_days_df.csv", row.names = FALSE)

write.csv(year_finished_days_df, file = "./out/year_finished_days_df.csv", row.names = FALSE)

