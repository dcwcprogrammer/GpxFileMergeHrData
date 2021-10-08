# GpxFileMergeHrData

## Description

Merges heart rate data contained in a tcx file into a gpx file. Utility assumes there is signigicant overlap in timestamps and the two files are adhere to their respetive standars.

## Mac Setup

```brew install gawk```

## Instructions

```./merge_hr_data.sh \
    heart_rate_data_example.tcx \ # tcx file with heart rate values correpsondning to time stamps
    merged_hr_gps_data.gpx \ # gpx file with at mininimum timestamps
    > road_bike_activity_example.gpx # new gpx file enriched with hr data
```
