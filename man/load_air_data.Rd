\name{load_air_data}
\alias{load_air_data}
\title{
Download and Load the External Air Quality Dataset
}
\description{
Downloads the large \code{air_data.RData} file (47 MB) from a Dropbox URL and loads it into the global environment. This is a workaround to bypass GitHub's file size limit for storing large datasets within an R package.
}
\usage{
load_air_data(destdir = tempdir(), verbose = TRUE)
}
\arguments{
  \item{destdir}{
  A directory path where the downloaded \code{air_data.RData} file will be saved locally. Defaults to a temporary directory.
  }
  \item{verbose}{
  Logical. If \code{TRUE}, status messages are printed during download and loading.
  }
}
\details{
This function is intended for use with the \code{air_data} dataset used in the HDTN (Hybrid Deep Tensor Network) model for function-on-function regression. The dataset includes:
\itemize{
  \item \code{y}: a matrix of functional response curves (daily mean \eqn{\text{PM}_{2.5}} levels),
  \item \code{x}: a list of 5 functional predictor matrices,
  \item \code{xscl}: a matrix of scalar covariates.
}
Due to the large size of the dataset, it is not bundled with the package and must be downloaded separately via this function.
}
\value{
Loads the object \code{air_data} into the global environment. This object is a list with elements:
  \item{y}{A matrix of dimension \eqn{n \times M} representing functional responses.}
  \item{x}{A list of 5 \eqn{n \times M} functional predictor matrices.}
  \item{xscl}{A matrix of dimension \eqn{n \times 3} for scalar covariates.}
}
\references{
Maranzano, M., and Algieri, C. (2024). ARPALData: An R package for retrieving and analyzing air quality and weather data from ARPA Lombardia (Italy). \emph{Environmental and Ecological Statistics}, 31(2), 187-218.
}
\author{
Ufuk Beyaztas, Gizel Bakicierler Sezer, and Han Lin Shang
}
\note{
This function downloads a 47 MB file from Dropbox. A stable internet connection is required. The file is cached locally but may be removed between sessions unless a permanent directory is specified.
}

\examples{

# Download and load the dataset into the workspace
# load_air_data()

## NOTE: This example involves ultra high-dimensional functional data.
## Running the model may require a PC with at least 64 GB of RAM.

# y <- air_data$y
# x <- air_data$x
# xscl <- air_data$xscl

# ntot <- dim(y)[1]
# ntrain <- 1000
# ntest <- ntot - ntrain

# train_ind <- sample(1:ntot, ntrain, replace = FALSE)

# Training sample
# y_train <- y[train_ind, ]
# y_test  <- y[-train_ind, ]
# xscl_train <- xscl[train_ind, ]
# xscl_test  <- xscl[-train_ind, ]

# Test sample
# x_train <- x_test <- vector("list", length = 5)
# for (j in 1:5) {
#   x_train[[j]] <- x[[j]][train_ind, ]
#   x_test[[j]]  <- x[[j]][-train_ind, ]
# }

# Train HDTN approach
# nfof_model <- fonf_fit(resp = y_train, func_cov = x_train, scalar_cov = xscl_train)

# Obtain predictions with conformal prediction intervals
# band <- fonf_predict(nfof_model,
#                      func_cov_new   = x_test,
#                      scalar_cov_new = xscl_test,
#                      interval       = "conformal")
}
