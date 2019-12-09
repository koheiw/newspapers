
import_lexis_advance_docx <- function(file, paragraph_separator) {
    cat('Reading', file, '\n')

    unzip(file, "word/document.xml", exdir = tempdir())
    xml <- paste0(readLines(paste0(tempdir(), "/word/document.xml"),
                            warn = FALSE, encoding = "UTF-8"), collapse = "")
    dom <- xmlParse(xml, encoding = "UTF-8")
    #elems <- getNodeSet(dom, "//w:p[.//w:outlineLvl]")
    #elems <- getNodeSet(dom, "//w:body/w:p[./w:hyperlink]")
    #elems <- getNodeSet(dom, "//w:p[./w:hyperlink]")
    #elems <- getNodeSet(dom, "//w:p[./w:bookmarkEnd]/following-sibling::w:p[1]")
    elems <- getNodeSet(dom, "//w:p[./w:bookmarkEnd and not(.//w:t) and not(.//w:r)]")

    n <- length(elems)
    data <- data.frame()
    for (i in seq(n)) {
        attrs <- list(pub = "", date = "", head = "", body = "", section = "", length = 0)
        elem <- elems[[i]]
        body <- character()
        #is_header <- FALSE
        is_body <- FALSE
        ignore <- FALSE
        j <- 1
        while (TRUE) {
            str <- stri_trim(xmlValue(elem))
            if (stri_detect_regex(str, "^End of Document$|^Load-Date:\\s")) break
            #cat(j, "\n")
            #print(str)
            if (stri_detect_regex(str, "^Body$")) {
                is_body <- TRUE
                elem <- getSibling(elem, after = TRUE)
                next
            }
            if (!is_body && !ignore) {
                if (!is.na(str) && str != "") {
                    if (j == 1) {
                        attrs$head <- str
                        j <- j + 1
                    } else if (j == 2) {
                        attrs$pub <- str
                        j <- j + 1
                    } else if (j == 3) {
                        attrs$date <- str
                        j <- j + 1
                    }
                }
                if (stri_detect_regex(str, "^Section:\\s")) {
                    attrs$section <- stri_trim(stri_replace_first_regex(str, "^Section:\\s", ""))
                } else if (stri_detect_regex(str, "^Length:\\s")) {
                    attrs$length <- stri_trim(stri_replace_first_regex(str, "Length:\\s(\\d+)\\swords", "$1"))
                }
            }
            if (stri_detect_regex(str, "^(ABSTRACT|Classification|Graphic)$")) {
                ignore <- TRUE
            }
            if (is_body && !ignore) {
                body <- c(body, str)
            }
            if (stri_detect_regex(str, "^(FULL TEXT)$")) {
                ignore <- FALSE
            }
            elem <- getSibling(elem, after = TRUE)
            if (is.null(elem)) break
            if (i < n && identical(elem, elems[[i + 1]])) break

        }
        body <- body[nzchar(body)]
        attrs$body <- paste(body, collapse = "\\n ")
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
