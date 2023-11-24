

rm -R metadata/md5-cache
rm */*/Manifest
pkgdev manifest
ebuilds=$(ls */*/*.ebuild)
for curr_ebuild in $ebuilds; do
	ebuild $curr_ebuild manifest
done
ls */*/*
pkgcheck scan

