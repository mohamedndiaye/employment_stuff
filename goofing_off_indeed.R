################################################################################
# Using Indeed's API to Get Job Posting Data
################################################################################

# This file starts by searching Indeed for job listings, then converting the 
# search results to a more useful form, and visualizing the data using word
# clouds

# See https://ads.indeed.com/jobroll/xmlfeed for editing feed to customize
# search. Search returns the most relevant search results (up to 25 listings), 
# given search terms and restrictions.

# `XML` package to parse the xml file that the Indeed API returns. 

# install.packages("XML")

library("XML")
library("plyr") # Had to install this via the command line for some reason
library("tm") # `tm` is a text mining package for R
library("stringi") # Using regex commands on strings from job summaries
library("magrittr") # Piping
library("wordcloud") # Word cloud visualization

# Searching for postings with "floor" and "technician"

raw_data <- xmlParse("http://api.indeed.com/ads/apisearch?publisher=9724091492889092&q=manual+labor&l=20001&sort=&radius=10&st=&jt=&start=1&limit=50&fromage=30&filter=&latlong=1&co=us&chnl=&userip=1.2.3.4&useragent=Mozilla/%2F4.0%28Firefox%29&v=2")

class(raw_data) # [1] "XMLInternalDocument" "XMLAbstractDocument"

xml_top <- xmlRoot(raw_data)

xml_data <- xml_top[[10]] # Extracting the job posting information

data <- ldply(xmlToList(xml_data), data.frame) # Converting to data frame

data$url <- as.character(data$url) # Need this for converting to a list

urls <- as.list(data$url) # Retaining the URLs as a list so we can lapply them

################################################################################
# Starting with first URL by itself, as a trail case
################################################################################

# You can update which particular search result you want to examine with the 
# code chunk below by adjust the `readLines(urls[[3]])` line below

suppressWarnings(rm(summary))

suppressWarnings(posting_html <- readLines(urls[[3]]))  # The code here lets 
# us avoid the readLines error message about incomplete final line

line_id <- grep("job_summary", posting_html) # Using grep to find job summary
plus_id <- grep("</span><br><div id=", posting_html) # Poking around for end of 
# the job summary section (NOTE: Thing probably needs to be fiddled with...)

summary <- posting_html[line_id:plus_id] # Subset just lines with job summary

summary %<>% paste(collapse=" ") %>% # Using piping, just for kicks
    stri_replace_all_regex("<.+?>"," ") %>% # Following code is tm + regex stuff
    stripWhitespace() %>% # No whitespace 
    removePunctuation() %>% # No punctuation
    tolower() %>% # All lowercase
    removeWords(stopwords("english")) %>% # Getting rid of common english words 
    PlainTextDocument() # Formatting output

summary[[1]] # Printing the plain text version of the job summary

################################################################################
# Combining a cleaning function + lapply to automate for each job posting
################################################################################

# First, creating a function to automate the above code chunk, then using lapply

cleaning <- function(x) {
  
  suppressWarnings(posting_html <- readLines(x))
  
  line_id <- grep("job_summary", posting_html) 
  plus_id <- grep("</span><br><div id=", posting_html) 
  
  summary <- posting_html[line_id:plus_id]
  
  summary %<>%  paste(collapse = " ") %>% # Paste creates single element string
  stripWhitespace() %>% # Everything works as in above code chunk
    stri_replace_all_regex("<.+?>"," ") %>%
    removePunctuation() %>% 
    tolower() %>% 
    removeWords(stopwords("english")) %>%
    PlainTextDocument() 
  
  return(summary) # This is important to ensure we get the function output right
  
}

posting_data <- lapply(urls, function(x) PlainTextDocument(cleaning(x)))

# cleaning <- dget("cleaning.R") `cleaning.R` has been saved as a separate file, 
# so we can also call it 

################################################################################
# Creating Corpus + Using Term Document Matrix (TDM) for Text Analysis
################################################################################

posting_data <- VectorSource(posting_data) # Prepping to convert to corpus

posting_data <- Corpus(posting_data) # Converting to corpus- collection of texts

posting_TDM <- TermDocumentMatrix(posting_data) # TDM for text analysis

posting_TDM # Printing TDM output

findFreqTerms(posting_TDM,10) # Prints words appearing > 10 times

################################################################################
# Creating Corpus + Using Term Document Matrix (TDM) for Text Analysis
################################################################################

# Used guide from http://www.r-bloggers.com/word-clouds-using-text-mining/

posting_matrix <- sort(rowSums(as.matrix(posting_TDM)), decreasing = T)

set.seed(4363)

wordcloud(names(posting_matrix), posting_matrix, min.freq=25) 



