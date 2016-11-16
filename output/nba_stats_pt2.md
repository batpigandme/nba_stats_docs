# NBA Stats API Part II -- Play-by-Play
Mara Averick  



#### ** **Work in Progress** **

## Streamlining the Data Retrieval Process

### Functions

In order to speed up the process of retrieving and parsing data from the stats.nba.api, it's a good idea to use functions for tasks that you'll be repeating. Functions can also help you avoid doing things that are easy to mess up, like finding and setting parameters, such as `GameID`, directly in the URL.  

#### Defining Functions in R 

In basic tersm, the structure of a user-defined function in R (see below), is as follows: a function name set using the `<-` assignment operator, argument(s) required put in parentheses `()`, and code for what the function should do and what data it should return in curly braces `{}`. 

More formally, [Hadley Wickham](http://adv-r.had.co.nz/Functions.html#function-components) defines the three components of a function as:[^1]  

* the `body()`, the code inside the function.  

* the `formals()`, the list of arguments which controls how you can call the function.  

* the `environment()`, the “map” of the location of the function’s variables.

![function structure in R](nba_stats_pt2_files/images/function_structure.png) 

Here's a simple function to multiply a variable, `x`, by 2, and return that value. Once I've defined that function, I can use it by passing it a value (argument) either directly, or indirectly by assigning a value to `x`.


```r
## name and define a function for multiplying by two
times_two <- function(x){
  return(x * 2)
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
## set up env't preferences
options(stringsAsFactors = FALSE)

## load libraries and functions from source
library(RCurl)
library(jsonlite)
library(tidyverse)
source("_functions.R")
```

If you're in RStudio, the functions should appear in the **Environment** section of your workspace (usually in the upper right-hand quadrant).  

![functions loaded into global env](nba_stats_pt2_files/images/functions_loaded.png)

#### Using `get_pbp`

We won't be using all of these functions (some of them will not work for the current season, as certain parts of the API have been depreciated), but let's take a quick look at one of them that we will be using (**`get_pbp`**) to get a better sense of what's involved.[^2]


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

Ignoring, for the time being, the tests, this function should look pretty similar to the code we ran to get box score data. The URL has all of the same parameters, but `GameID` is set by a user-assigned value, `gameid`. Inside of `get_pbp`, data is retrieved by passing the URL to the `fromJSON` function (from the [**`jsonlite`**](https://github.com/jeroenooms/jsonlite) package).

So, if we wanted to get the play-by-play data for the same game we looked at in the box score section, we would do the following:

```r
## set gameid
gameid <- "0041500407"
## retrieve pbp data
pbp <- get_pbp(gameid)
```

### What's in the play-by-play data?  

Let's look at our data a bit more closely. First we'll convert our data frame to a `tbl` class-- a format that will allow us to make full use of the [**`dplyr`**](https://github.com/hadley/dplyr) package. Then we can examine the data using the `glimpse()` function, which returns a dense summary, limited to what can be viewed on the screen (i.e. no text wrapping).


```r
## convert to tbl_df
pbp <- tbl_df(pbp)

## glimpse the data
glimpse(pbp)
```

```
## Observations: 442
## Variables: 33
## $ GAME_ID                   <chr> "0041500407", "0041500407", "0041500...
## $ EVENTNUM                  <chr> "0", "1", "2", "3", "4", "5", "6", "...
## $ EVENTMSGTYPE              <chr> "12", "10", "2", "4", "2", "4", "1",...
## $ EVENTMSGACTIONTYPE        <chr> "0", "0", "78", "0", "58", "0", "40"...
## $ PERIOD                    <chr> "1", "1", "1", "1", "1", "1", "1", "...
## $ WCTIMESTRING              <chr> "8:11 PM", "8:11 PM", "8:12 PM", "8:...
## $ PCTIMESTRING              <chr> "12:00", "12:00", "11:39", "11:36", ...
## $ HOMEDESCRIPTION           <chr> NA, "Jump Ball Ezeli vs. Thompson: T...
## $ NEUTRALDESCRIPTION        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
## $ VISITORDESCRIPTION        <chr> NA, NA, "MISS Smith 5' Floating Jump...
## $ SCORE                     <chr> NA, NA, NA, NA, NA, NA, "2 - 0", NA,...
## $ SCOREMARGIN               <chr> NA, NA, NA, NA, NA, NA, "-2", NA, NA...
## $ PERSON1TYPE               <chr> "0", "4", "5", "4", "4", "5", "5", "...
## $ PLAYER1_ID                <chr> "0", "203105", "2747", "201939", "20...
## $ PLAYER1_NAME              <chr> NA, "Festus Ezeli", "JR Smith", "Ste...
## $ PLAYER1_TEAM_ID           <chr> NA, "1610612744", "1610612739", "161...
## $ PLAYER1_TEAM_CITY         <chr> NA, "Golden State", "Cleveland", "Go...
## $ PLAYER1_TEAM_NICKNAME     <chr> NA, "Warriors", "Cavaliers", "Warrio...
## $ PLAYER1_TEAM_ABBREVIATION <chr> NA, "GSW", "CLE", "GSW", "GSW", "CLE...
## $ PERSON2TYPE               <chr> "0", "5", "0", "0", "0", "0", "5", "...
## $ PLAYER2_ID                <chr> "0", "202684", "0", "0", "0", "0", "...
## $ PLAYER2_NAME              <chr> NA, "Tristan Thompson", NA, NA, NA, ...
## $ PLAYER2_TEAM_ID           <chr> NA, "1610612739", NA, NA, NA, NA, "1...
## $ PLAYER2_TEAM_CITY         <chr> NA, "Cleveland", NA, NA, NA, NA, "Cl...
## $ PLAYER2_TEAM_NICKNAME     <chr> NA, "Cavaliers", NA, NA, NA, NA, "Ca...
## $ PLAYER2_TEAM_ABBREVIATION <chr> NA, "CLE", NA, NA, NA, NA, "CLE", NA...
## $ PERSON3TYPE               <chr> "0", "5", "0", "0", "0", "0", "0", "...
## $ PLAYER3_ID                <chr> "0", "2544", "0", "0", "0", "0", "0"...
## $ PLAYER3_NAME              <chr> NA, "LeBron James", NA, NA, NA, NA, ...
## $ PLAYER3_TEAM_ID           <chr> NA, "1610612739", NA, NA, NA, NA, NA...
## $ PLAYER3_TEAM_CITY         <chr> NA, "Cleveland", NA, NA, NA, NA, NA,...
## $ PLAYER3_TEAM_NICKNAME     <chr> NA, "Cavaliers", NA, NA, NA, NA, NA,...
## $ PLAYER3_TEAM_ABBREVIATION <chr> NA, "CLE", NA, NA, NA, NA, NA, "CLE"...
```

As is to be expected, the play-by-play data is a sequence of events that occur, the order of which is recorded in the **`EVENTNUM`** variable. The players involved are identified by name and ID number, and, depending on team, the event is described as a string (AKA words) in the **`HOMEDESCRIPTION`**, **`NEUTRALDESCRIPTION`**, or **`VISITORDESCRIPTION`** columns. 

The third and fourth columns give us **`EVENTMSGTYPE`**, and **`EVENTMSGACTIONTYPE`**. 

### Dealing with Time

Dealing with time can be a tricky business. The [**`lubridate`**](https://github.com/hadley/lubridate) library makes things a little easier, and I recommend checking out the package vignette if you want to learn more. If you look at your `pbp` data frame, you'll see that there are two variables that contain `TIME`, one of which is a 12-minute countdown clock for each period (`PCTIMESTRING`). In order to get box score information at the moment of a given event, however, we'll need time in the form of tenths of seconds elapsed since the start of the game.

Below, I've done this operation in two ways: step-by-step, and in a single operation. 


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
## load lubridate
library(lubridate)

## convert PCTIMESTRING for Range params
pbp$range_clock2 <- (abs(((period_to_seconds(ms(pbp$PCTIMESTRING))) - 720)) + (((as.numeric(pbp$PERIOD)) - 1) * 720)) * 10
```

===  
**References**  
[^1]: For actual best practices for writing functions in R, I recommend checking out the [Functions](http://adv-r.had.co.nz/Functions.html) section of [Hadley Wickham](http://hadley.nz/)'s [_Advanced R_](http://adv-r.had.co.nz/), which is free, and online.  
[^2]: More detail on all of these functions, including `get_pbp`, can be found in Rajiv Shah's post: [“Merging NBA Play by Play data with SportVU data”](http://projects.rajivshah.com/sportvu/PBP_NBA_SportVu.html).
