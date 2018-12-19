require(XML)
require(stringi)

import_doc <- function(file, paragraph_separator) {

    cat('Reading', file, '\n')

    unzip(file, "word/document.xml", exdir = tempdir())
    file <- paste0(tempdir(), "/word/document.xml")
    html <- paste0(readLines(file, warn = FALSE, encoding = "UTF-8"), collapse = "")

    # # fix tags
    # html <- stri_replace_all_fixed(html, "&nbsp;<br><pre></pre>", "")
    # html <- stri_replace_all_fixed(html, "<li>", " ")
    # html <- stri_replace_all_fixed(html, "</li>", " ")
    # html <- stri_replace_all_fixed(html, "<p><p>", "</p><p>")
    #
    # # separate articles
    # html <- stri_replace_all_fixed(html, "<h1>", "<doc><h1>")
    # html <- stri_replace_all_fixed(html, "<p></p><br><p></p><br><p></p>", "</doc>")

    dom <- htmlParse(html, encoding = "UTF-8")

    length(getNodeSet(dom, "//*[name()='w:titlePg']"))
    getNodeSet(dom, '//w')

    data <- data.frame()
    for(doc in getNodeSet(dom, '//w:titlePg')){

        attrs <- list(pub = "", date = "", head = "", body = "")

        # h1s <- getNodeSet(doc, './h1')
        # if (length(h1s) == 1)
        #     attrs$head <- stri_trim_both(xmlValue(h1s[[1]]))
        #
        # h2s <- getNodeSet(doc, './h2')
        # if (length(h2s) == 2) {
        #     attrs$pub <- stri_trim_both(xmlValue(h2s[[1]]))
        #     time <- unlist(stri_split_fixed(stri_trim_both(xmlValue(h2s[[2]])), "."))
        #     attrs$date <- paste(rev(time), collapse = "-")
        # }
        #
        # ps <- getNodeSet(doc, './p')
        # if (length(ps) > 0) {
        #     p <- sapply(ps, xmlValue)
        #     attrs$body <- stri_trim(paste0(p, collapse = paste0(' ', paragraph_separator, ' ')))
        # }
        #
        # if (attrs$pub[1] == '' || is.na(attrs$pub[1])) warning('Failed to extract publication name')
        # if (attrs$date[1] == '' || is.na(attrs$date[1])) warning('Failed to extract date')
        # if (attrs$head[1] == '' || is.na(attrs$head[1])) warning('Failed to extract heading')
        # if (attrs$body[1] == '' || is.na(attrs$body[1])) warning('Failed to extract body text')
        #
        # data <- rbind(data, as.data.frame(attrs, stringsAsFactors = FALSE))
    }
    return(data)
}

import_doc("tests/data/nexis/nyt_1-50.docx")
