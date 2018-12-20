#' Extract texts and meta data from Nexis files
#'
#' This extract headings, body texts and meta data (date, byline, length,
#' secotion, edntion) from items in HTML or MS Word files downloaded from the Nexis
#' database.
#' @param path either path to a file or a directory that containe files
#' @param paragraph_separator a character to sperarate paragrahphs in body
#'   texts.
#' @param language_date a character to specify langauge-dependent date format.
#' @param raw_date return date of publication without parsing if \code{TRUE}.
#' @param variant specify type of Nexis database files downloaded. Files should
#'   be HTML (.html) for Nexis UK or MS Word (.docx) for Nexis Advance.
#' @import utils XML
#' @export
#' @examples
#' \dontrun{
#' # Nexis UK
#' irt <- import_nexis("tests/data/nexis/irish-times_1995-06-12_0001.html")
#' afp <- import_nexis("tests/data/nexis/afp_2013-03-12_0501.html")
#' gur <- import_nexis("tests/data/nexis/guardian_1986-01-01_0001.html")
#' spg <- import_nexis("tests/data/nexis/spiegel_2012-02-01_0001.html", language_date = "german")
#' all <- import_nexis("tests/data/nexis", raw_date = TRUE)
#'
#' # Nexis Advance
#' nyt <- import_nexis("tests/data/nexis/nyt.docx", variant = "advance")
#' ust <- import_nexis("tests/data/nexis/usa-today.docx", variant = "advance")
#' wsp <- import_nexis("tests/data/nexis/washington-post.docx", variant = "advance")
#' all <- import_nexis("tests/data/nexis/", variant = "advance")
#' }
import_nexis <- function(path, paragraph_separator = '|', language_date = c('english', 'german'), raw_date = FALSE,
                         variant = c("uk", "advance")){

    language_date <- match.arg(language_date)
    variant <- match.arg(variant)

    if (dir.exists(path)) {
        dir <- path
        file <- list.files(dir, full.names = TRUE, recursive = TRUE)
        data <- data.frame()
        for(f in file){
            if (variant == "uk") {
                if(stri_detect_regex(f, '\\.html$|\\.htm$|\\.xhtml$', ignore.case = TRUE)){
                    data <- rbind(data, import_nexis_uk_html(f, paragraph_separator, language_date, raw_date))
                }
            } else {
                if(stri_detect_regex(f, '\\.docx$', ignore.case = TRUE)){
                    data <- rbind(data, import_nexis_advance_docx(f, paragraph_separator, language_date, raw_date))
                }
            }
        }
    } else if (file.exists(path)) {
        if (variant == "uk") {
            data <- import_nexis_uk_html(path, paragraph_separator, language_date, raw_date)
        } else {
            data <- import_nexis_advance_docx(path, paragraph_separator, language_date, raw_date)
        }
    } else {
        stop(path, " does not exist")
    }
    return(data)
}
