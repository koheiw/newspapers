require(XML)
require(stringi)
require(xml2)



#out <- antiword::antiword("tests/data/nexis/nyt.docx")
#out <- docx_extract_all_tbls(read_docx("tests/data/nexis/nyt.docx"))

#import_doc <- function(file, paragraph_separator) {
    #file <- "tests/data/nexis/nyt.docx"
    file <- "tests/data/nexis/usa-today.docx"
    #file <- "tests/data/nexis/washington-post.docx"
    cat('Reading', file, '\n')

    unzip(file, "word/document.xml", exdir = tempdir())
    file <- paste0(tempdir(), "/word/document.xml")
    xml <- paste0(readLines(file, warn = FALSE, encoding = "UTF-8"), collapse = "")
    dom <- xmlParse(xml, encoding = "UTF-8")
    elems <- getNodeSet(dom, "//w:p[./w:hyperlink/w:r/w:rPr/w:sz[@w:val='28'] and
                                   ./w:hyperlink/w:r/w:rPr/w:color[@w:val='0077CC']]")
    n <- length(elems)
    data <- data.frame()
    for (i in seq(n)) {
        if (i + 1 > n) break
        attrs <- list(pub = "", date = "", head = "", body = "")
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
            if (stri_detect_regex(str, "^Load-Date:\\s")) {
                break
            }
            if (j == 1)
                attrs$head <- str
            if (j == 2)
                attrs$pub <- str
            if (j == 3)
                attrs$date <- str
            #if (str == "End of Document") break
            if (stri_detect_regex(str, "^Section:\\s"))
                attrs$section <- stri_trim(stri_replace_first_regex(str, "^Section:\\s", ""))
            if (stri_detect_regex(str, "^Length:\\s"))
                attrs$length <- stri_trim(stri_replace_first_regex(str, "Length:\\s(\\d+)\\swords", "$1"))
            if (is_body)
                body <- c(body, str)
            if (str == "Body") is_body <- TRUE
            elem <- getSibling(elem, after = TRUE)
            if (identical(elem, elems[[i + 1]])) break
            if (is.null(elem)) break
            j <- j + 1
        }
        body <- body[nzchar(body)]
        attrs$body <- paste(body, collapse = " ")
        data <- rbind(data, as.data.frame(attrs, stringsAsFactors = FALSE))
    }

#    return(data)
#}

#import_doc("tests/data/nexis/nyt_1-50.docx")
