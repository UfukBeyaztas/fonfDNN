load_air_data <- function(destdir = tempdir(), verbose = TRUE) {
  url <- "https://www.dropbox.com/scl/fi/67ti444bslfpztzq5n2rm/air_data.RData?rlkey=bo2gr2uenc9orb1cuvv909rcw&st=99xllhnr&dl=1"
  destfile <- file.path(destdir, "air_data.RData")

  if (verbose) message("Downloading air_data.RData to ", destfile)

  utils::download.file(url, destfile, mode = "wb")
  load(destfile, envir = .GlobalEnv)

  if (verbose) message("`air_data` has been loaded into your workspace.")
}
