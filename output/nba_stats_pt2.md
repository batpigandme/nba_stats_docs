# NBA Stats API Part II -- Play-by-Play
Mara Averick  



#### ** **Work in Progress** **

## Streamlining the Data Retrieval Process

### Functions

In order to speed up the process of retrieving and parsing data from the stats.nba.api, it's a good idea to use functions for tasks that you'll be repeating. Functions can also help you avoid doing things that are easy to mess up, like finding and setting parameters, such as `GameID`, directly in the URL.  

#### Defining Functions in R

The structure of a user-defined function in R (see below), is as follows: a function name set using the `<-` assignment operator, argument(s) required put in parentheses `()`, and code for what the function should do and what data it should return in curly braces `{}`. 

![function structure in R](nba_stats_pt2_files/images/function_structure.png) 

Here's a simple function to multiply a variable, `x`, by 2, and return that value. Once I've defined that function, I can use it by passing it a value (argument) either directly, or indirectly by assigning a value to `x`.


```r
## name and define a function for multiplying by two
times_two <- function(x){
  return(x*2)
}

## multiply 6 by 2 with function
times_two(6)
```

```
## [1] 12
```

```r
## assign x value
x <- 4
## use function with x
times_two(x)
```

```
## [1] 8
```

#### Loading Functions Into R

