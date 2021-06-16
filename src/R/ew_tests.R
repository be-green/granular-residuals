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

# return regression coefficients and average returns
genCoef <- function(R, ExMkt) {
  fit <- lm(R ~ ExMkt)
  data.table(t(coef(fit)), avgret = mean(R))
}

# plan(multiprocess(workers = 4))

source("src/R/make_combined_data.R")

stock_returns <- fread("data/stock_returns.csv")

replaceZeros(
  stock_returns
)

factor_returns <- fread("data/FF_Monthly.csv") %>%
  .[,Date := eomonth(as.Date(paste0(V1, "25"),
                             format = "%Y%m%d"))] %>%
  .[,.(Date, ExMkt = `Mkt-RF`, SMB, HML, RF)] %>%
  .[, c("ExMkt", "SMB", "HML", "RF") := lapply(.SD, function(x) x/100),
    .SDcols = c("ExMkt", "SMB", "HML", "RF")]

port_returns <- fread('data/monthly_merged.csv') %>%
  melt(1, variable.name = "Portfolio", value.name = "Return",
       variable.factor = F) %>%
  .[,Date := eomonth(as.Date(Date, format = "%m/%d/%Y"))] %>%
  .[,Return := Return/100] %>%
  .[,Sort := str_extract(Portfolio, ".*(?=_[0-9]+)") %>%
      str_replace_all("_", " ") %>%
      str_to_title] %>%
  .[,PortfolioNumber := as.integer(str_extract(Portfolio, "[0-9]$"))] %>%
  setorder(Date)

# equal weighted market is just the average stock return
ew_market <- as.vector(rowMeans(stock_returns, na.rm = T))

# need to normalize to decimals to match factor returns
# work in excess return
factor_returns[,EWMkt := ew_market/100 - RF]

getGR <- function(ExMkt, EWMkt) {
  fit <- lm(ExMkt ~ EWMkt)
  coef(fit)[1] + resid(fit)
}

# proxy for GR is just the regular market minus the equal weighted market
factor_returns[,GR := getGR(ExMkt, EWMkt)]

# combine factors with portfolios
combined_data <- merge(factor_returns, port_returns, by = "Date")
combined_data <- combined_data[Date > as.Date("1963-01-01")]
combined_data[,Return := Return - RF]

# run FM with HML and No Granular Residuals
# across all portfolios
ts_reg <- combined_data[!is.na(Return),
                        genCoef(Return, cbind(EWMkt, HML)),
                        by = Portfolio]
setnames(ts_reg, colnames(ts_reg), stringr::str_replace(colnames(ts_reg), fixed("cbind(1, ExMkt)"), ""))

ts_reg[,3 := NULL]

# or annualized version
# ts_reg <- combined_data[, genCoef(avgret*1200, ExMkt = cbind(EWMkt, HML))]

# run FM with HML and Granular Residuals
# across all portfolios
ts_reg_with_gr <- combined_data[!is.na(Return),
                        genCoef(Return, cbind(ExMkt, GR, HML)),
                        by = Portfolio]
# annualized version
# ts_reg_with_gr <- combined_data[, genCoef(avgret*1200,
#                                            ExMkt = cbind(ExMkt, GR, HML))]


library(ggplot2)
merge(ts_reg, ts_reg_with_gr,
      by = "Portfolio", suffixes = c("_noGR", "_withGR")) %>%
  .[,.(Sort = Portfolio, ExMkt_noGR, ExMkt_withGR)] %>%
  melt(1) %>%
  ggplot(aes(x = Sort, y = value, fill = variable)) +
  geom_col(position = "dodge", color = "black") +
  coord_flip() +
  theme_mit() +
  scale_fill_mit()

