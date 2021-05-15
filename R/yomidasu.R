#' @rdname import
#' @import utils XML
#' @export
#' @examples
#' \dontrun{
#' # Yomidasu
#' yom <- import_yomidasu("tests/data/yomidasu/yomidasu_1987-01-01_001.html")
#' }
import_yomidasu <- function(path, paragraph_separator = "\n\n") {
    import_html(path, paragraph_separator, "yomidasu")
}

import_yomidasu_html <- function(file, paragraph_separator){

    #Convert format
    cat("Reading", file, "\n")

    line <- readLines(file, warn = FALSE, encoding = "UTF-8")
    html <- paste0(line, collapse = "\n")

    #Load as DOM object
    dom <- htmlParse(html, encoding = "UTF-8")
    data <- data.frame()
    for (node in getNodeSet(dom, '//div[@id="heiseiDetailArea"]/table[@class="contentsTable"]')) {
        attrs <- extract_yomidasu_attrs(node, paragraph_separator)
        if (attrs$date[1] == "")
            warning('Failed to extract date in ', file, call. = FALSE)
        if (attrs$head[1] == "")
            warning('Failed to extract heading in ', file, call. = FALSE)
        if (attrs$length[1] != "\U5B57" && attrs$body[1] == "")
            warning('Failed to extract body text in ', file, call. = FALSE)
        data <- rbind(data, as.data.frame(attrs, stringsAsFactors = FALSE))
    }

    data$date <- stri_replace_first_regex(data$date, "(\\d+)\\.(\\d+)\\.(\\d+)", "$1-$2-$3")
    data$page <- as.numeric(stri_replace_all_regex(data$page, "[^0-9]", ""))
    data$length <- as.numeric(stri_replace_all_regex(data$length, "[^0-9]", ""))
    data$file <- basename(file)

    return(data)
}

extract_yomidasu_attrs <- function(node, paragraph_separator) {

    attrs <- list(edition = "", date = "", length = "", section = "", head = "", body = "")

    ps <- getNodeSet(node, '../following-sibling::div[1]//p[@class="mb10"]//text()')
    p <- sapply(ps, xmlValue)
    attrs$body <- stri_replace_all_regex(paste0(p, collapse = ""), "\\p{P}\\p{Z}",
                                         paste0("\U3002", paragraph_separator))

    tds <- getNodeSet(node, './/tr/th')
    attrs$date <- clean_text(xmlValue(tds[[2]]))
    attrs$head <- clean_text(xmlValue(tds[[3]]))
    attrs$edition <- clean_text(xmlValue(tds[[4]]))
    attrs$section <- clean_text(xmlValue(tds[[5]]))
    attrs$page <- clean_text(xmlValue(tds[[6]]))
    attrs$length <- clean_text(xmlValue(tds[[7]]))

    return(attrs)
}