As far as functions go for retrieving data from stats.nba.com goes, we don't have to start from scratch. Rajiv Shah's [_functions.R](https://github.com/rajshah4/NBA_SportVu/blob/master/_functions.R) in his [NBA_SportVu](https://github.com/rajshah4/NBA_SportVu) repo already contains much of what we'll need.

To load those functions, we'll use `source()` when loading our libraries, but you'll need to download the file in order for this to work on your own machine.


```r
## load libraries and functions from source
library(RCurl)
library(jsonlite)
library(tidyverse)
source("_functions.R")
```

If you're in RStudio, the functions should appear in the **Environment** section of your workspace (usually in the upper right-hand quadrant).  

![functions loaded into global env](nba_stats_pt2_files/images/functions_loaded.png)

#### Using `get_pbp`

We won't be using all of these functions (some of them will not work for the current season, as certain parts of the API have been depreciated), but let's take a quick look at one of them that we will be using (**`get_pbp`**) to get a better sense of what's involved.[^1]


```r
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
```

Ignoring, for the time being, the tests, this function should look pretty similar to the code we ran to get box score data. The URL has all of the same parameters, but `GameID` is set by a user-assigned value, `gameid`. Inside of `get_pbp`, data is retrieved by passing the URL to the `fromJSON` function (from the [**`jsonlite**`](https://github.com/jeroenooms/jsonlite) package).

So, if we wanted to get the play-by-play data for the same game we looked at in the box score section, we would do the following:

```r
## set gameid
gameid <- "0041500407"
## retrieve pbp data
pbp <- get_pbp(gameid)

## peek at the data
head(pbp)
```

```
##      GAME_ID EVENTNUM EVENTMSGTYPE EVENTMSGACTIONTYPE PERIOD WCTIMESTRING
## 1 0041500407        0           12                  0      1      8:11 PM
## 2 0041500407        1           10                  0      1      8:11 PM
## 3 0041500407        2            2                 78      1      8:12 PM
## 4 0041500407        3            4                  0      1      8:12 PM
## 5 0041500407        4            2                 58      1      8:12 PM
## 6 0041500407        5            4                  0      1      8:12 PM
##   PCTIMESTRING                            HOMEDESCRIPTION
## 1        12:00                                       <NA>
## 2        12:00 Jump Ball Ezeli vs. Thompson: Tip to James
## 3        11:39                                       <NA>
## 4        11:36                Curry REBOUND (Off:0 Def:1)
## 5        11:18         MISS Ezeli 7' Turnaround Hook Shot
## 6        11:17                                       <NA>
##   NEUTRALDESCRIPTION               VISITORDESCRIPTION SCORE SCOREMARGIN
## 1               <NA>                             <NA>  <NA>        <NA>
## 2               <NA>                             <NA>  <NA>        <NA>
## 3               <NA> MISS Smith 5' Floating Jump Shot  <NA>        <NA>
## 4               <NA>                             <NA>  <NA>        <NA>
## 5               <NA>                             <NA>  <NA>        <NA>
## 6               <NA>      James REBOUND (Off:0 Def:1)  <NA>        <NA>
##   PERSON1TYPE PLAYER1_ID  PLAYER1_NAME PLAYER1_TEAM_ID PLAYER1_TEAM_CITY
## 1           0          0          <NA>            <NA>              <NA>
## 2           4     203105  Festus Ezeli      1610612744      Golden State
## 3           5       2747      JR Smith      1610612739         Cleveland
## 4           4     201939 Stephen Curry      1610612744      Golden State
## 5           4     203105  Festus Ezeli      1610612744      Golden State
## 6           5       2544  LeBron James      1610612739         Cleveland
##   PLAYER1_TEAM_NICKNAME PLAYER1_TEAM_ABBREVIATION PERSON2TYPE PLAYER2_ID
## 1                  <NA>                      <NA>           0          0
## 2              Warriors                       GSW           5     202684
## 3             Cavaliers                       CLE           0          0
## 4              Warriors                       GSW           0          0
## 5              Warriors                       GSW           0          0
## 6             Cavaliers                       CLE           0          0
##       PLAYER2_NAME PLAYER2_TEAM_ID PLAYER2_TEAM_CITY PLAYER2_TEAM_NICKNAME
## 1             <NA>            <NA>              <NA>                  <NA>
## 2 Tristan Thompson      1610612739         Cleveland             Cavaliers
## 3             <NA>            <NA>              <NA>                  <NA>
## 4             <NA>            <NA>              <NA>                  <NA>
## 5             <NA>            <NA>              <NA>                  <NA>
## 6             <NA>            <NA>              <NA>                  <NA>
##   PLAYER2_TEAM_ABBREVIATION PERSON3TYPE PLAYER3_ID PLAYER3_NAME
## 1                      <NA>           0          0         <NA>
## 2                       CLE           5       2544 LeBron James
## 3                      <NA>           0          0         <NA>
## 4                      <NA>           0          0         <NA>
## 5                      <NA>           0          0         <NA>
## 6                      <NA>           0          0         <NA>
##   PLAYER3_TEAM_ID PLAYER3_TEAM_CITY PLAYER3_TEAM_NICKNAME
## 1            <NA>              <NA>                  <NA>
## 2      1610612739         Cleveland             Cavaliers
## 3            <NA>              <NA>                  <NA>
## 4            <NA>              <NA>                  <NA>
## 5            <NA>              <NA>                  <NA>
## 6            <NA>              <NA>                  <NA>
##   PLAYER3_TEAM_ABBREVIATION
## 1                      <NA>
## 2                       CLE
## 3                      <NA>
## 4                      <NA>
## 5                      <NA>
## 6                      <NA>
```

### Dealing with Time


```r
## load lubridate
library(lubridate)

## convert PCTIME to seconds
pbp$pcsecs <- period_to_seconds(ms(pbp$PCTIMESTRING))
## get period seconds elapsed
pbp$period_sec_elapsed <- abs((pbp$pcsecs - 720))
## convert to game seconds elapsed
pbp$game_sec_elapsed <- abs((pbp$pcsecs - 720)) + (((as.numeric(pbp$PERIOD)) - 1) * 720)
## convert to tenths of seconds for Range params
pbp$range_clock <- (pbp$game_sec_elapsed * 10)
```


```r
pbp$range_clock2 <- (abs(((period_to_seconds(ms(pbp$PCTIMESTRING))) - 720)) + (((as.numeric(pbp$PERIOD)) - 1) * 720)) * 10
```

===  
**References**

[^1]: More detail on all of these functions, including `get_pbp`, can be found in Rajiv Shah's post: [“Merging NBA Play by Play data with SportVU data”](http://projects.rajivshah.com/sportvu/PBP_NBA_SportVu.html).
