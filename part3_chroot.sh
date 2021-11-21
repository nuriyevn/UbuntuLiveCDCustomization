#!/bin/bash
EDIT="edit"
EXTRACT_CD="extract-cd"
squashmanifest="casper/filesystem.manifest"

TMP="/tmp.filesystem.manifest"

sudo dpkg-query -W --showformat='${Package} ${Version}\n' > "$TMP"
exit
