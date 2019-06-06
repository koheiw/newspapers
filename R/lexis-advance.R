
import_lexis_advance_docx <- function(file, paragraph_separator, language_date, raw_date) {
    cat('Reading', file, '\n')

    unzip(file, "word/document.xml", exdir = tempdir())
    xml <- paste0(readLines(paste0(tempdir(), "/word/document.xml"),
                            warn = FALSE, encoding = "UTF-8"), collapse = "")
    dom <- xmlParse(xml, encoding = "UTF-8")
    elems <- getNodeSet(dom, "//w:p[./w:hyperlink/w:r/w:rPr/w:sz[@w:val='28'] and
                                   ./w:hyperlink/w:r/w:rPr/w:color[@w:val='0077CC']]")
    n <- length(elems)
    data <- data.frame()
    for (i in seq(n)) {
        attrs <- list(pub = "", date = "", head = "", body = "", section = "", length = 0)
        elem <- elems[[i]]
        body <- character()
        is_body <- FALSE
        j <- 1
        while (TRUE) {
            str <- stri_trim(xmlValue(elem))
            if (stri_detect_regex(str, "^\\(.{0,100}\\)$")) {
                elem <- getSibling(elem, after = TRUE)
                next
            }
            if (stri_detect_regex(str, "^Load-Date:\\s")) break
            if (j == 1)
                attrs$head <- str
            if (j == 2)
                attrs$pub <- str
            if (j == 3)
                attrs$date <- str
            if (stri_detect_regex(str, "^Section:\\s"))
                attrs$section <- stri_trim(stri_replace_first_regex(str, "^Section:\\s", ""))
            if (stri_detect_regex(str, "^Length:\\s"))
                attrs$length <- stri_trim(stri_replace_first_regex(str, "Length:\\s(\\d+)\\swords", "$1"))
            if (is_body)
                body <- c(body, str)
            if (str == "Body") is_body <- TRUE
            elem <- getSibling(elem, after = TRUE)
            #if (is.null(elem)) break
            if (i < n && identical(elem, elems[[i + 1]])) break
            j <- j + 1
        }
        body <- body[nzchar(body)]
        attrs$body <- paste(body, collapse = " ")
        if (attrs$pub[1] == '' || is.na(attrs$pub[1]))
            warning('Failed to extract publication name in ', file, call. = FALSE)
        if (attrs$date[1] == '' || is.na(attrs$date[1]))
            warning('Failed to extract date in ', file, call. = FALSE)
        if (attrs$head[1] == '' || is.na(attrs$head[1]))
            warning('Failed to extract heading in ', file, call. = FALSE)
        if (attrs$body[1] == '' || is.na(attrs$body[1]))
            warning('Failed to extract body text in ', file, call. = FALSE)
        data <- rbind(data, as.data.frame(attrs, stringsAsFactors = FALSE))
    }
    return(data)
}
