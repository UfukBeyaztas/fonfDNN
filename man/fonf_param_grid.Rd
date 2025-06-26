\name{fonf_param_grid}
\alias{fonf_param_grid}
\title{
Create a Parameter Grid Without Factors
}
\description{
Generates a data frame from all combinations of input vectors, ensuring that character variables are not converted to factors. This is a convenient wrapper around \code{expand.grid(..., stringsAsFactors = FALSE)}.
}
\usage{
fonf_param_grid(...)
}
\arguments{
  \item{...}{
  One or more vectors, factors, or lists to be combined into a data frame of parameter combinations.
  }
}
\details{
This function simplifies the creation of parameter grids for tuning models. Unlike the base R \code{expand.grid}, it ensures that character vectors remain as characters, which is often desirable when building machine learning or neural network models where hyperparameter names or tags are string-based.
}
\value{
A data frame containing one row for each combination of the supplied vectors.
}
\author{
Ufuk Beyaztas, Gizel Bakicierler Sezer
}
\note{
This function is mainly used to build cross-product grids of model parameters when performing grid search for tuning.
}
