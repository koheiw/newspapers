
# newspapers

Import files downloaded from newspaper databases

## Supported databases and formats

| Database                 | File type | Function            |
| ------------------------ | --------- | ------------------- |
| Asahi Shimbun Kikuzo     | .html     | `import_kikuzo()`   |
| Yomiuri Shimbun Yomidasu | .html     | `import_yomidasu()` |
| Dow Jones Faciva         | .html     | `import_factiva()`  |
| Nexis UK                 | .html     | `import_nexis()`    |
| Lexis Advance            | .docx     | `import_lexis()`    |
| Integrum                 | .xlsx     | `import_integrum()` |

## Install the package

``` r
install.packages("devtools")
devtools::install_github("koheiw/newspapers")
```

## Import files

``` r
require(newspapers, quietly = TRUE)
dat <- import_nexis("tests/data/nexis/guardian_1986-01-01_0001.html")
## Reading tests/data/nexis/guardian_1986-01-01_0001.html
dat$date <- as.Date(dat$date)
```

| pub                   | edition | date       | byline               | length | section | head                                                                                                      |
| :-------------------- | :------ | :--------- | :------------------- | :----- | :------ | :-------------------------------------------------------------------------------------------------------- |
| The Guardian (London) |         | 1986-06-05 | By JEREMY LEGGET     | 1269   |         | Eavesdroppers who heard the guilty secrets / Covert nuclear tests by the US and Britain detected          |
| The Guardian (London) |         | 1986-06-05 | By VICTORIA BRITTAIN | 663    |         | Third World Column: Uganda tries again / National Resistance Movement takes power                         |
| The Guardian (London) |         | 1986-06-05 | By RICHARD LAPPER    | 1007   |         | Third World Review: A bad bisnes in Managua / Nicaragua’s black economy                                   |
| The Guardian (London) |         | 1986-06-05 |                      | 60     |         | Financial News in Brief / British Government support for ICI Alcan tax case in California                 |
| The Guardian (London) |         | 1986-06-05 | By MICHAEL SIMMONS   | 401    |         | Minister predicts downturn in Singaporean economy                                                         |
| The Guardian (London) |         | 1986-06-05 | From MARK TRAN       | 350    |         | Aid appeal get cool reception / US Administration’s proposals to increase the foreign aid budget flounder |

## Download files

### Asahi Shimbun Kikuzo

In the Kikuzo database, you can display up to 100 full-texts news
articles in your browser. However, you cannot download the articles as
an HTML file in a format this package can read, becasue news articles
are in frames. To save the articles, you should use Firefox’s context
menu “Save Frame As” (or other browsers’ equivalent) to save pages in a
frame.

![](images/kikuzo.png)

### Dow Jones Faciva

The Factiva database offers a button to display full-texts in a pop-up
window: check all boxes, click “Format for Saving” (Floppy Disk icon)
and select “Article Format”. You only need to save the HTML file in the
pop-up window by “Save Page” (or press Ctrl + S).

![](images/factiva.png)
