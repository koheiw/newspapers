#' @rdname import
#' @import utils XML
#' @export
#' @examples
#' \dontrun{
#' # Nexis UK
#' irt <- import_nexis("tests/data/nexis/irish-times_1995-06-12_0001.html")
#' afp <- import_nexis("tests/data/nexis/afp_2013-03-12_0501.html")
#' gur <- import_nexis("tests/data/nexis/guardian_1986-01-01_0001.html")
#' spg <- import_nexis("tests/data/nexis/spiegel_2012-02-01_0001.html")
#' }
import_nexis <- function(path, paragraph_separator = "\n\n") {

    if (dir.exists(path)) {
        dir <- path
        file <- list.files(dir, full.names = TRUE, recursive = TRUE)
        data <- data.frame()
        for(f in file){
            if (stri_detect_regex(f, '\\.html$|\\.htm$|\\.xhtml$', case_insensitive = TRUE)){
                data <- rbind(data, import_nexis_uk_html(f, paragraph_separator))
            }
        }
    } else if (file.exists(path)) {
        data <- import_nexis_uk_html(path, paragraph_separator)
    } else {
        stop(path, " does not exist")
    }
    return(data)
}
