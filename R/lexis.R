#' Extract texts and meta data from Lexis files
#'
#' This extract headings, body texts and meta data (date, byline, length,
#' secotion, edntion) from items in HTML or MS Word files downloaded from the
#' Lexis database.
#' @param path either path to a file or a directory that containe files
#' @param paragraph_separator a character to sperarate paragrahphs in body
#'   texts.
#' @param variant specify type of Lexis database files downloaded. Files should be
#' MS Word (.docx) for Lexis Advance.
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
import_lexis <- function(path, paragraph_separator = "\n\n", variant = c("advance")){

    variant <- match.arg(variant)

    if (dir.exists(path)) {
        dir <- path
        file <- list.files(dir, full.names = TRUE, recursive = TRUE)
        data <- data.frame()
        for(f in file){
            if(stri_detect_regex(f, '\\.docx$', ignore.case = TRUE)){
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
