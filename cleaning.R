################################################################################
# `cleaning()` function
################################################################################

# Pulls search results from Indeed's API, and creates a corpus of clean text 
# with the job desription from each individual job posting

cleaning <- function(x) {
  
  suppressWarnings(posting_html <- readLines(x))
  
  line_id <- grep("job_summary", posting_html) 
  plus_id <- grep("</span><br><div id=", posting_html) 
  
  summary <- posting_html[line_id:plus_id]
  
  summary %<>%  paste(collapse = " ") %>% # Paste creates single element string
    stripWhitespace() %>% # Eliminate white space
    stri_replace_all_regex("<.+?>"," ") %>% # Drop all html tags
    removePunctuation() %>% # Drop punctuation
    tolower() %>% # Make everything lowercase
    removeWords(stopwords("english")) %>% # Cool! Delete common english words
    PlainTextDocument() # Convert to a plain text document
  
  return(summary) # This is important to ensure we get the function output right
  
}