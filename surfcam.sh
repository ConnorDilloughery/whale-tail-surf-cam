#!/bin/bash

TIMESTAMP=$(date '+%Y-%m-%d %H:%M %Z')
IMAGE=/tmp/surfcam.jpg
OVERLAY=/tmp/surfcam_overlay.jpg

rpicam-still -o $IMAGE --width 1920 --height 1080 -n --timeout 3000 --autofocus-mode manual --lens-position 0
convert $IMAGE \
  -gravity SouthWest \
  -fill white \
  -pointsize 36 \
  -annotate +20+20 "Whale Tail, CA  |  $TIMESTAMP" \
  $OVERLAY

aws s3 cp $OVERLAY s3://YOUR_BUCKET_NAME/whale-tail-cam.jpg \
  --content-type image/jpeg \
  --cache-control "no-cache, no-store, must-revalidate" \
  --metadata-directive REPLACE
