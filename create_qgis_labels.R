# Create dataframe for geographic location labels for QGIS
# Coordinates are in WGS84
# x = longitude, y = latitude

df <- data.frame(
  x = c(
    74.578807, 75.290020, 77.081958, 78.397066, 77.443731, 76.990450,
    75.842712, 75.785142, 78.214833, 77.647956,
    74.482163
  ),
  y = c(
    42.873104, 42.830498, 42.640296, 42.480410, 42.171232, 42.113510,
    42.723778, 42.595414, 42.426811, 41.955246,
    42.564171
  ),
  name = c(
    "Bishkek", "Tokmok", "Cholpon-Ata", "Karakol", "Tosor", "Bökönbaev",
    "Cholok", "Konorchek Canyon", "Jeti Oguz", "Seok Pass",
    "Ala Archa National Park"
  )
)

# Export dataframe to CSV for use in QGIS
write.csv(df, "./kaartjes/location_labels.csv", row.names = FALSE)
