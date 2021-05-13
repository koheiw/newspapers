require(XML)
require(stringi)

import_integrum_html <- function(file, paragraph_separator){

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
    attrs$pub <- clean_text(stri_match_first_regex(v, "\\^ИС:\\n(.*)\\n")[1,2])
    attrs$date <- clean_text(stri_match_first_regex(v, "\\^ДТ:\\n(.*)\\n")[1,2])
    attrs$head <- clean_text(stri_match_first_regex(v, "\\^ЗГ:\\n(.*)\\n")[1,2])
    attrs$byline <- clean_text(stri_match_first_regex(v, "\\^АВ:\\n(.*)\\n")[1,2])
    attrs$page <- clean_text(stri_match_first_regex(v, "\\^НР:\\n(.*)\\n")[1,2])
    attrs$section <- clean_text(stri_match_first_regex(v, "\\^РБ:\\n(.*)\\n")[1,2])
    return(attrs)
}

file <- "/home/kohei/repo/newspapers/tests/data/integrum/moscow_1993-06-06_1994-09-02.html"
out <- import_integrum_html(file, "\n\n")
