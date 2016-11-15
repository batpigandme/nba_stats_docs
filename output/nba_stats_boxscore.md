# NBA Stats API -- Box Score Data
Mara Averick  



## NBA Stats API Resources

This is not official documentation— it's a mash-up of information I have gathered from tinkering with the API, and the hard work of those who have done this before me, including:

* The extensive [“stats.nba.com Endpoint Documentation”](https://github.com/seemethere/nba_py/wiki/stats.nba.com-Endpoint-Documentation) from the [nba_py wiki](https://github.com/seemethere/nba_py/wiki/Completed-Work-Log);
* Daniel Welch's [“Documenting the NBA Stats API”](http://danielwelch.github.io/documenting-the-nba-stats-api.html);
* Savvas Tjortjoglou's [“How to Track NBA Player Movements in Python”](http://savvastjortjoglou.com/nba-play-by-play-movements.html);
* Daniel Forsyth's [“Exploring NBA Data in Python”](http://www.danielforsyth.me/exploring_nba_data_in_python/)
*  Tanya Cashorali's [“NBA Player Movement Data in R”](http://tcbanalytics.com/blog/nba-movement-data-R.html#.WCncXdwwd_x); and
* Rajiv Shah's [“NBA SportVu Analysis”](http://projects.rajivshah.com/blog/2016/04/02/sportvu_analysis/) blog series, and [NBA_SportVu](https://github.com/rajshah4/NBA_SportVu) GitHub repo

## Box Score Endpoint Parameters

As you may have gathered from the list of references above, the stats.nba.com endpoints have been well-documented.[^1] However, since the NBA API no longer supports the SporVu data in the way it had when many of these prior tutorials were written, it was possible to use a `movements` data to determine what players were on the court at a given time. 

In order to get lineups and on/off data now, we have to use the **`boxscoreadvanced2`** endpoint. For all `GET` requests to `stats.nba.com/stats/boxscoreadvancedv2/`, the following parameters are required:  

  * `GameID`
  * `StartPeriod`
  * `EndPeriod`
  * `StartRange`
  * `EndRange`
  * `RangeType`

The parameters follow a question mark that comes at the end of the endpoint name, and are separated by ampersands (`&`), and are, by default, set up to capture the entire game. 

![boxscore endpoint url params](nba_stats_scraping_files/images/boxscorev2_url1.png)  

While the full URL might look something like this:


```r
`http://stats.nba.com/stats/boxscoreadvancedv2?EndPeriod=10&EndRange=55800&GameID=0041500407&RangeType=2&StartPeriod=1&StartRange=0`
```

The JSON retrieved, then, identifies the parameter settings as such:

```r
parameters: {

    "GameID": "0041500407",
    "StartPeriod": 1,
    "EndPeriod": 10,
    "StartRange": 0,
    "EndRange": 55800,
    "RangeType": 2

}
```

These match the parameters seen in the URL:

![endpoint parameters](nba_stats_scraping_files/images/boxscorev2_params.png)

In order for any of this to be useful, we have to actually know what those parameters _mean_. Some of them are fairly obvious. 

### GameID  

Every game has a unique `GameID`— for example, for Game 7 of the 2016 NBA Finals, `GameID=0041500407`.[^2] Often, `GameID` will be the only parameter you'll need to pass to functions such as [Rajiv Shah's](https://github.com/rajshah4/NBA_SportVu) used to retrieve play-by-play data. 

![GameID param](nba_stats_scraping_files/images/boxscorev2_GameID.png)

### RangeType

This was the parameter that initially tripped me up, since it determines which of the other parameters are actually _used_ as arguments in your call to the API. `RangeType` can take three values: `0`, `1`, and `2`.

![RangeType param](nba_stats_scraping_files/images/boxscoreadv2_RangeType.png)

* If `RangeType=0`, then, regardless of the values of other parameters, you will be retrieving the data for the entirety of the game specified in `GameID`.  
* If `RangeType=1`, your data will be retrieved for the entirety of periods specified in `StartPeriod` and `EndPeriod`, regardless of what values are assigned to `StartRange` and `EndRange`.
* If `RangeType=2`, the you will retrieve data for the time period specified in `StartRange` and `EndRange` (dicsussed in further detail, below).

However, all of the parameters, _including_ those ignored, depending on `RangeType`, _are_ **required**. 


### StartPeriod & EndPeriod  

The `StartPeriod` and `EndPeriod` parameters are assigned values according to the periods of the game for which you want to collect information. Despite the fact that there are rarely 10 periods in a basketball game, that default value captures a regulation-length game, with overtime periods to spare. 

![Start/EndPeriod params](nba_stats_scraping_files/images/boxscorev2_StartEndPeriod.png)

### StartRange & EndRange  

The values for `StartRange` and `EndRange` are **tenths of seconds**. So, to get the first ten minutes of a game, you would set `StartRange=0` and `EndRange=6000`. 

![Start/EndRange params](nba_stats_scraping_files/images/boxscorev2_StartEndRange.png)

## Parsing Box Score JSON with R


```r
## strings as factors to FALSE
options(stringsAsFactors = FALSE)

## load libraries
library(RCurl)
library(jsonlite)
library(tidyverse)

## get JSON from stats.nba.com
df <- fromJSON("http://stats.nba.com/stats/boxscoretraditionalv2?EndPeriod=10&EndRange=55800&GameID=0041500407&RangeType=2&StartPeriod=1&StartRange=0")
```


```r
## unlist parameters from JSON
params <- unlist(df$parameters)

## view parameters
params
```

```
##       GameID  StartPeriod    EndPeriod   StartRange     EndRange 
## "0041500407"          "1"         "10"          "0"      "55800" 
##    RangeType 
##          "2"
```


```r
pstats <- df[['resultSets']]

headers <- unlist(unlist(df$resultSets$headers[[1]]))
headers <- data_frame(headers)

## data to matrix
rowsets <- unlist(df$resultSets$rowSet[[1]])
## convert to data frame
rowsets.df <- as.data.frame(rowsets)

## convert to tbl_df
rowsets_tbl <- tbl_df(rowsets.df)

## headers as vector 
headers_vec <- as.vector(headers$headers)
## assign headers as column names
names(rowsets_tbl)[1:28] = c(headers_vec)
```


```r
## save as temp file
write.csv(rowsets_tbl, file = "output/rowsets_tbl.csv", row.names = FALSE)
```


```r
## read in using readr
library(readr)
rowsets_tbl <- read_csv("~/wicker/output/rowsets_tbl.csv", col_types = cols(MIN = col_character()))

head(rowsets_tbl)
```

```
## # A tibble: 6 × 28
##      GAME_ID    TEAM_ID TEAM_ABBREVIATION TEAM_CITY PLAYER_ID
##        <chr>      <int>             <chr>     <chr>     <int>
## 1 0041500407 1610612739               CLE Cleveland      2544
## 2 0041500407 1610612739               CLE Cleveland    201567
## 3 0041500407 1610612739               CLE Cleveland    202684
## 4 0041500407 1610612739               CLE Cleveland      2747
## 5 0041500407 1610612739               CLE Cleveland    202681
## 6 0041500407 1610612739               CLE Cleveland      2210
## # ... with 23 more variables: PLAYER_NAME <chr>, START_POSITION <chr>,
## #   COMMENT <chr>, MIN <chr>, FGM <int>, FGA <int>, FG_PCT <dbl>,
## #   FG3M <int>, FG3A <int>, FG3_PCT <dbl>, FTM <int>, FTA <int>,
## #   FT_PCT <dbl>, OREB <int>, DREB <int>, REB <int>, AST <int>, STL <int>,
## #   BLK <int>, TO <int>, PF <int>, PTS <int>, PLUS_MINUS <int>
```
