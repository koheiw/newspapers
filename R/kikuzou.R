require(stringi)
require(XML)

#' extract texts and meta data from Nexis HTML files
#'
#' This extract headings, body texts and meta data (date, byline, length,
#' secotion, edntion) from items in HTML files downloaded by the scraper.
#' @param path either path to a HTML file or a directory that containe HTML files
#' @param paragraph_separator a character to sperarate paragrahphs in body texts.
#' @import stringi XML
#' @export
#' @examples
#' \dontrun{
#' one <- import_kinuzo('tests/html/kikuzo_1985-01-01_001.html')
#' two <- import_kinuzo('tests/html/kikuzo_1985-01-01_002.html')
#' all <- import_kinuzo('tests/html')
#' }
#'
import_kinuzo <- function(path, paragraph_separator = '|'){

    if (dir.exists(path)) {
        dir <- path
        file <- list.files(dir, full.names = TRUE, recursive = TRUE)
        data <- data.frame()
        for(f in file){
            if(stri_detect_regex(f, '\\.html$|\\.htm$|\\.xhtml$', ignore.case = TRUE) && file.size(f)) {
                tryCatch({
                    data <- rbind(data, import_html(f, paragraph_separator))
                },
                error = function(e) {
                    warning("Invalid file format: ", f)
                })
            }
        }
    } else if (file.exists(path) && file.size(path)) {
        data <- import_html(path, paragraph_separator)
    } else {
        stop(path, " does not exist")
    }
    return(data)
}

#' @import XML
import_html <- function(file, paragraph_separator){

    #Convert format
    cat('Reading', file, '\n')

    line <- readLines(file, warn = FALSE, encoding = "UTF-8")
    html <- paste0(line, collapse = "\n")

    #Load as DOM object
    dom <- htmlParse(html, encoding = "UTF-8")
    data <- data.frame()
    for (node in getNodeSet(dom, '//body/table/tbody/tr')) {
        if (length(getNodeSet(node, './/div[@class="detail001"]'))) {
            data <- rbind(data, extract_attrs(node, paragraph_separator))
        }
    }

    data$date <- as.Date(stri_datetime_parse(data$date, 'yyyy年MM月dd日'))
    data$page <- as.numeric(stri_replace_all_regex(data$page, "[^0-9]", ''))
    data$length <- as.numeric(stri_replace_all_regex(data$length, "[^0-9]", ''))
    data$file <- basename(file)

    return(data)
}

#' @import stringi
extract_attrs <- function(node, paragraph_separator) {

    attrs <- list(edition = '', date = '', length = '', section = '', head = '', body = '')

    ps <- getNodeSet(node, './/div[@class="detail001"]/text()')
    p <- sapply(ps, xmlValue)
    attrs$body <- stri_trim(paste0(p, collapse = paste0(' ', paragraph_separator, ' ')))
    #attrs$body <- clean_text(xmlValue(getNodeSet(node, './/div[@class="detail001"]')[[1]]))
    attrs$head <- clean_text(xmlValue(getNodeSet(node, './/span[@class="font002"]')[[1]]))

    tds <- getNodeSet(node, './/table[@class="topic-list"]/tbody/tr/td')
    attrs$date <- clean_text(xmlValue(tds[[2]]))
    attrs$edition <- clean_text(xmlValue(tds[[3]]))
    attrs$section <- clean_text(xmlValue(tds[[4]]))
    attrs$page <- clean_text(xmlValue(tds[[5]]))
    attrs$length <- clean_text(xmlValue(tds[[6]]))
    #print(attrs)

    if (attrs$date[1] == '' || is.na(attrs$date[1])) warning('Failed to extract date')
    if (attrs$head[1] == '' || is.na(attrs$head[1])) warning('Failed to extract heading')
    if (attrs$body[1] == '' || is.na(attrs$body[1])) warning('Failed to extract body text')
    return(as.data.frame(attrs, stringsAsFactors = FALSE))
}

#' @import stringi
clean_text <- function(str) {
    str <- stri_replace_all_regex(str, '[[:^print:]]', ' ');
    str <- stri_replace_all_regex(str, "[\\r\\n\\t]", ' ')
    str <- stri_replace_all_regex(str, "\\s\\s+", ' ')
    str <- stri_trim(str);
    return(str)
}
