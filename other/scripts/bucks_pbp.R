library(readr)
## read in pbp
pbp <- read_csv("other/data/bucks/pbp.csv")
## read in games
games <- read_csv("other/data/bucks/games.csv")
## read in boxscores
advanced_boxscores <- read_csv("other/data/bucks/advanced_boxscores.csv", col_types = cols(MIN = col_character()))

## filter games to this season
library(tidyverse)
pbp_1617 <- pbp %>%
  mutate(GAME_NUMERIC = as.numeric(GAME_ID)) %>%
  filter(GAME_NUMERIC >= 21600008) %>%
  filter(GAME_NUMERIC < 41400121)

games_1617 <- games %>%
  mutate(GAME_NUMERIC = as.numeric(GAME_ID)) %>%
  filter(GAME_NUMERIC >= 21600008) %>%
  filter(GAME_NUMERIC < 41400121)

box_1617 <- advanced_boxscores %>%
  mutate(GAME_NUMERIC = as.numeric(GAME_ID)) %>%
  filter(GAME_NUMERIC >= 21600008) %>%
  filter(GAME_NUMERIC < 41400121)

## get subs and start/end period only
subs_pbp <- pbp_1617 %>%
  filter(EVENTMSGTYPE == 8)

## home vs away games
home_1617 <- games_1617 %>%
  filter(AT_HOME == 1)

away_1617 <- games_1617 %>%
  filter(AT_HOME == 0)

home_gid <- home_1617$GAME_ID
away_gid <- away_1617$GAME_ID

## home vs away pbp
home_pbp <- pbp_1617 %>%
  filter(GAME_ID %in% home_gid)

away_pbp <- pbp_1617 %>%
  filter(GAME_ID %in% away_gid)


### playing around
home_v_min <- home_pbp %>%
  filter(GAME_ID == "0021600978")

home_players_v_min <- home_v_min %>%
  gather("player_num", "pid_on", 36:40)

write.csv(home_players_v_min, file="other/data/bucks/home_players_v_min.csv", row.names = FALSE)

home_players_pbp <- home_pbp %>%
  gather("player_num", "pid_on", 36:40)

away_players_pbp <- away_pbp %>%
  gather("player_num", "pid_on", 41:45)

write.csv(home_players_pbp, file="other/data/bucks/home_players_pbp.csv", row.names = FALSE)
write.csv(away_players_pbp, file="other/data/bucks/away_players_pbp.csv", row.names = FALSE)
