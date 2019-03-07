#' Extract texts and meta data from Kikuzo HTML files
#'
#' This extract headings, body texts and meta data (date, byline, length,
#' secotion, edntion) from HTML files downloaded from the Kikuzo database.
#' @param path either path to a HTML file or a directory that containe HTML files
#' @param paragraph_separator a character to sperarate paragrahphs in body texts.
#' @import utils XML
#' @export
#' @examples
#' \dontrun{
#' one <- import_kikuzo("tests/data/kikuzo/kikuzo_1985-01-01_001.html")
#' two <- import_kikuzo("tests/data/kikuzo/kikuzo_1985-01-01_002.html")
#' all <- import_kikuzo("tests/data/kikuzo")
#' }
import_kikuzo <- function(path, paragraph_separator = "\n\n") {
    import_html(path, paragraph_separator, "kikuzo")
}

import_kikuzo_html <- function(file, paragraph_separator){

    #Convert format
    cat("Reading", file, "\n")

    line <- readLines(file, warn = FALSE, encoding = "UTF-8")
    html <- paste0(line, collapse = "\n")

    #Load as DOM object
    dom <- htmlParse(html, encoding = "UTF-8")
    data <- data.frame()
    for (node in getNodeSet(dom, '//table[@class="topic-detail"]')) {
        node <- xmlParent(node)
        if (length(getNodeSet(node, './/div[@class="detail001"]'))) {
            attrs <- extract_kikuzo_attrs(node, paragraph_separator)
            if (attrs$date[1] == "" || is.na(attrs$date[1]))
                warning('Failed to extract date in ', file, call. = FALSE)
            if (attrs$head[1] == "" || is.na(attrs$head[1]))
                warning('Failed to extract heading in ', file, call. = FALSE)
            if (attrs$body[1] == "" || is.na(attrs$body[1]))
                warning('Failed to extract body text in ', file, call. = FALSE)
            data <- rbind(data, as.data.frame(attrs, stringsAsFactors = FALSE))
        }
    }

    data$date <- stri_replace_first_regex(data$date, "(\\d+)年(\\d+)月(\\d+)日", "$1-$2-$3")
    data$page <- as.numeric(stri_replace_all_regex(data$page, "[^0-9]", ""))
    data$length <- as.numeric(stri_replace_all_regex(data$length, "[^0-9]", ""))
    data$file <- basename(file)

    return(data)
}

extract_kikuzo_attrs <- function(node, paragraph_separator) {

    attrs <- list(edition = "", date = "", length = "", section = "", head = "", body = "")

    ps <- getNodeSet(node, './/div[@class="detail001"]//text()')
    p <- sapply(ps, xmlValue)
    attrs$body <- stri_trim(paste0(p, collapse = paste0(' ', paragraph_separator, ' ')))
    #attrs$body <- clean_text(xmlValue(getNodeSet(node, './/div[@class="detail001"]')[[1]]))
    attrs$head <- clean_text(xmlValue(getNodeSet(node, './/span[@class="font002"]')[[1]]))

    tds <- getNodeSet(node, './/table[@class="topic-list"]//td')
    attrs$date <- clean_text(xmlValue(tds[[2]]))
    attrs$edition <- clean_text(xmlValue(tds[[3]]))
    attrs$section <- clean_text(xmlValue(tds[[4]]))
    attrs$page <- clean_text(xmlValue(tds[[5]]))
    attrs$length <- clean_text(xmlValue(tds[[6]]))
    #print(attrs)
    return(attrs)
}
