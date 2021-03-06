% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Functions.R
\name{prep_for_transcribing}
\alias{prep_for_transcribing}
\title{Function to Prepare Text for Transcribing Values}
\usage{
prep_for_transcribing(x, char_per_line = 50)
}
\arguments{
\item{x}{A character string.}

\item{char_per_line}{An integer giving the preferred
character limit each line of text should not exceed.}
}
\value{
A character string that can be processed with
  \code{\link{wtext}} once placeholder '[[?]]' instances
  have been updated.
}
\description{
A function to identify cases within a raw character
string where numeric values can be transcibed,
inserting a placeholder '[[?]]' that can then be
adapted for use with the \code{\link{wtext}} function.
}
\examples{
# Example string
x = "Here are three values to update: 1.0, 2.0, and 3.0."
string = prep_for_transcribing( x )
# Identify placeholder positions
pos = which( strsplit( string, split = "" )[[1]] == "?" )
for ( i in 1:length(pos) )
  substr( string, pos[i], pos[i] ) = as.character( i )

# Update values with 'wtext'
wtext( string, strip_dbl = T, values = c( 4, 5, 7 ) )

}
