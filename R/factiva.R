#' @rdname import
#' @import utils XML
#' @export
#' @examples
#' \dontrun{
#' # Factiva
#' iri <- import_factiva("testthat/data/factiva/irish-independence_1_2017-11-14.html")
#' chi <- import_factiva("testthat/data/factiva/chosun_ilbo_1_2018-05-28.html")
#' all <- import_factiva("testthat/data/factiva")
#' }
#'
#'
import_factiva <- function(path, paragraph_separator = "\n\n") {
    import_html(path, paragraph_separator, "factiva")
}

import_factiva_html <- function(file, paragraph_separator){

    #Convert format
    cat('Reading', file, '\n')

    line <- readLines(file, warn = FALSE, encoding = "UTF-8")
    line <- stri_replace_all_fixed(line, c("<b>", "</b>"), "", vectorize_all = FALSE)
    html <- paste0(line, collapse = "\n")

    #Load as DOM object
    dom <- htmlParse(html, encoding = "UTF-8")

    data <- data.frame()
    for (node in getNodeSet(dom, '//div[contains(@class, "Article")]')) {
        node <- xmlParent(node)
        attrs <- extract_factiva_attrs(node, paragraph_separator)
        if (attrs$date[1] == "" || is.na(attrs$date[1]))
            warning('Failed to extract date in ', file, call. = FALSE)
        if (attrs$head[1] == "" || is.na(attrs$head[1]))
            warning('Failed to extract heading in ', file, call. = FALSE)
        if (attrs$body[1] == "" || is.na(attrs$body[1]))
            warning('Failed to extract body text in ', file, call. = FALSE)
        data <- rbind(data, as.data.frame(attrs, stringsAsFactors = FALSE))
    }

    data$length <- as.numeric(stri_replace_all_regex(data$length, "[^0-9]", ""))
    data$file <- basename(file)

    return(data)
}

extract_factiva_attrs <- function(node, paragraph_separator) {

    attrs <- list(date = "", length = "", section = "", head = "", body = "", source = "")

    ps <- getNodeSet(node, './/p[contains(@class, "articleParagraph")]//text()')
    p <- sapply(ps, xmlValue)
    attrs$body <- stri_trim(paste0(p, collapse = paste0(' ', paragraph_separator, ' ')))
    attrs$head <- clean_text(xmlValue(getNodeSet(node, './/span[contains(@class, "Headline")]')[[1]]))

    divs <- getNodeSet(node, './/div[not(@*)]')
    v <- sapply(divs, function(x) clean_text(xmlValue(x)))
    i <- min(which(stri_detect_regex(v, "^\\d+")))
    attrs$length <- v[i]
    attrs$date <- v[i + 1]
    attrs$source <- v[i + 2]
    attrs$section <- v[i + 4]

    return(attrs)
}
