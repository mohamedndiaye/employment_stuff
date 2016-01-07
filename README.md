## Web Scraping and Visualization with Job Posting Data

This repo is (or will hopefully be) a set of files exploring using R to collect and describe / visualize job posting data, starting with listings made available via Indeed's API. 

#### Motivation

The motivation for this work started with thinking about employment prospects for ex-offenders; specifically, I wanted to look at postings in the sorts of industries and jobs where ex-offenders tended to seek employment after incarceration.

My goal is to produce something useful in the way of describing the kinds of qualifications employers posted on job listings for potential applicants. 

#### Data Stuff

The code included (primarily `goofing_off_indeed.R`) is my first foray into text analysis with R. It starts by using Indeed's API to query local job postings for a specified search term, with date and location restrictions on the posts. 

This gives me a XML file with the search data, including URL's for each individual job posting. First, this information is formatted as a tidy R dataset with information on each job listing. From here, I use each individual listing's URL to create a plain text document using `tm` and `regex` commands featuring the full text from each job posting. With a cleaned corpus of postings, I can then do analysis plus visualization stuff (including making a word cloud). 
