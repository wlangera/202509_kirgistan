if (!requireNamespace("magick", quietly = TRUE)) {
  install.packages("magick")
}
if (!requireNamespace("exifr", quietly = TRUE)) {
  install.packages("exifr")
}

library(magick)
library(exifr)

# --- User settings ---
input_dir  <- "google_fotos"
output_dir <- "google_fotos_ordered"

# --- Create output directory ---
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

# --- Step 1: List files and read EXIF ---
files <- list.files(input_dir, full.names = TRUE)
if (length(files) == 0) stop("No files found in ", input_dir)

info <- read_exif(files)

# --- Choose best available datetime ---
info$datetime <- info$CreateDate
info$datetime[is.na(info$datetime)] <- info$DateTimeOriginal[is.na(info$datetime)]

# fallback to file modification time if EXIF missing
missing_dt <- is.na(info$datetime)
if (any(missing_dt)) {
  info$datetime[missing_dt] <- file.info(info$SourceFile[missing_dt])$mtime
}

# ensure POSIXct
info$datetime <- as.POSIXct(
  info$datetime,
  format = "%Y:%m:%d %H:%M:%S",
  tz = "UTC"
)

# --- Order chronologically ---
info <- info[order(info$datetime), ]

# --- Step 2: Copy & rename with timestamp ---
for (i in seq_len(nrow(info))) {

  ts <- format(info$datetime[i], "%Y%m%d_%H%M%S")
  ext <- tolower(tools::file_ext(info$SourceFile[i]))

  new_name <- sprintf("%s_%04d.%s", ts, i, ext)
  new_path <- file.path(output_dir, new_name)

  file.copy(info$SourceFile[i], new_path, overwrite = TRUE)
}

message("✅ Files copied and renamed with sortable timestamps.")

# --- Step 3: Convert HEIC -> JPEG ---
heic_files <- list.files(
  output_dir,
  pattern = "\\.heic$",
  ignore.case = TRUE,
  full.names = TRUE
)

for (f in heic_files) {
  message("Converting HEIC to JPEG: ", basename(f))
  img <- image_read(f)
  out_file <- sub("\\.[Hh][Ee][Ii][Cc]$", ".jpg", f)
  image_write(img, path = out_file, format = "jpeg")
  file.remove(f)
}

message("✅ All HEIC files converted to JPEG.")
message("📂 Final ordered files in: ", output_dir)
