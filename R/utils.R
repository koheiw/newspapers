
import_html <- function(path, paragraph_separator = "\n\n", source){

    result <- data.frame()
    if (dir.exists(path)) {
        dir <- path
        file <- list.files(dir, full.names = TRUE, recursive = TRUE)
        for(f in file){
            if(stri_detect_regex(f, '\\.html$|\\.htm$|\\.xhtml$', ignore.case = TRUE) && file.size(f)) {
                tryCatch({
                    if (source == "kikuzo") {
                        result <- rbind(result, import_kikuzo_html(f, paragraph_separator))
                    } else if (source == "yomidasu") {
                        result <- rbind(result, import_yomidasu_html(f, paragraph_separator))
                    } else if (source == "factiva") {
                        result <- rbind(result, import_factiva_html(f, paragraph_separator))
                    }
                },
                error = function(e) {
                    warning("Invalid file format: ", f)
                })
            }
        }
    } else if (file.exists(path) && file.size(path)) {
        if (source == "kikuzo") {
            result <- import_kikuzo_html(path, paragraph_separator)
        } else if (source == "yomidasu") {
            result <- import_yomidasu_html(path, paragraph_separator)
        } else if (source == "factiva") {
            result <- import_factiva_html(path, paragraph_separator)
        }
    } else {
        stop(path, " does not exist")
    }
    return(result)
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
#' @param ... additional arguments passed to \code{plot}
#' @import graphics grDevices
#' @export
check_gaps <- function(x, size = 7, plot = TRUE, from = NULL, to = NULL, ...) {

    if (class(x$date) != "Date" )
        stop("x must have a date column")

    x <- x[!is.na(x$date),,drop = FALSE]
    if (is.null(from))
        from <- min(x$date)
    if (is.null(to))
        to <- max(x$date)

    x <- subset(x, from <= date & date <= to)
    tb <- table(factor(as.character(x$date),
                       levels = as.character(seq.Date(as.Date(from), as.Date(to), by = "1 day"))))
    plot(as.Date(names(tb)), as.numeric(tb), type = "h",
         ylab = "Frequency", xlab = "", xaxt = "n", lend = 2, ...)

    is_year <- stri_endswith_fixed(names(tb), "01-01")
    is_month <- stri_endswith_fixed(names(tb), "01")
    if (length(names(tb)) > 365) {
        is_first <- stri_endswith_fixed(names(tb), "01-01")
        axis(1, as.Date(names(tb))[is_year], stri_sub(names(tb)[is_year], 1, 4))
        axis(1, as.Date(names(tb))[is_month], labels = NA, tck = 0.01)
    } else {
        axis(1, as.Date(names(tb))[is_month], stri_sub(names(tb)[is_month], 1, 7))
        axis(1, as.Date(names(tb)), labels = NA, tck = 0.01)
    }

    date <- unique(sort(x$date))
    l <- diff(date) >= size
    m <- max(tb)
    if (any(l)) {
        warning("There are ", size, "-day gaps after ", paste(date[l], collapse = ", "), call. = FALSE)
        for (i in seq_along(l)) {
            if (date[i + 1] - date[i] >= size) {
                polygon(c(date[i], date[i], date[i + 1], date[i + 1], date[i]),
                        c(m, 0, 0, m, m),
                        col = rgb(1, 0, 0, 0.5), border = FALSE)
            }
        }
    }
}
