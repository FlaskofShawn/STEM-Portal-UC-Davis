library(stringr)
library(rvest)
library(XML)
library(NLP)
library(tm)

# first Level Start
# create a blank list 
urls_combined <- character()

# loop through all the stem resource programs and combine them in the blank list
for(i in 1:22){
  link <- paste0("https://stem.ucdavis.edu/resources/page/",i)
  stem_web <- read_html(link)
  urls <- stem_web %>%
    html_nodes(".btn") %>%
    html_attr("href")
    urls_combined <- c(urls_combined, urls)
}

# exclude all the unexisted links
urls_combined = urls_combined[which(urls_combined != "NA")]

# count for create folder name
count <- 1

# start to scrape text for each first level page
for (i in urls_combined){
link <- i
html = read_html(link)
p = html_nodes(html, "body")
t = html_text(p)

# Cleaning
# change to lowercase
t_lowercase <- tolower(t)

# remove stopwords
t_unStopped <- removeWords(t_lowercase, stopwords('english'))

#############
# wash, rinse, repeat from here
##############
# identify any words you want removed from
# the corpus prior to analysis
var_word_blacklist = c("abcd", 
                       "efgh")

# use the below line to remove any other tokens based on blacklist
t_blacklisted <- removeWords(t_unStopped, var_word_blacklist)

# protect hyphens
t_nonNumeric <- gsub("-", " - ", t_blacklisted)

# remove punctuation
t_noPunctuation <- removePunctuation(t_nonNumeric)

# remove numeric elements
t_nonNumeric <- gsub("\\d+", "#numeric#", t_noPunctuation)

# collapse multiple spaces
t_collapseWhitespace <- gsub("\\s+", " ", t_nonNumeric)

# trim leading and trailing spaces
t_cleaned <- trimws(t_collapseWhitespace )


# define an output path
setwd("D:/software/R file/projectfiles")

folder_name = "STEM_resources_program_"
dir.create(paste0(folder_name,count))

txt_path = paste0(folder_name,count)


setwd(paste0("D:/software/R file/projectfiles/", txt_path))
getwd()

txt_name = "raw_text.txt"
file.create(txt_name)

outpath <- (txt_name)

# open a write connection
fileConn <- file(outpath)

# write the file
writeLines(t, con = fileConn, useBytes = FALSE)

# close the connection
close(fileConn)

txt_name = "cleaned_text.txt"
file.create(txt_name)

outpath <- (txt_name)

# open a write connection
fileConn <- file(outpath)

# write the file
writeLines(t_cleaned, con = fileConn, useBytes = FALSE)

# close the connection
close(fileConn)

count <- count + 1
}

# second level start

# define a pattern
pattern_deeper <- ".*ucdavis.edu.*"

# count for creating folders
final_count <- 1
for (i in urls_combined){

  deeper_link <- url(i)
  deeper_html <- read_html(deeper_link)
  deeper_url <- deeper_html %>% html_nodes("a") %>% html_attr("href")
  
  
# fliter non-ucdavis.edu links    
  deeper_true_url <- character()
  
  tryCatch({
  for(j in 1:length(deeper_url)){
    bool = str_detect(deeper_url[j], pattern_deeper)
    
    if(!(is.na(bool))) {
      if (str_detect(deeper_url[j], pattern_deeper)){
        deeper_true_url <- c(deeper_true_url, deeper_url[j])
      }
    }
  }
  })
  
  # start to scrape text from second level page
  
  final_folder_count <- 1
  # define an output path
  final_folder_path <- "D:/software/R file/projectfiles/STEM_resources_program_"

  for(k in deeper_true_url){
    tryCatch({
    final_link <- url(k)
    
    
    final_html = read_html(final_link)
    final_p = html_nodes(final_html, "body")
    final_t = html_text(final_p)
    
    # Cleaning
    # change to lowercase
    #print(k)
    final_t_lowercase <- tolower(final_t)
    
    # remove stopwords
    final_t_unStopped <- removeWords(final_t_lowercase, stopwords('english'))
    
    #############
    # wash, rinse, repeat from here
    ##############
    # identify any words you want removed from
    # the corpus prior to analysis
    final_var_word_blacklist = c("abcd", 
                           "efgh")
    
    # use the below line to remove any other tokens based on blacklist
    final_t_blacklisted <- removeWords(final_t_unStopped, final_var_word_blacklist)
    
    # protect hyphens
    final_t_nonNumeric <- gsub("-", " - ", final_t_blacklisted)
    
    # remove punctuation
    final_t_noPunctuation <- removePunctuation(final_t_nonNumeric)
    
    # remove numeric elements
    final_t_nonNumeric <- gsub("\\d+", "#numeric#", final_t_noPunctuation)
    
    # collapse multiple spaces
    final_t_collapseWhitespace <- gsub("\\s+", " ", final_t_nonNumeric)
    
    # trim leading and trailing spaces
    final_t_cleaned <- trimws(final_t_collapseWhitespace )
    
    
    setwd(paste0(final_folder_path,final_count))
    

    final_folder_name = "second_level_page_"
    dir.create(paste0(final_folder_name,final_folder_count))
    
    final_txt_path = paste0(final_folder_name,final_folder_count)
    combined_final_txt_path = paste0(paste0(paste0(final_folder_path,final_count),"/"), final_txt_path)
    
    setwd(combined_final_txt_path)
    #getwd()
    
    final_txt_name = "second_raw_text.txt"
    file.create(final_txt_name)
    
    outpath <- (final_txt_name)
    
    # open a write connection
    fileConn <- file(outpath)
    
    # write the file
    writeLines(final_t, con = fileConn, useBytes = FALSE)
    
    # close the connection
    close(fileConn)
    
    final_txt_name = "second_cleaned_text.txt"
    file.create(final_txt_name)
    
    outpath <- (final_txt_name)
    
    # open a write connection
    fileConn <- file(outpath)
    
    # write the file
    writeLines(final_t_cleaned, con = fileConn, useBytes = FALSE)
    
    # close the connection
    close(fileConn)
    
    final_folder_count <- final_folder_count + 1
    }, error = function(err) {
      print(err)
    }
    )}
  
  final_count <- final_count + 1
  
}
