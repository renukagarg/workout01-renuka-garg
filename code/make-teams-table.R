# title: "make-teams-table"
# description: "process and package nba2018.csv data"
# input: nba2018.csv
# output: nba2018-teams.csv efficiency-summary.txt


data <- read.csv("../data/nba2018.csv")
data$experience <- as.character(data$experience)
for (i in 1:length(data$experience)){
  if(data$experience[i] == "R"){
    data$experience[i] <- "0"
  }
}
data$experience <- as.integer(data$experience)

for (i in 1:length(data$salary)){
  data$salary[i] <- data$salary[i]/1000000
}

data$position <- as.character(data$position)
for(i in 1:length(data$position)){
  if(data$position[i] == "C"){
    data$position[i] <- "center"
  }
  if(data$position[i] == "PF"){
    data$position[i] <- "power_fwd"
  } 
  if(data$position[i] == "PG"){
    data$position[i] <- "point_guard"
  } 
  if(data$position[i] == "SF"){
    data$position[i] <- "small_fwd"
  } 
  if(data$position[i] == "SG"){
    data$position[i] <- "shoot_guard"
  }
}

library(dplyr)
missed_fg <- data$field_goals_atts - data$field_goals
missed_ft <- data$points1_atts - data$points1
rebounds <- data$off_rebounds + data$def_rebounds

data <- mutate(data, missed_fg, missed_ft, rebounds)
efficiency <- (data$points + data$rebounds + data$assists + data$steals + data$blocks - data$missed_fg - data$missed_ft - data$turnovers)/data$games
mutate(data, efficiency)

effsum <- summary(efficiency)
sink("../output/efficiency-summary.txt", append = TRUE)
effsum
sink()


experience <- summarize(group_by(data, team), experience = sum(experience))
data$salary <- round(data$salary, 2)
salary <- summarize(group_by(data, team), salary = sum(salary))
points3 <- summarize(group_by(data, team), points3 = sum(points3))
points2 <- summarize(group_by(data, team), points2 = sum(points2))
points1 <- summarize(group_by(data, team), points1 = sum(points1))
points <- summarize(group_by(data, team), points = sum(points))
off_rebounds <- summarize(group_by(data, team), off_rebounds = sum(off_rebounds))
def_rebounds <- summarize(group_by(data, team), def_rebounds = sum(def_rebounds))
assists <- summarize(group_by(data, team), assists = sum(assists))
steals <- summarize(group_by(data, team), steals = sum(steals))
blocks <- summarize(group_by(data, team), blocks = sum(blocks))
turnovers <- summarize(group_by(data, team), turnovers = sum(turnovers))
fouls <- summarize(group_by(data, team), fouls = sum(fouls))
efficiency <- summarize(group_by(data, team), efficiency = sum(efficiency))

teams <- data.frame(experience, salary[ , 2], points3[ , 2], points2[ , 2], points1[ , 2], 
                    points[ , 2], off_rebounds[ , 2], def_rebounds[ , 2], 
                    assists[ , 2], steals[ , 2], blocks[ , 2], turnovers[ , 2], fouls[ , 2],
                    efficiency[ , 2])

sink("../data/teams-summary.txt", append = TRUE)
teams
sink()

write.csv(teams, file = "../data/nba2018-teams.csv")
