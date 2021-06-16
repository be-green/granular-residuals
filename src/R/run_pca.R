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

plan(multiprocess(workers = 4))

source("src/R/make_combined_data.R")

stock_returns <- fread("data/stock_returns.csv")
factor_returns <- get_factor_returns()

dur <- readxl::read_xlsx("data/dur_factor.xlsx") %>%
  as.data.table
setnames(dur, "date","Date")

dur[, Date := as.IDate(Date)]

factor_returns <- merge(dur, factor_returns, by = "Date")

port_returns <- get_portfolio_returns() %>%
  setorder(Date)


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

quick_ols <- compiler::cmpfun(function(X, y, w) {
  solve(crossprod(sqrt(w) * X, sqrt(w) * X)) %*% crossprod(sqrt(w) * X, sqrt(w) * y)
})

quick_ols_with_y <-
  compiler::cmpfun(function(X, y, w) {
    setDT(
      list(Values = c(quick_ols(X,y,w), weighted.mean(y, w = w)),
      Variables = c(colnames(X), "AvgRet")))
  })

quick_pred <- compiler::cmpfun(function(X, y, w) {
  as.vector(X %*% quick_ols(X, y, w))
})

quick_resid <-
  compiler::cmpfun(function(X, y, w) {
  y - quick_pred(X, y, w)
})

quick_gr <-
  compiler::cmpfun(
    function(X, y, w) {
      fit <- quick_ols(X, y, w)
      fit[1,] + y - as.vector(X %*% fit)
    }
)

quick_proj <- compiler::cmpfun(
  function(X, y, w) {
    as.vector(as.matrix(X[,2:ncol(X)])%*% quick_ols(X, y, w)[2:ncol(X), ])
  }
)

stock_returns <- transpose(stock_returns)

run_iv_pca <- function(stock_returns, factor_returns,
                       port_returns, window, weights = NA, ...) {
  dates <- unique(factor_returns$Date) %>% sort

  if(all(sapply(weights, is.na))) {
    weights = rep(1, length(dates))/length(dates)
  }

  all_coefs <- list()

  for (i in (window + start - 1):length(factor_returns$Date)) {

    w = weights[(i - window + 1):i]
    w = w/sum(w)
    dts <- dates[(i - window + 1):i]

    fr <- factor_returns[(i - window + 1):i,]
    sr <- stock_returns[,(i - window + 1):i]

    tsr <- transpose(sr[complete.cases(sr)])

    pcs <-  prcomp(
      tsr,
      scale. = F,
      center = F,
      rank. = 3
    )

    factors <- data.table(fr, pcs$x)

    factors[, ExMktProj := quick_proj(cbind(1, PC1, PC2, PC3), y = ExMkt, w = w)]
    factors[, GranResid := ExMkt - ExMktProj]

    factors[, OHML := quick_gr(X = cbind(1, ExMktProj),
                               y = HML,
                               w = w)]

    pr <- port_returns[Date %in% dts
                       ][
                         factors, on = "Date", nomatch = 0
                       ][
                         data.table(Date = dts, weight = w),
                         on = "Date", nomatch = 0
                       ]

    pr <- pr[, ExReturn := Return - RF][!is.na(ExReturn)]

    prProj <- pr[, quick_ols_with_y(y = ExReturn,
                                 X = cbind(ExMktProj,OHML),
                                 w = weight),
       by = Portfolio]

    prProj[,Ind := i - start - window + 2]

    all_coefs[[i - start - window + 2]] <- prProj


  }

  coef_data <- rbindlist(all_coefs) %>%
    dcast(as.formula(paste0(paste0(setdiff(colnames(all_coefs[[1]]),
                                    c("Variables", "Values")
                                    ), collapse = "+"
                            ), "~Variables")),
          value.var = "Values") %>%
    .[,Sort := str_extract(Portfolio, ".*(?=_[0-9]+)") %>%
        str_replace_all("_", " ") %>%
        str_to_title] %>%
    .[,PortfolioNumber := as.integer(str_extract(Portfolio, "[0-9]+$"))]

  annualize <- function(x, period = 12) {
    (1 + x)^period - 1
  }

  coef_data[,Return := annualize(AvgRet)*100]

  coef_data[]
}


run_with_weights <- function(n, factor_returns, stock_returns, port_returns, window, ...) {
  w <- rexp(nrow(factor_returns))
  run_iv_pca(stock_returns, factor_returns,
                          port_returns, window, weights = w, ...)
}

s <- proc.time()
run_with_weights(1,
                 factor_returns = factor_returns,
                 stock_returns = stock_returns,
                 port_returns = port_returns,
                 window = window)
e <- proc.time()

diff = e - s


booted <- future_map(1:400, run_with_weights,
                     factor_returns = factor_returns,
                     stock_returns = stock_returns,
                     port_returns = port_returns,
                     window = window, .progress = T, .options = furrr_options(seed = 123))




coef_data %>%
  split(by = c("Ind")) %>%
  lapply(function(x) lm(Return ~ ExMktProj + GranResid + OHML, data = x) %>%
           coef %>%
           t %>%
           as.data.table) %>%
  rbindlist(idcol = F) %>%
  .[,lapply(.SD, mean, na.rm = T)]

coef_data %>%
  .[,lapply(.SD, mean, na.rm = T), by = c("Portfolio", "Sort")] %>%
  lm(Return ~ ExMktProj + GranResid + OHML, data = .)
