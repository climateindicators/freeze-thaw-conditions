# Provenance

Every file in this directory is reproduced unmodified from EPA's published
indicator page and its per-figure data downloads. To update the data, replace the
file and rerun `Rscript R/build_data.R`.

## Indicator page

- `source-page.html`  \
  <https://19january2025snapshot.epa.gov/climate-indicators/climate-change-indicators-freeze-thaw-conditions/index.html>  \
  sha256 `44908bc177d7ccad71f75e2a036be44629a820bf87a1e7ad9a1a7fb41c4743fe`

Technical documentation: <https://19january2025snapshot.epa.gov/system/files/documents/2025-01/freeze-thaw-conditions_td.pdf>

## Figure data

- `freeze-thaw_fig-1.csv`  \
  <https://19january2025snapshot.epa.gov/system/files/other-files/2023-09/freeze-thaw_fig-1.csv>  \
  sha256 `6e998ed1a24e9cdc4075bbfb89b998aae7bb466fdb90f5e562f9cc713120c39d`  \
  encoding UTF-8-BOM, 45 data rows, columns: `Year`, `Deviation from long-term average`  \
  title: Figure 1. Number of Unfrozen Days in the Contiguous 48 States, 1979–2023  \
  data source: Kim and Kimball, 2024; web update: January 2025; units: days

- `freeze-thaw_fig-2.csv`  \
  <https://19january2025snapshot.epa.gov/system/files/other-files/2023-09/freeze-thaw_fig-2.csv>  \
  sha256 `c8647626ca9ec7f2fa61be4176aa7d411251509b603331bac3e91db460148559`  \
  encoding UTF-8-BOM, 45 data rows, columns: `Year`, `Deviation from long-term average`  \
  title: Figure 2. Number of Unfrozen Days in Alaska, 1979–2023  \
  data source: Kim and Kimball, 2024; web update: January 2025; units: days

- **Figure 3** has no data download on EPA's page. The narrative carries the caption; there is nothing to build.
