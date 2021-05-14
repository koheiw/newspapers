#' @rdname import
#' @import utils XML
#' @export
#' @examples
#' \dontrun{
#' # Lexis Advance
#' nyt <- import_lexis("tests/data/lexis/nyt1.docx")
#' ust <- import_lexis("tests/data/lexis/usa-today.docx")
#' wsp <- import_lexis("tests/data/lexis/washington-post.docx")
#' all <- import_lexis("tests/data/lexis/")
#' }
import_lexis <- function(path, paragraph_separator = "\n\n"){

    if (dir.exists(path)) {
        dir <- path
        file <- list.files(dir, full.names = TRUE, recursive = TRUE)
        data <- data.frame()
        for(f in file){
            if (stri_detect_regex(f, '\\.docx$', case_insensitive = TRUE)){
                data <- rbind(data, import_lexis_advance_docx(f, paragraph_separator))
            }
        }
    } else if (file.exists(path)) {
        data <- import_lexis_advance_docx(path, paragraph_separator)
    } else {
        stop(path, " does not exist")
    }
    return(data)
}
