# Load required packages
library(sf)
library(tidyverse)

# Folder containing the GPX files
kaartjes_dir <- "kaartjes"

# List all GPX files
gpx_files <- list.files(
  path = kaartjes_dir,
  pattern = "\\.gpx$",
  full.names = TRUE
)

# Helper function to read a GPX track and add placeholder columns
read_gpx_track <- function(file) {

  # Read GPX tracks layer
  track <- st_read(
    file,
    layer = "tracks",
    quiet = TRUE
  )

  # Extract order and name from filename
  filename <- basename(file)

  order_id <- str_extract(filename, "^\\d+") |> as.integer()
  name_id  <- filename |>
    str_remove("^\\d+_") |>
    str_remove("\\.gpx$")

  # Add required columns
  track |>
    mutate(
      order = order_id,
      name = name_id
    ) %>%
    select("order", "name", "geometry")
}

# Add empty-geometry rows for outbound and return flights
add_flight_rows <- function(
    x,
    outbound_date,
    outbound_label,
    return_date,
    return_label
) {

  # Shift existing order to make room
  x <- x |>
    mutate(order = order + 1)

  # Create empty geometry with same CRS
  empty_geom <- st_sfc(
    st_geometrycollection(),
    crs = st_crs(x)
  )

  # Template row (to keep column types consistent)
  template <- x[1, ]

  # Outbound flight row
  flight_out <- template |>
    mutate(
      order = 1,
      name = NA_character_,
      start_location = NA_character_,
      end_location = NA_character_,
      start_date = outbound_date,
      end_date = outbound_date,
      description = NA_character_,
      label = outbound_label,
      geometry = empty_geom
    )

  # Return flight row
  flight_back <- template |>
    mutate(
      order = max(x$order) + 1,
      name = NA_character_,
      start_location = NA_character_,
      end_location = NA_character_,
      start_date = return_date,
      end_date = return_date,
      description = NA_character_,
      label = return_label,
      geometry = empty_geom
    )

  # Combine and reorder
  bind_rows(
    flight_out,
    x,
    flight_back
  ) |>
    arrange(order)
}

# Read and combine all GPX tracks
tracks_sf <- gpx_files |>
  map(read_gpx_track) |>
  bind_rows() |>
  arrange(order) |>
  mutate(
    start_location = c("Bishkek", "Bishkek", "Cholpon-Ata", "Karakol",
                       "Karakol", "Tosor", "Bökönbaev"),
    end_location   = c("Bishkek", "Cholpon-Ata", "Karakol", "Karakol",
                       "Tosor", "Bökönbaev", "Bishkek"),
    start_date     = c("04-09-2025", "06-09-2025", "08-09-2025", "09-09-2025",
                       "13-09-2025", "14-09-2025", "15-09-2025"),
    end_date       = c("05-09-2025", "07-09-2025", "08-09-2025", "12-09-2025",
                       "13-09-2025", "14-09-2025", "16-09-2025"),
    description = c(
      "Bishkek en Ala Archa National Park",
      "Konorcheck Canyon en Cholpon-Ata",
      "doorreis Karakol",
      "Ala Kul hike",
      "Jeti-Ögüz en Seok Pass",
      "Skazka Canyon en yurtkampen Bökönbaev",
      "Bökönbaev daguitstap en terug naar Bishkek"
    )
  ) |>
  mutate(
    # Build date part of label
    label_dates = if_else(
      start_date == end_date,
      start_date,
      paste(start_date, end_date, sep = " – ")
    ),

    # Build location part of label
    label_location = if_else(
      start_location == end_location,
      description,
      paste(start_location, end_location, sep = " – ")
    ),

    # Final label
    label = paste(label_dates, label_location, sep = ": ")
  ) |>
  select(-label_dates, -label_location) |>
  select(everything(), "geometry")

# Add flights
tracks_sf <- tracks_sf |>
  add_flight_rows(
    outbound_date  = "03-09-2025",
    outbound_label = "03-09-2025: Vlucht Brussel - Istanbul - Bishkek",
    return_date    = "17-09-2025",
    return_label   = "17-09-2025: Vlucht Bishkek - Istanbul - Brussel"
  )

tracks_sf

# Visualisation
mapview::mapview(tracks_sf[2:8,], zcol = "label", layer = "Legende")

# Output GeoPackage path
output_gpkg <- file.path(kaartjes_dir, "kirgistan_route.gpkg")

# Write GeoPackage (overwrite if it exists)
st_write(
  tracks_sf,
  output_gpkg,
  delete_dsn = TRUE
)

# Confirmation message
message("GeoPackage written to: ", output_gpkg)
