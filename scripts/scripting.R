options(stringsAsFactors = FALSE)

## load libraries and functions from source
library(RCurl)
library(jsonlite)
library(tidyverse)
source("_functions.R")

## get play by play
get_pbp <- function(gameid){
  #Grabs the play by play data from the NBA site
  URL1 <- paste("http://stats.nba.com/stats/playbyplayv2?EndPeriod=10&EndRange=55800&GameID=",gameid,"&RangeType=2&StartPeriod=1&StartRange=0",sep = "")
  the.data.file<-fromJSON(URL1)
  test <-the.data.file$resultSets$rowSet
  test2 <- test[[1]]
  test3 <- data.frame(test2)
  coltest <- the.data.file$resultSets$headers
  colnames(test3) <- coltest[[1]]
  return (test3)
}
## set gameid
gameid <- "0041500407"
## retrieve pbp data
pbp <- get_pbp(gameid)

## convert to tbl_df
pbp <- tbl_df(pbp)

## glimpse the data
glimpse(pbp)

## get event record by EVENTNUM
event_212 <- filter(pbp, EVENTNUM == "212")

## look at EVENTMSG and ACTIONTYPE
select(event_212, 1:4)

## look at description
select(event_212, 8)

## get unique sets of EVENTMSG and ACTION TYPEs
eventmsg_combos <- pbp %>%
  select(one_of(c("EVENTMSGTYPE", "EVENTMSGACTIONTYPE"))) %>%
  distinct()

## load lubridate
library(lubridate)

## convert PCTIME to seconds
pbp$pcsecs <- period_to_seconds(ms(pbp$PCTIMESTRING))
## get period seconds elapsed
pbp$period_sec_elapsed <- abs((pbp$pcsecs - 720))
## convert to game seconds elapsed
pbp$game_sec_elapsed <- abs((pbp$pcsecs - 720)) + (((as.numeric(pbp$PERIOD)) - 1) * 720)
## convert to tenths of seconds for Range params
pbp$range_clock1 <- (pbp$game_sec_elapsed * 10)

## load lubridate
library(lubridate)

## convert PCTIMESTRING for Range params
pbp$range_clock <- (abs(((period_to_seconds(ms(pbp$PCTIMESTRING))) - 720)) + (((as.numeric(pbp$PERIOD)) - 1) * 720)) * 10

## filter pbp by EVENTMSGTYPE 8 (subs) OR start of period (12)
pbp_subs <- pbp %>%
  filter(EVENTMSGTYPE == "8" | EVENTMSGTYPE == "12")

get_boxtrad <- function(gameid, startrange, endrange){
  #Grabs the box score data from NBA site
  URL1 <- paste("http://stats.nba.com/stats/boxscoretraditionalv2?EndPeriod=1&EndRange=",endrange,"&GameID=",gameid,"&RangeType=2&StartPeriod=1&StartRange=",startrange,"", sep = "")
  df<-fromJSON(URL1)
  test <- unlist(df$resultSets$rowSet[[1]])
  test1 <- as.data.frame(test)
  test1[, c(10,11,13,14,16,17,19:28)] <- sapply(test1[, c(10,11,13,14,16,17,19:28)], as.integer)
  test1[, c(12,15,18)] <- sapply(test1[, c(12,15,18)], as.numeric)
  test2 <- tbl_df(test1)
  headers <- unlist(unlist(df$resultSets$headers[[1]]))
  names(test2)[1:28] = c(headers)
  return(test2)
}

## set arguments
gameid <- "0041500407"
startrange <- "0"
endrange <- "3020"

## get_boxtrad
boxscore_3020 <- get_boxtrad(gameid, startrange, endrange)

## glimpse results
boxscore_3020$PLAYER_NAME

## load jsonlite library
library(jsonlite)

## get NBA personIds from JSON
players <- fromJSON("http://data.nba.net/data/10s/prod/v1/2016/players.json")
ps <- lapply(players, function(x) x$standard)

firstName <- unlist(lapply(ps, function(x) x[[1]]))
lastName <- unlist(lapply(ps, function(x) x[[2]]))
personId <- unlist(lapply(ps, function(x) x[[3]]))
teamId <- unlist(lapply(ps, function(x) x[[4]]))

## load tidyverse
library(tidyverse)
## create data frame
nba_personIds <- data_frame(firstName, lastName, personId, teamId)

## create variable for each row with the range_clock value of the previous substitution
pbp_subs_w_lag <- pbp_subs %>%
  mutate(prev = (lag(range_clock) + 1)) # 1 sec beyond prev sub
## set NA to 0 for start
pbp_subs_w_lag$prev[which(is.na(pbp_subs_w_lag$prev))] <- 0

## rename to pbp_subs
pbp_subs <- pbp_subs_w_lag

## function to return the players on the court during time duration
get_players <- function(gameid, endperiod, startperiod, endrange, startrange){
  URL1 <- paste("http://stats.nba.com/stats/boxscoretraditionalv2?EndPeriod=",endperiod,"&EndRange=",endrange,"&GameID=",gameid,"&RangeType=2&StartPeriod=",startperiod,"&StartRange=",startrange,"", sep = "")
  df <- fromJSON(URL1)
  test <- unlist(df$resultSets$rowSet[[1]])
  test1 <- as.data.frame(test)
  player_ids <- as.character(test1$V5)
}
## align params by row

gameid <- pbp_subs$GAME_ID
endperiod <- pbp_subs$PERIOD
startperiod <- pbp_subs$PERIOD
endrange <- pbp_subs$range_clock
startrange <- pbp_subs$prev

## get full boxscore for game
endrange <- "28800"
boxscore_full <- get_boxtrad(gameid, startrange, endrange)


## define function for empty as NA
empty_as_na <- function(x){
  if("factor" %in% class(x)) x <- as.character(x)
  ifelse(as.character(x)!="", x, NA)}

## run on full boxscore
boxscore_full <- boxscore_full %>%
  mutate_each(funs(empty_as_na))

## add true false start variable to boxscore
boxscore_full$START <- ifelse(!is.na(boxscore_full$START_POSITION), TRUE, FALSE)


## select subset for lineup dataframe
lineup <- select(boxscore_full, one_of(c("PLAYER_ID", "START")))

## spread for each player id to be its own column
lineup <- spread(lineup, PLAYER_ID, START)
lineup <- lineup %>%
  mutate(GAME_ID = "0041500407")

lineup <- lineup %>%
  mutate(EVENTNUM = "0")


### NOTE THINK BELOW HERE IS WONKY ##

players_on <- function(URL){
  #Grabs the box score data from NBA site
  URL1 <- pbp_subs$subURL
  df<-fromJSON(URL1)
  test <- unlist(df$resultSets$rowSet[[1]])
  test1 <- as.data.frame(test)
  test1[, c(10,11,13,14,16,17,19:28)] <- sapply(test1[, c(10,11,13,14,16,17,19:28)], as.integer)
  test1[, c(12,15,18)] <- sapply(test1[, c(12,15,18)], as.numeric)
  test2 <- tbl_df(test1)
  headers <- unlist(unlist(df$resultSets$headers[[1]]))
  names(test2)[1:28] = c(headers)
  return(test2$PLAYER_NAME)
}

