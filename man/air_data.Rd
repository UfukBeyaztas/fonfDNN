\name{air_data}
\alias{air_data}
\title{
Air Quality Dataset from Lombardy, Italy (2023–2024)
}
\description{
A real-world dataset containing daily air pollution measurements from the Lombardy region in Italy, covering the years 2023 and 2024. This dataset includes functional trajectories of various pollutants recorded over time across 1481 monitoring stations, and serves as the empirical application for the proposed hybrid deep tensor network (HDTN) model for function-on-function regression with mixed predictors.
}
\usage{
data(air_data)
}
\format{
A list with the following components:
\describe{
  \item{\code{y}}{A matrix of dimension \code{n x M} representing the functional response curves (daily mean \eqn{\text{PM}_{2.5}} concentrations), where \code{n} is the number of stations and \code{M} is the number of grid points.}
  \item{\code{x}}{A list of length 5, where each element is an \code{n x M} matrix corresponding to a functional predictor:
    \enumerate{
      \item Daily mean \eqn{\text{NO}_2} concentration,
      \item Daily maximum 1-hour \eqn{\text{NO}_2} concentration,
      \item Daily maximum 8-hour \eqn{\text{O}_3} concentration,
      \item Daily maximum 1-hour \eqn{\text{O}_3} concentration,
      \item Daily mean \eqn{\text{PM}_{10}} concentration.
    }
  }
  \item{\code{xscl}}{A matrix of dimension \eqn{n \times 3} containing scalar predictors:
  }
}
}
\details{
This dataset is sourced from the ARPA Lombardy regional environmental monitoring agency and was accessed using the \code{ARPALData} package. It is used in the empirical section of the paper to demonstrate the effectiveness of the HDTN model in predicting fine particulate matter concentrations based on mixed-type predictors (functional and scalar).
}
\value{
A list containing the functional response and covariate data required to fit the HDTN model, including:
\item{y}{Functional response (\eqn{\text{PM}_{2.5}} curves)}
\item{x}{List of 5 functional covariate matrices}
\item{xscl}{Matrix of scalar covariates}
}
\references{
Maranzano, M., and Algieri, C. (2024). ARPALData: An R package for retrieving and analyzing air quality and weather data from ARPA Lombardia (Italy). \emph{Environmental and Ecological Statistics}, 31(2), 187-218.
}
\note{
The dataset has been preprocessed and standardized for modeling purposes. Time series lengths and grid structures are aligned for all stations.
}
\examples{
## NOTE: This example involves ultra high-dimensional functional data.
## Running the model may require a PC with at least 64 GB of RAM.

# data(air_data)

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
