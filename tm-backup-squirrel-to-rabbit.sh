#!/bin/bash

set -e

TARGET_SRC="/Volumes/squirrel"
TARGET_DST="/Volumes/rabbit"

echo "=== Time Machine: Configure external-only backup ==="
echo "Source (to be backed up):   $TARGET_SRC"
echo "Destination (backup disk):  $TARGET_DST"
echo

if [ ! -d "$TARGET_SRC" ]; then
    echo "ERROR: Source disk '$TARGET_SRC' is not mounted."
    exit 1
fi

if [ ! -d "$TARGET_DST" ]; then
    echo "ERROR: Destination disk '$TARGET_DST' is not mounted."
    exit 1
fi

echo "Both source and destination volumes are mounted."
echo

echo "Clearing old exclusions (ignore errors)..."
sudo tmutil removeexclusion -p / || true

echo "Excluding internal system volumes..."
sudo tmutil addexclusion -p /

echo "Scanning all mounted volumes..."
for vol in /Volumes/*; do
    if [ "$vol" != "$TARGET_SRC" ]; then
        echo "Excluding: $vol"
        sudo tmutil addexclusion -p "$vol" || true
    fi
done

echo
echo "All volumes excluded except '$TARGET_SRC'."
echo

echo "Setting Time Machine destination to: $TARGET_DST"
sudo tmutil setdestination "$TARGET_DST"
echo

echo "Starting manual backup..."
sudo tmutil startbackup --block

echo
echo "Backup complete (or running)."
echo "Time Machine is now configured to back up ONLY:"
echo "    $TARGET_SRC -->  $TARGET_DST"
echo
echo "Done!"
