
git pull
rm -R metadata/md5-cache
rm sys-kernel/cwte-linux/Manifest
pkgdev manifest
pkgcheck scan
read
git add .
git commit -m "Update Manifest"
git push
