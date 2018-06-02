
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

