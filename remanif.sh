

rm -R metadata/md5-cache
rm */*/Manifest
pkgdev manifest -f
ls */*/Manifest
ls metadata/md5-cache/*
pkgcheck scan

