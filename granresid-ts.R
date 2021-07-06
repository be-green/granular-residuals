# get time series of granular residuals
# through PCA procedure

library(data.table)
library(magrittr)
library(future)
library(furrr)

is_zero <- function(x) {
  x == 0
}

replaceZeros <- function(DT) {
  # or by number (slightly faster than by name) :
  for (j in seq_len(ncol(DT)))
    set(DT,which(is_zero(DT[[j]])),j,NaN)
}

filterCols <- function(DT, f) {
  DT[, which(sapply(DT, f)), with = F]
}

subtractRFCol <- function(DT, col) {
  for(j in 1:ncol(DT)) {
    set(DT, j = j, value = DT[[j]]/100 - col)
  }
}

# plan(multiprocess(workers = 4))

source("src/R/make_combined_data.R")

# matrix of stock returns
stock_returns <- fread("data/stock_returns.csv")

# FF3
factor_returns <- get_factor_returns()

# portfolio sort returns
port_returns <- get_portfolio_returns() %>%
  setorder(Date)

# 5 year window
window <- 60

# replace zeros with NA
# to better represent missing
# set edits the variable in place
replaceZeros(
  stock_returns
)

# subtract risk-free rate from all stock returns
# to generate excess returns
subtractRFCol(
  stock_returns,
  col = factor_returns$RF
)

start <- which(factor_returns$Date == as.Date("1963-01-31"))

quick_ols <- compiler::cmpfun(function(X, y) {
  solve(crossprod(X, X)) %*% crossprod(X, y)
})

quick_ols_with_y <-
  compiler::cmpfun(function(X, y) {
    setDT(
      list(Values = c(quick_ols(X,y), mean(y)),
           Variables = c(colnames(X), "AvgRet")))
  })

quick_pred <- compiler::cmpfun(function(X, y) {
  as.vector(X %*% quick_ols(X, y))
})

quick_resid <-
  compiler::cmpfun(function(X, y) {
    y - quick_pred(X, y)
  })

quick_gr <-
  compiler::cmpfun(
    function(X, y) {
      fit <- quick_ols(X, y)
      fit[1,] + y - as.vector(X %*% fit)
    }
  )

quick_proj <- compiler::cmpfun(
  function(X, y) {
    as.vector(as.matrix(X[,2:ncol(X)])%*% quick_ols(X, y)[2:ncol(X), ])
  }
)

stock_returns <- transpose(stock_returns)


dates <- unique(factor_returns$Date) %>% sort

all_coefs <- list()

# rolling projection of market on principal components
for (i in (window + start - 1):length(factor_returns$Date)) {

  dts <- dates[(i - window + 1):i]

  fr <- factor_returns[(i - window + 1):i,]
  sr <- stock_returns[,(i - window + 1):i]

  # transpose stock returns
  tsr <- transpose(sr[complete.cases(sr)])

  # get principal components
  pcs <- prcomp(
    tsr,
    scale. = F,
    center = F,
    rank. = 3
  )

  # combine w/ factors
  factors <- data.table(fr, pcs$x)

  # project market projection
  factors[, ExMktProj := quick_proj(cbind(1, PC1, PC2, PC3), y = ExMkt)]

  # GR values
  factors[, GranResid := ExMkt - ExMktProj]

  # HML that is orthogonal to this market factor
  factors[, OHML := quick_gr(X = cbind(1, ExMktProj),
                             y = HML)]

  # grab last one and put it in a list
  all_coefs[[i - start - window + 2]] <- tail(factors, 1)
}

# save to CSV
rbindlist(all_coefs) %>%
  fwrite("data/GR_time_series.csv")
