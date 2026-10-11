# Regression checks on the generated data for the Freeze-Thaw Conditions indicator.
#
#   Rscript tests/test-data.R
#
# The checks below are shape-independent: they hold whatever the reshape in
# R/build_data.R turns each figure into. Value snapshots, which pin the actual
# numbers so a data update fails loudly instead of passing silently, are the
# TODO at the bottom.

setwd(here::here())
source("R/utils/write_stable.R")

# Keeps the dictionary check readable when a meta.yml field is absent altogether.
`%||%` <- function(a, b) if (is.null(a)) b else a

failures <- character()
check <- function(label, ok) {
  ok <- isTRUE(ok)
  cat(sprintf("  [%s] %s\n", if (ok) "PASS" else "FAIL", label))
  if (!ok) failures <<- c(failures, label)
  invisible(ok)
}

rd <- function(f) {
  readr::read_csv(file.path("data", f),
                  col_types = readr::cols(.default = readr::col_character()),
                  na = character(), progress = FALSE)
}

meta <- yaml::read_yaml("data/meta.yml")

cat("\nData dictionary\n")
check("meta.yml documents 2 dataset(s)", length(meta$datasets) == 2L)
check("meta.yml has no timestamp",
      !any(grepl("\\d{4}-\\d{2}-\\d{2}T|Sys\\.time|generated_at",
                 readLines("data/meta.yml", warn = FALSE))))

for (ds in meta$datasets) {
  df   <- rd(ds$file)
  cols <- vapply(ds$columns, function(x) x$name, character(1))
  check(sprintf("%s: meta.yml lists the columns the file actually has", ds$file),
        identical(cols, names(df)))
  check(sprintf("%s: meta.yml row count matches the file", ds$file),
        identical(as.integer(ds$rows), nrow(df)))
  check(sprintf("%s: every column has a type and a description", ds$file),
        all(vapply(ds$columns, function(x) nzchar(x$type %||% "") && nzchar(x$description %||% ""), logical(1))))
  check(sprintf("%s: source file is still present and unchanged", ds$file),
        identical(file_sha256(file.path("data-raw", ds$source_file)), ds$source_sha256))
  check(sprintf("%s: no blank rows", ds$file), nrow(df) > 0L)
}

cat("\nFile hygiene\n")
for (f in list.files("data", pattern = "[.](csv|yml)$", full.names = TRUE)) {
  check(sprintf("%s is UTF-8, LF, no BOM, no mojibake", basename(f)),
        tryCatch({ assert_clean_output(f); TRUE },
                 error = function(e) { cat("      ", conditionMessage(e), "\n"); FALSE }))
}

cat("\nValue snapshots\n")
# Pinned from EPA's January 2025 release. Values compare as strings so the
# source precision has to survive the build byte for byte.
snap <- function(f, n, first, last, min_row, max_row) {
  d <- rd(f)
  v <- as.numeric(d$value)
  check(sprintf("%s: %d rows", f, n), nrow(d) == n)
  check(sprintf("%s: years 1979-2023, one row each", f),
        identical(d$year, as.character(1979:2023)))
  check(sprintf("%s: first row %s", f, paste(first, collapse = " ")),
        identical(unname(unlist(d[1, ])), first))
  check(sprintf("%s: last row %s", f, paste(last, collapse = " ")),
        identical(unname(unlist(d[nrow(d), ])), last))
  check(sprintf("%s: minimum %s", f, paste(min_row, collapse = " ")),
        identical(unname(unlist(d[which.min(v), ])), min_row))
  check(sprintf("%s: maximum %s", f, paste(max_row, collapse = " ")),
        identical(unname(unlist(d[which.max(v), ])), max_row))
}

snap("unfrozen_days_contiguous_us.csv", 45L,
     first   = c("1979", "-5.422511111"),
     last    = c("2023", "17.32048889"),
     min_row = c("1980", "-13.25851111"),
     max_row = c("2023", "17.32048889"))

snap("unfrozen_days_alaska.csv", 45L,
     first   = c("1979", "8.680955556"),
     last    = c("2023", "7.749955556"),
     min_row = c("1992", "-26.45804444"),
     max_row = c("2016", "22.59995556"))

cat("\n")
if (length(failures)) {
  cat(sprintf("%d FAILED:\n", length(failures)))
  for (f in failures) cat("  -", f, "\n")
  quit(status = 1L)
}
cat("All data checks passed.\n")
