library(stringr)
library(data.table)
library(magrittr)
library(lubridate)

#' Function which finds the end date of a given month
#' @importFrom lubridate ceiling_date
#' @param date vector of class Date
eomonth <- function(date) {
  lubridate::ceiling_date(date, "month") - 1
}

# read in returns, construct date, rename cols, divide by 100
get_factor_returns <- function() {
  fread("data/FF_Monthly.csv") %>%
    .[,Date := eomonth(as.Date(paste0(V1, "25"),
                               format = "%Y%m%d"))] %>%
    .[,.(Date, ExMkt = `Mkt-RF`, SMB, HML, RF)] %>%
    .[, c("ExMkt", "SMB", "HML", "RF") := lapply(.SD, function(x) x/100),
      .SDcols = c("ExMkt", "SMB", "HML", "RF")] %>%
    .[]
}

# read in all ports, convert to dates
# rename some stuff, make tidy
get_portfolio_returns <- function() {

  fread('data/monthly_merged.csv') %>%
    melt(1, variable.name = "Portfolio", value.name = "Return",
         variable.factor = F) %>%
    .[,Date := eomonth(as.Date(Date, format = "%m/%d/%Y"))] %>%
    .[,Return := Return/100] %>%
    .[,Sort := str_extract(Portfolio, ".*(?=_[0-9]+)") %>%
        str_replace_all("_", " ") %>%
        str_to_title] %>%
    .[,PortfolioNumber := as.integer(str_extract(Portfolio, "[0-9]$"))] %>%
    .[]
}

