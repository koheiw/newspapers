#' @rdname import
#' @import utils XML readxl
#' @export
#' @examples
#' \dontrun{
#' # Integrum
#' xlsx <- import_integrum("tests/data/integrum/channel1_20050201-20050228_0001-0059_0059.xlsx")
#' html <- import_integrum("tests/data/integrum/moscow_1993-06-06_1994-09-02.html")
#' }
import_integrum <- function(path, paragraph_separator = "\n\n") {
    result <- data.frame()
    if (dir.exists(path)) {
        dir <- path
        file <- list.files(dir, full.names = TRUE, recursive = TRUE)
        size_prev <- 0
        for (f in file) {
            if (stri_detect_regex(f, '\\.doc$', case_insensitive = TRUE) && file.size(f)) {
                result <- rbind(result, import_integrum_doc(f, paragraph_separator))
            } else if (stri_detect_regex(f, '\\.xlsx$', case_insensitive = TRUE) && file.size(f)) {
                result <- rbind(result, import_integrum_xlsx(f, paragraph_separator))
            } else if (stri_detect_regex(f, '\\.html$|\\.htm$|\\.xhtml$', case_insensitive = TRUE)) {
                result <- rbind(result, import_integrum_html(f, paragraph_separator))
            }
        }
    } else if (file.exists(path) && file.size(path)) {
        if (stri_detect_regex(path, '\\.doc$', case_insensitive = TRUE)) {
            result <- import_integrum_doc(path, paragraph_separator)
        } else if (stri_detect_regex(path, '\\.xlsx$', case_insensitive = TRUE)) {
            result <- import_integrum_xlsx(path, paragraph_separator)
        } else if (stri_detect_regex(path, '\\.html$|\\.htm$|\\.xhtml$', case_insensitive = TRUE)) {
            result <- import_integrum_html(path, paragraph_separator)
        }
    } else {
        stop(path, " does not exist")
    }
    return(result)
}

import_integrum_xlsx <- function(file, paragraph_separator) {
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
import_integrum_doc <- function(file, paragraph_separator) {

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

#' @noRd
#' @examples
#' \dontrun{
#' out <- newspapers:::import_integrum_html("tests/data/integrum/moscow_1993-06-06_1994-09-02.html", "\n\n")
#' }

import_integrum_html <- function(file, paragraph_separator) {

    #Convert format
    cat("Reading", file, "\n")

    line <- readLines(file, warn = FALSE, encoding = "windows-1251")
    html <- paste0(line, collapse = "\n")

    #Load as DOM object
    dom <- htmlParse(html, encoding = "windows-1251")
    data <- data.frame()
    for (node in getNodeSet(dom, '//body/div')) {
        attrs <- extract_integrum_attrs(node, paragraph_separator)
        if (attrs$date[1] == "")
            warning('Failed to extract date in ', file, call. = FALSE)
        if (attrs$head[1] == "")
            warning('Failed to extract heading in ', file, call. = FALSE)
        if (attrs$body[1] == "")
            warning('Failed to extract body text in ', file, call. = FALSE)
        data <- rbind(data, as.data.frame(attrs, stringsAsFactors = FALSE))
    }

    data$date <- stri_replace_first_regex(data$date, "(\\d+)\\.(\\d+)\\.(\\d+)", "$3-$2-$1")
    data$page <- as.numeric(stri_replace_all_regex(data$page, "[^0-9]", ""))
    data$file <- basename(file)

    return(data)
}

extract_integrum_attrs <- function(node, paragraph_separator) {

    attrs <- list(pub = "", date = "", byline = "", head = "", body = "", section = "")

    ps <- getNodeSet(node, './pre')
    p <- sapply(ps[1], xmlValue)
    attrs$body <- stri_replace_all_regex(paste0(p, collapse = ""), "\\n\\p{Z}+", "\U2029")
    attrs$body <- stri_replace_all_fixed(attrs$body, "\n", " ")
    attrs$body <- stri_replace_all_fixed(attrs$body, "\U2029", paragraph_separator)

    tds <- getNodeSet(node, './table/tr/td')
    v <- paste0(sapply(tds[1], xmlValue), "\n")
    attrs$pub <- clean_text(stri_match_first_regex(v, "\\^\U0418\U0421:\\n(.*)\\n")[1,2])
    attrs$date <- clean_text(stri_match_first_regex(v, "\\^\U0414\U0422:\\n(.*)\\n")[1,2])
    attrs$head <- clean_text(stri_match_first_regex(v, "\\^\U0417\U0413:\\n(.*)\\n")[1,2])
    attrs$byline <- clean_text(stri_match_first_regex(v, "\\^\U0410\U0412:\\n(.*)\\n")[1,2])
    attrs$page <- clean_text(stri_match_first_regex(v, "\\^\U041d\U0420:\\n(.*)\\n")[1,2])
    attrs$section <- clean_text(stri_match_first_regex(v, "\\^\U0420\U0411:\\n(.*)\\n")[1,2])
    return(attrs)
}
