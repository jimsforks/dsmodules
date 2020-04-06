#'@export
downloadTableUI <- function(id, text = "Download", formats = NULL, class = NULL) {

  ns <- NS(id)
  loadingGif <- "data:image/gif;base64,R0lGODlhEAALAPQAAP///wAAANra2tDQ0Orq6gYGBgAAAC4uLoKCgmBgYLq6uiIiIkpKSoqKimRkZL6+viYmJgQEBE5OTubm5tjY2PT09Dg4ONzc3PLy8ra2tqCgoMrKyu7u7gAAAAAAAAAAACH/C05FVFNDQVBFMi4wAwEAAAAh/hpDcmVhdGVkIHdpdGggYWpheGxvYWQuaW5mbwAh+QQJCwAAACwAAAAAEAALAAAFLSAgjmRpnqSgCuLKAq5AEIM4zDVw03ve27ifDgfkEYe04kDIDC5zrtYKRa2WQgAh+QQJCwAAACwAAAAAEAALAAAFJGBhGAVgnqhpHIeRvsDawqns0qeN5+y967tYLyicBYE7EYkYAgAh+QQJCwAAACwAAAAAEAALAAAFNiAgjothLOOIJAkiGgxjpGKiKMkbz7SN6zIawJcDwIK9W/HISxGBzdHTuBNOmcJVCyoUlk7CEAAh+QQJCwAAACwAAAAAEAALAAAFNSAgjqQIRRFUAo3jNGIkSdHqPI8Tz3V55zuaDacDyIQ+YrBH+hWPzJFzOQQaeavWi7oqnVIhACH5BAkLAAAALAAAAAAQAAsAAAUyICCOZGme1rJY5kRRk7hI0mJSVUXJtF3iOl7tltsBZsNfUegjAY3I5sgFY55KqdX1GgIAIfkECQsAAAAsAAAAABAACwAABTcgII5kaZ4kcV2EqLJipmnZhWGXaOOitm2aXQ4g7P2Ct2ER4AMul00kj5g0Al8tADY2y6C+4FIIACH5BAkLAAAALAAAAAAQAAsAAAUvICCOZGme5ERRk6iy7qpyHCVStA3gNa/7txxwlwv2isSacYUc+l4tADQGQ1mvpBAAIfkECQsAAAAsAAAAABAACwAABS8gII5kaZ7kRFGTqLLuqnIcJVK0DeA1r/u3HHCXC/aKxJpxhRz6Xi0ANAZDWa+kEAA7AAAAAAAAAAAA"

  tbl_formats <- formats
  if (is.null(formats)) tbl_formats <- "csv"

  addResourcePath(prefix = "downloadInfo", directoryPath = system.file("aux/", package = "dsmodules"))

  div(shiny::tagList(shiny::singleton(shiny::tags$body(shiny::tags$script(src = "downloadInfo/downloadGen.js")))),
      lapply(tbl_formats, function(z) {
        tagList(div(style = "text-align: center;",
                    `data-for-btn` = ns(paste0("DownloadTbl", z)),
                    downloadButton(ns(paste0("DownloadTbl", z)), paste0(text, " ", toupper(z)), class = class, style = "width: 200px;"),
                    span(class = "btn-loading-container",
                         img(src = loadingGif, class = "btn-loading-indicator", style = "display: none;"),
                         HTML("<i class = 'btn-done-indicator fa fa-check' style = 'display: none;'> </i>"))))
      }))

}


#'@export
downloadTable <- function(input, output, session, table = NULL, formats, name = "table") {

  ns <- session$ns
  tbl_formats <- formats

  lapply(tbl_formats, function(z) {
    buttonId <- ns(paste0("DownloadTbl", z))

    output[[paste0("DownloadTbl", z)]] <- downloadHandler(
      filename = function() {
        session$sendCustomMessage("setButtonState", c("loading", buttonId))
        if (is.reactive(name))
          name <- name()
        paste0(name, "-", gsub(" ", "_", substr(as.POSIXct(Sys.time()), 1, 19)), ".", z)
      },
      content = function(file) {
        if (is.reactive(table))
          table <- table()
        saveTable(table, filename = file, format = z)
        session$sendCustomMessage("setButtonState", c("done", buttonId))
      }
    )
  })

}


#'@export
saveTable <- function(tbl, filename, format = NULL, ...) {

  if (is.null(format)) {
    format <- tools::file_ext(filename) %||% "csv"
  }
  tmp <- paste(tempdir(), "csv", sep ='.')
  write.csv(tbl, tmp)
  tmpSave <- filename
  filename <- gsub("([^.]+)\\.[[:alnum:]]+$", "\\1", filename)
  if (format == "csv") {
    write.csv(tbl, paste0(filename, ".csv"))
  }
  if (format == "xlsx") {
    openxlsx::write.xlsx(tbl, paste0(filename, ".xlsx"))
  }
  if (format == "json") {
    jsonlite::write_json(tbl, paste0(filename, ".json"))
  }

}