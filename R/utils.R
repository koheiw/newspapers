
import_html <- function(path, paragraph_separator = "|", source){

    if (dir.exists(path)) {
        dir <- path
        file <- list.files(dir, full.names = TRUE, recursive = TRUE)
        data <- data.frame()
        for(f in file){
            if(stri_detect_regex(f, '\\.html$|\\.htm$|\\.xhtml$', ignore.case = TRUE) && file.size(f)) {
                tryCatch({
                    if (source == "kikuzo") {
                        data <- rbind(data, import_kikuzo_html(f, paragraph_separator))
                    } else if (source == "yomidasu") {
                        data <- import_yomidasu_html(f, paragraph_separator)
                    } else if (source == "factiva") {
                        data <- rbind(data, import_factiva_html(f, paragraph_separator))
                    }
                },
                error = function(e) {
                    warning("Invalid file format: ", f)
                })
            }
        }
    } else if (file.exists(path) && file.size(path)) {
        if (source == "kikuzo") {
            data <- import_kikuzo_html(path, paragraph_separator)
        } else if (source == "yomidasu") {
            data <- import_yomidasu_html(path, paragraph_separator)
        } else if (source == "factiva") {
            data <- import_factiva_html(path, paragraph_separator)
        }
    } else {
        stop(path, " does not exist")
    }
    return(data)
}

#' @import stringi
clean_text <- function(str) {
    str <- stri_replace_all_regex(str, '[[:^print:]]', ' ');
    str <- stri_replace_all_regex(str, "[\\r\\n\\t]", ' ')
    str <- stri_replace_all_regex(str, "\\s\\s+", ' ')
    str <- stri_trim(str);
    return(str)
}

is_number <- function(x) {
    suppressWarnings({
        x <- as.numeric(x)
    })
    if (any(is.na(x))) {
        return(FALSE)
    }
    return(TRUE)
}

#' Check and plot gaps in data
#'
#' @param x out from import functions, or any data.frame with "date" column
#' @param size size of gap to detect specified in number of days, defaults to 7 days
#' @param plot if \code{TRUE}, plot the number of items for each day
#' @param from start of the data collection period
#' @param to end of the data collection period
#' @import graphics
#' @export
check_gaps <- function(x, size = 7, plot = TRUE, from = NULL, to = NULL) {

    if (class(x$date) != "Date" )
        stop("data.frame must have a date column")
    d <- sort(x$date)

    if (is.null(from))
        from <- min(d)
    if (is.null(to))
        to <- min(d)

    tb <- table(factor(as.numeric(d), levels = seq.Date(as.Date(from), as.Date(to), by = "1 day")))
    plot(tb, xaxt = "n", ylab = "Frequency")
    axis(1, seq_along(tb), names(tb))

    l <- diff(d) >= size
    if (any(l)) {
        warning("There are gaps after ", paste(d[l], collapse = ", "))
        points(match(as.character(d[l]), names(tb)), rep(0, length(d[l])), col = "red")
    }
}


