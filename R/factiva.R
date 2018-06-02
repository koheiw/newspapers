#' Extract texts and meta data from factiva HTML files
#'
#' This extract headings, body texts and meta data (date, byline, length,
#' secotion, edntion) from HTML files downloaded from the factiva database.
#' @param path either path to a HTML file or a directory that containe HTML files
#' @param paragraph_separator a character to sperarate paragrahphs in body texts.
#' @import stringi XML
#' @export
#' @examples
#' \dontrun{
#' one <- import_factiva('testthat/data/factiva/asahi_1985-01-01_001.html')
#' two <- import_factiva('testthat/data/factiva/asahi_1985-01-01_002.html')
#' all <- import_factiva('testthat/data/factiva')
#' }
#'
#'
import_factiva <- function(path, paragraph_separator = "|") {
    import_html(path, paragraph_separator, "factiva")
}

#' @import XML
import_factiva_html <- function(file, paragraph_separator){

    #Convert format
    cat('Reading', file, '\n')

    line <- readLines(file, warn = FALSE, encoding = "UTF-8")
    html <- paste0(line, collapse = "\n")

    #Load as DOM object
    dom <- htmlParse(html, encoding = "UTF-8")
    data <- data.frame()
    for (node in getNodeSet(dom, '//div[contains(@class, "Article")]')) {
        node <- xmlParent(node)
        data <- rbind(data, extract_factiva_attrs(node, paragraph_separator))
    }

    data$date <- as.Date(stri_datetime_parse(data$date, 'dd MMMM yyyy'))
    data$length <- as.numeric(stri_replace_all_regex(data$length, "[^0-9]", ""))
    data$file <- basename(file)

    return(data)
}

file <- "/home/kohei/packages/newspapers/testthat/data/factiva/irish-independence_1_2017-11-14.html"

out <- import_factiva_html("/home/kohei/packages/newspapers/testthat/data/factiva/irish-independence_1_2017-11-14.html", "|")

#' @import stringi
extract_factiva_attrs <- function(node, paragraph_separator) {

    attrs <- list(edition = "", date = "", length = "", section = "", page = "",
                  source = "", language = "", head = "", body = "")

    ps <- getNodeSet(node, './/p[contains(@class, "articleParagraph")]/text()')
    p <- sapply(ps, xmlValue)
    attrs$body <- stri_trim(paste0(p, collapse = paste0(' ', paragraph_separator, ' ')))
    attrs$head <- clean_text(xmlValue(getNodeSet(node, './/span[contains(@class, "Headline")]')[[1]]))

    divs <- getNodeSet(node, './/div[not(@*)]')
    attrs$section <- clean_text(xmlValue(divs[[6]]))
    attrs$page <- clean_text(xmlValue(divs[[7]]))
    attrs$length <- clean_text(xmlValue(divs[[2]]))
    attrs$date <- clean_text(xmlValue(divs[[3]]))
    attrs$source <- clean_text(xmlValue(divs[[4]]))
    attrs$language <- clean_text(xmlValue(divs[[8]]))

    #print(attrs)

    if (attrs$date[1] == "" || is.na(attrs$date[1])) warning('Failed to extract date')
    if (attrs$head[1] == "" || is.na(attrs$head[1])) warning('Failed to extract heading')
    if (attrs$body[1] == "" || is.na(attrs$body[1])) warning('Failed to extract body text')
    return(as.data.frame(attrs, stringsAsFactors = FALSE))
}
