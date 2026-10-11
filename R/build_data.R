# Build tidy long-format data for the Freeze-Thaw Conditions indicator.
#
#   Rscript R/build_data.R
#
# Reads EPA's published figure CSVs in data-raw/ and writes data/*.csv plus
# data/meta.yml. Rerunning with unchanged inputs produces byte-identical output.
# Nothing here touches the network.
#
# Generated as a stub by the build-indicator skill. Each figure below has a
# `todo_reshape()` call standing where its reshape belongs. Replace that line,
# then delete the todo_reshape() helper once no call to it remains.
#
# TO UPDATE THE DATA: drop replacement CSVs into data-raw/ and rerun. Headers
# are asserted, not assumed, so a renamed or reordered column stops the build.

suppressPackageStartupMessages({
  library(dplyr)
})

root <- here::here()
source(file.path(root, "R/utils/epa_csv.R"))
source(file.path(root, "R/utils/write_stable.R"))

raw_dir <- file.path(root, "data-raw")
out_dir <- file.path(root, "data")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# ---- Indicator constants -----------------------------------------------------

INDICATOR <- list(
  name                    = "Freeze-Thaw Conditions",
  slug                    = "freeze-thaw-conditions",
  publisher               = "U.S. Environmental Protection Agency",
  source_page             = "https://19january2025snapshot.epa.gov/climate-indicators/climate-change-indicators-freeze-thaw-conditions/index.html",
  technical_documentation = "https://19january2025snapshot.epa.gov/system/files/documents/2025-01/freeze-thaw-conditions_td.pdf",
  rights                  = "Public domain, work of the U.S. Government (17 U.S.C. 105)"
)

# ---- Figure 1: Number of Unfrozen Days in the Contiguous 48 States, 1979–2023 ----

f1_path <- file.path(raw_dir, "freeze-thaw_fig-1.csv")
f1_meta <- read_epa_preamble(f1_path)
f1_raw  <- read_epa_csv(f1_path)

# All columns are listed as expected headers so a rename or reorder stops the
# build from the first run. When you write the reshape, move the identifier
# columns into id_cols so the split between keys and series is explicit.
assert_headers(
  f1_raw,
  id_cols          = character(),
  expected_headers = c("Year", "Deviation from long-term average"),
  what             = "freeze-thaw_fig-1.csv"
)

f1 <- f1_raw |>
  dplyr::transmute(
    year  = Year,
    value = `Deviation from long-term average`
  )

write_csv_stable(f1, file.path(out_dir, "unfrozen_days_contiguous_us.csv"))

# ---- Figure 2: Number of Unfrozen Days in Alaska, 1979–2023 ----

f2_path <- file.path(raw_dir, "freeze-thaw_fig-2.csv")
f2_meta <- read_epa_preamble(f2_path)
f2_raw  <- read_epa_csv(f2_path)

# All columns are listed as expected headers so a rename or reorder stops the
# build from the first run. When you write the reshape, move the identifier
# columns into id_cols so the split between keys and series is explicit.
assert_headers(
  f2_raw,
  id_cols          = character(),
  expected_headers = c("Year", "Deviation from long-term average"),
  what             = "freeze-thaw_fig-2.csv"
)

f2 <- f2_raw |>
  dplyr::transmute(
    year  = Year,
    value = `Deviation from long-term average`
  )

write_csv_stable(f2, file.path(out_dir, "unfrozen_days_alaska.csv"))

# ---- Data dictionary ---------------------------------------------------------

col <- function(name, type, description) {
  list(name = name, type = type, description = description)
}

meta <- list(
  indicator = INDICATOR,
  datasets = list(
    list(
      file            = "unfrozen_days_contiguous_us.csv",
      figure          = "Figure 1",
      figure_title    = f1_meta$title,
      source_file     = "freeze-thaw_fig-1.csv",
      source_sha256   = file_sha256(f1_path),
      source_encoding = "UTF-8-BOM",
      data_source     = f1_meta$data_source,
      web_update      = f1_meta$web_update,
      unit            = f1_meta$units,
      rows            = nrow(f1),
      columns         = list(
        col("year", "integer", "Calendar year, 1979-2023."),
        col("value", "number", "Deviation of the number of unfrozen days in the contiguous 48 states from the 1979-2023 average, in days.")
      )
    ),
    list(
      file            = "unfrozen_days_alaska.csv",
      figure          = "Figure 2",
      figure_title    = f2_meta$title,
      source_file     = "freeze-thaw_fig-2.csv",
      source_sha256   = file_sha256(f2_path),
      source_encoding = "UTF-8-BOM",
      data_source     = f2_meta$data_source,
      web_update      = f2_meta$web_update,
      unit            = f2_meta$units,
      rows            = nrow(f2),
      columns         = list(
        col("year", "integer", "Calendar year, 1979-2023."),
        col("value", "number", "Deviation of the number of unfrozen days in Alaska from the 1979-2023 average, in days.")
      )
    )
  )
)

write_yaml_stable(meta, file.path(out_dir, "meta.yml"))

# ---- Verify what was written -------------------------------------------------

written <- list.files(out_dir, pattern = "[.](csv|yml)$", full.names = TRUE)
invisible(lapply(written, assert_clean_output))

cat("\nWrote:\n")
for (p in written) {
  cat(sprintf("  %-34s %8d bytes  %s\n", basename(p), file.size(p), substr(file_sha256(p), 1, 12)))
}
