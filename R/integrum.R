#' Extract texts and meta data from Integrum XLSX files
#'
#' This extract headings, body texts and meta data (date, time) from XLSX files
#' downloaded from the Integrum database.
#' @param path either path to a XLSX file or a directory that containe XLSX
#'   files
#' @param paragraph_separator a character to sperarate paragrahphs in body
#'   texts.
#' @import utils XML readxl
#' @export
#' @examples
#' \dontrun{
#' one <- import_integrum("tests/data/integrum/channel1_20050201-20050228_0001-0059_0059.xlsx")
#' two <- import_integrum("tests/data/integrum/ntv_20121201-20121231_0001-0100_0190.xlsx")
#' all <- import_integrum("tests/data/integrum")
#' }
import_integrum <- function(path, paragraph_separator = "\n\n") {
    result <- data.frame()
    if (dir.exists(path)) {
        dir <- path
        file <- list.files(dir, full.names = TRUE, recursive = TRUE)
        size_prev <- 0
        for (f in file) {
            if (stri_detect_regex(f, '\\.doc$', ignore.case = TRUE) && file.size(f)) {
                result <- rbind(result, import_doc(f, paragraph_separator))
            } else if (stri_detect_regex(f, '\\.xlsx$', ignore.case = TRUE) && file.size(f)) {
                result <- rbind(result, import_xlsx(f, paragraph_separator))
            }
        }
    } else if (file.exists(path) && file.size(path)) {
        if (stri_detect_regex(path, '\\.doc$', ignore.case = TRUE)) {
            result <- import_doc(path, paragraph_separator)
        } else if(stri_detect_regex(path, '\\.xlsx$', ignore.case = TRUE)) {
            result <- import_xlsx(path, paragraph_separator)
        }
    } else {
        stop(path, " does not exist")
    }
    return(result)
}

import_xlsx <- function(file, paragraph_separator) {
    cat('Reading', file, '\n')
    result <- readxl::read_excel(file)
    result <- result[,seq(5)]
    colnames(result) <- c("source", "date", "time", "head", "body")
    result$body <- stri_replace_all_fixed(result$body, "\r\n\r\n", paragraph_separator)
    result$date <- as.Date(sapply(result$date, fix_date))
    return(result)
}

fix_date <- function(x) {
    elem <- rev(unlist(stri_split_fixed(stri_trim_both(x), ".")))
    if (stri_length(elem[1]) == 2) {
        elem[1] <- paste0("20", elem[1])
    }
    paste(elem, collapse = "-")
}

#' @import XML
import_doc <- function(file, paragraph_separator) {

    cat('Reading', file, '\n')

    unzip(file, "word/afchunk.htm", exdir = tempdir())
    file <- paste0(tempdir(), "/word/afchunk.htm")
    html <- paste0(readLines(file, warn = FALSE, encoding = "UTF-8"), collapse = "")

    # fix tags
    html <- stri_replace_all_fixed(html, "&nbsp;<br><pre></pre>", "")
    html <- stri_replace_all_fixed(html, "<li>", " ")
    html <- stri_replace_all_fixed(html, "</li>", " ")
    html <- stri_replace_all_fixed(html, "<p><p>", "</p><p>")

    # separate articles
    html <- stri_replace_all_fixed(html, "<h1>", "<doc><h1>")
    html <- stri_replace_all_fixed(html, "<p></p><br><p></p><br><p></p>", "</doc>")

    dom <- htmlParse(html, encoding = "UTF-8")

    result <- data.frame()
    for(doc in getNodeSet(dom, '//doc')){

        attrs <- list(pub = "", date = "", head = "", body = "")

        h1s <- getNodeSet(doc, './h1')
        if (length(h1s) == 1)
            attrs$head <- stri_trim_both(xmlValue(h1s[[1]]))

        h2s <- getNodeSet(doc, './h2')
        if (length(h2s) == 2) {
            attrs$pub <- stri_trim_both(xmlValue(h2s[[1]]))
            time <- unlist(stri_split_fixed(stri_trim_both(xmlValue(h2s[[2]])), "."))
            attrs$date <- paste(rev(time), collapse = "-")
        }

        ps <- getNodeSet(doc, './p')
        if (length(ps) > 0) {
            p <- sapply(ps, xmlValue)
            attrs$body <- stri_trim(paste0(p, collapse = paste0(' ', paragraph_separator, ' ')))
        }

        if (attrs$pub[1] == '' || is.na(attrs$pub[1])) warning('Failed to extract publication name')
        if (attrs$date[1] == '' || is.na(attrs$date[1])) warning('Failed to extract date')
        if (attrs$head[1] == '' || is.na(attrs$head[1])) warning('Failed to extract heading')
        if (attrs$body[1] == '' || is.na(attrs$body[1])) warning('Failed to extract body text')

        result <- rbind(result, as.data.frame(attrs, stringsAsFactors = FALSE))
    }
    return(result)
}


