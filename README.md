# Kyrgyzstan 2025

Scripts and resources used to create a photo album and travel map for the **Kyrgyzstan 2025** trip.

This repository contains small, purpose-built R scripts and spatial layers to help with:

* Organising photos exported from Google Photos
* Creating a custom travel map from GPX tracks in QGIS

## 📸 Photos

Workflow for preparing the photo album.

1. **Download photos** from Google Photos (manual export)

2. **Order photos**

 ```r
 order_photos.R
 ```

 * Set the input directory (raw photos)
 * Set the output directory (ordered / renamed photos)

The script takes care of sorting photos chronologically so they’re ready for album creation.
It also converts `.HEIC` photos to `.jpeg`.


## 🗺️ Travel map

Workflow for generating a clean travel map with routes and labels.

1. **Create GPX files**
   Use [Open Map Maker](https://open-map-maker.vercel.app/) to draw travel routes and export them as GPX (save in `kaartjes` directory).

2. **Parse GPX tracks**

```r
parse_gpx_tracks.R
```

3. **Create map labels**

```r
create_qgis_labels.R
```

4. **Build the final map**

Open the QGIS project (in `kaartjes` directory):

```
kyrgyzstan_map.qgz
```

and style/export the final travel map.

## Requirements

* R (for the scripts)
* QGIS (for the final map layout)
* GPX files created beforehand
