# newspapers

Import files downloaded from newspaper databases

## Supported databases and formats

Database | File type | Function
-- | -- | --
Asahi Shimbun Kikuzo | .html | `import_kikuzo()`
Yomiuri Shimbun Yomidasu | .html | `import_yomidasu()`
Dow Jones Faciva | .html | `import_factiva()`
Nexis UK and Nexis Advance | .docx .html | `import_nexis()`
Integrum | .xlsx | `import_integrum()`

## Install the package

```
install.packages("devtools")
devtools::install_github("koheiw/newspapers")
```
## Download HTML files

### Asahi Shimbun Kikuzo

In the Kikuzo database, you can display up to 100 full-texts news articles in your browser. However, you cannot download the articles as an HTML file in a format this package can read, becasue news articles are in frames. To save the articles, you should use Firefox's context menu "Save Frame As" (or other browsers' equivalent) to save pages in a frame.

![](images/kikuzo.png)

### Dow Jones Faciva

The Factiva database offers a button to display full-texts in a pop-up window: check all boxes, click "Format for Saving" (Floppy Disk icon) and select "Article Format". You only need to save the HTML file in the pop-up window by "Save Page" (or press Ctrl + S).

![](images/factiva.png)
