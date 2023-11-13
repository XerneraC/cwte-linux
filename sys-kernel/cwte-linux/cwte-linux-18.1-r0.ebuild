EAPI=8

inherit toolchain-funcs

cwte_srcver=3.8.2
cwte_kern_variant=cwte

pkgbase=linux-cwte-515-starfive-visionfive2


#cwte_rev=2
#cwte_cwtrel=18
#cwte_cwtrev=1

#             /------- cwte_cwtrel
#             | /----- cwte_cwterev
#             | |  /-- cwte_rev
#cwte-kernel-18.1-r2
#            \+-/  |-- This is the local versioning. It is my tool to deviate from cwt
#             |    \-- As in the version of this ebuild file
#             |
#             |------- These 2 values define the ctw version this ebuild is based on
#             \------- As in 18.1 => cwt18 ${cwte_srcver}-1

#cwte_rev="$(echo ${PR} | sed -n -E 's/r([0-9]+)/\1/p')"
#cwte_cwtrel="$(echo ${PV} | sed -n -E 's/([0-9]+)\.[0-9]+/\1/p')"
#cwte_cwtrev="$(echo ${PV} | sed -n -E 's/[0-9]+\.([0-9]+)/\1/p')"

#cwte_rev="$(echo ${PR} | sed -n -E 's/r([0-9]+)/\1/p')"

# cwte_cwt_tagname = cwt${cwte_cwtrel}-${cwte_srcver}-${cwte_cwterev}
# where:
# ${PV} = ${cwte_cwtrel}.${cwte_cwterev}
cwte_cwt_tagname="$(echo $PV | (IFS='.' read -r cwte_cwtrel cwte_cwtrev; echo "cwt${cwte_cwtrel}-${cwte_srcver}-${cwte_cwtrev}"))"

DESCRIPTION="Linux 5.15.x (-cwte) for StarFive RISC-V VisionFive 2 Board"
HOMEPAGE="
	https://github.com/starfive-tech/linux
	https://github.com/cwt-vf2/aur-linux-cwt-starfive-vf2
	https://forum.rvspace.org/t/arch-linux-image-for-visionfive-2
"
# https://github.com/cwt-vf2/aur-linux-cwt-starfive-vf2/archive/refs/tags/cwt${cwte_cwtrel}-${cwte_srcver}-${cwte_cwtrev}.tar.gz -> cwt_pkg.tar.gz
SRC_URI="
	https://github.com/cwt-vf2/aur-linux-cwt-starfive-vf2/archive/refs/tags/${cwte_cwt_tagname}.tar.gz -> cwt_pkg.tar.gz
	https://github.com/starfive-tech/linux/archive/refs/tags/VF2_v${cwte_srcver}.tar.gz -> kern_pkg.tar.gz
	https://github.com/starfive-tech/soft_3rdpart/archive/refs/tags/VF2_v${cwte_srcver}.tar.gz -> 3rdpart_pkg.tar.gz
"

LICENSE="GPL-2 BSD-Chips-and-Media"
SLOT="0"
KEYWORDS="-* ~riscv"
IUSE=""
RESTRICT="mirror"


# PN="<name of package>"
# P="${PN}-<package version>"
# therefore the name of the file is "${P}.ebuild"
#S="${WORKDIR}/${PN}-${P}"

#DEPEND=""
#RDEPEND="${DEPEND}"
BDEPEND="
	sys-devel/bc
	dev-util/pahole
	dev-lang/perl
	app-arch/tar
"

S="${WORKDIR}"

cwte_srcdir_cwt="${S}/aur-linux-cwt-starfive-vf2-${cwte_cwt_tagname}"
cwte_srcdir_kern="${S}/linux-VF2_v${cwte_srcver}"
cwte_srcdir_3rdpart="${S}/soft_3rdpart-VF2_v${cwte_srcver}"

cwte_dir_tmpfiles="${T}"

cwte_cc="$(tc-getCC)"

make_com=(KCFLAGS="-fno-asynchronous-unwind-tables -fno-unwind-tables" CC="$cwte_cc" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}")
case $cwte_cc in
	clang*)
		# TODO: Check whether the LLVM_IAS option is actually necessary
		make_com+=("LLVM=1" "LLVM_IAS=1");;
	*)
		;;
esac



cwte_prepare_kern() {
	cd $cwte_srcdir_kern

	local src
	for src in $(ls $cwte_srcdir_cwt/linux-*.patch); do
		echo "Applying patch $src to kernel..."
		#patch -Np1 < "$src" || die "Failed kernel patch $src"
		patch -Np1 < "$src"
	done

	echo "Setting version..."
	scripts/setlocalversion --save-scmversion
	#echo "-${cwte_kern_variant}" > localversion.10-variant
	#echo "-${cwte_srcver}"       > localversion.20-pkgver
	#echo "-$cwte_rev"            > localversion.30-pkgrel
	echo "-${cwte_kern_variant}" > localversion.10-variant
	echo "-${cwte_srcver}"       > localversion.20-srcver
	echo "-${PVR}"               > localversion.30-pkgver

	echo "Setting config..."
	cp $cwte_srcdir_cwt/config .config
	emake "${make_com[@]}" olddefconfig  || die "Failed loading old config $src"
	cp .config $cwte_dir_tmpfiles/config

	emake "${make_com[@]}" -s kernelrelease > $cwte_dir_tmpfiles/version
	echo "Prepared kernel version $(<$cwte_dir_tmpfiles/version)"
}


cwte_prepare_3rdpart() {
	cd $cwte_srcdir_3rdpart

	local src
	for src in $(ls $cwte_srcdir_cwt/soft_3rdpart-*.patch); do
		echo "Applying patch $src to 3rdpart..."
		patch -Np1 < "$src" || die "Failed 3rdpart patch $src"
	done
}


cwte_compile() {
	cd $cwte_srcdir_kern
	emake "${make_com[@]}" all  || die "Failed kernel compile"

	# JPU
	cd $cwte_srcdir_3rdpart/codaj12/jdi/linux/driver
	emake "${make_com[@]}" KERNELDIR=$cwte_srcdir_kern || die "Failed 3rdpart compile (JPU)"

	# VENC
	cd $cwte_srcdir_3rdpart/wave420l/code/vdi/linux/driver
	emake "${make_com[@]}" KERNELDIR=$cwte_srcdir_kern || die "Failed 3rdpart compile (VENC)"

	# VDEC
	cd $cwte_srcdir_3rdpart/wave511/code/vdi/linux/driver
	emake "${make_com[@]}" KERNELDIR=$cwte_srcdir_kern || die "Failed 3rdpart compile (VDEC)"
}



cwte_install_kern() {
	cd $cwte_srcdir_kern
	local kernver="$(<$cwte_dir_tmpfiles/version)"
	local modulesdir="${D}/lib/modules/$kernver"

	echo "Installing boot image..."
	install -Dm644 "arch/riscv/boot/Image.gz" "$modulesdir/vmlinuz"
	install -Dm644 "arch/riscv/boot/Image.gz" "${D}/boot/vmlinuz"

	echo "Installing modules..."
	emake "${make_com[@]}" INSTALL_MOD_PATH="${D}" INSTALL_MOD_STRIP=1 modules_install || die "Failed make install modules"

	echo "Installing dtbs..."
	emake "${make_com[@]}" INSTALL_DTBS_PATH="${D}/usr/share/dtbs/$kernver" dtbs_install || die "Failed make install dtbs (1)"
	emake "${make_com[@]}" INSTALL_DTBS_PATH="${D}/boot/dtbs/"              dtbs_install || die "Failed make install dtbs (2)"

	# remove build links
	rm "$modulesdir"/build

	install -Dm644 $cwte_srcdir_cwt/linux.preset  "${D}/etc/mkinitcpio.d/linux.preset"
	install -Dm644 $cwte_srcdir_cwt/90-linux.hook "${D}/usr/share/libalpm/hooks/90-linux.hook"
}



cwte_install_3rdpart() {
	echo "Installing Soft 3rd Part..."

	local kernver="$(<$cwte_dir_tmpfiles/version)"
	local modulesdir="${D}/lib/modules/$kernver"
	local _mod_extra="$modulesdir/extra"

	#JPU
	cd $cwte_srcdir_3rdpart/codaj12/jdi/linux/driver
	install -Dm644 jpu.ko "$_mod_extra/jpu.ko"
	$cwte_srcdir_kern/scripts/sign-file sha1 \
		$cwte_srcdir_kern/certs/signing_key.pem \
		$cwte_srcdir_kern/certs/signing_key.x509 \
		$_mod_extra/jpu.ko || die "Failed sign-script (JPU)"
	xz --lzma2=dict=2MiB -f $_mod_extra/jpu.ko

	# VENC
	cd $cwte_srcdir_3rdpart/wave420l/code/vdi/linux/driver
	install -Dm644 venc.ko "$_mod_extra/venc.ko"
	$cwte_srcdir_kern/scripts/sign-file sha1 \
		$cwte_srcdir_kern/certs/signing_key.pem \
		$cwte_srcdir_kern/certs/signing_key.x509 \
		$_mod_extra/venc.ko || die "Failed sign-script (VENC)"
	xz --lzma2=dict=2MiB -f $_mod_extra/venc.ko
	install -Dm644 $cwte_srcdir_3rdpart/wave420l/firmware/monet.bin             "${D}/lib/firmware/monet.bin"
	install -Dm644 $cwte_srcdir_3rdpart/wave420l/code/cfg/encoder_defconfig.cfg "${D}/lib/firmware/encoder_defconfig.cfg"

	# VDEC
	cd $cwte_srcdir_3rdpart/wave511/code/vdi/linux/driver
	install -Dm644 vdec.ko "$_mod_extra/vdec.ko"
	$cwte_srcdir_kern/scripts/sign-file sha1 \
		$cwte_srcdir_kern/certs/signing_key.pem \
		$cwte_srcdir_kern/certs/signing_key.x509 \
		$_mod_extra/vdec.ko || die "Failed sign-script (VDEC)"
	xz --lzma2=dict=2MiB -f $_mod_extra/vdec.ko
	install -Dm644 $cwte_srcdir_3rdpart/wave511/firmware/chagall.bin "${D}/lib/firmware/chagall.bin"

	# HiFi4
	cd $cwte_srcdir_3rdpart/HiFi4
	install -Dm644 sof-vf2.ri                "${D}/lib/firmware/sof/sof-vf2.ri"
	install -Dm644 sof-vf2-wm8960-aec.tplg   "${D}/lib/firmware/sof/sof-vf2-wm8960-aec.tplg"
	install -Dm644 sof-vf2-wm8960-mixer.tplg "${D}/lib/firmware/sof/sof-vf2-wm8960-mixer.tplg"
	install -Dm644 sof-vf2-wm8960.tplg       "${D}/lib/firmware/sof/sof-vf2-wm8960.tplg"


	install -Dm644 $cwte_srcdir_cwt/soft_3rdpart-modules.conf "${D}/etc/modprobe.d/soft_3rdpart-modules.conf"
	install -Dm644 $cwte_srcdir_cwt/91-soft_3rdpart.hook      "${D}/usr/share/libalpm/hooks/91-soft_3rdpart.hook"
	install -Dm644 $cwte_srcdir_cwt/91-soft_3rdpart.rules     "${D}/etc/udev/rules.d/91-soft_3rdpart.rules"
}








cwte_install_headers() {
	cd $cwte_srcdir_kern

	local builddir="${D}/lib/modules/$(<$cwte_dir_tmpfiles/version)/build"

	echo "Installing build files..."
	install -Dt "$builddir"            -m644 .config Makefile Module.symvers System.map version
	install -Dt "$builddir/kernel"     -m644 kernel/Makefile
	install -Dt "$builddir/arch/riscv" -m644 arch/riscv/Makefile
	cp -t "$builddir" -a scripts

	# required when DEBUG_INFO_BTF_MODULES is enabled
	cp --parents -r -t "$builddir/" tools/bpf/resolve_btfids

	echo "Installing VDSO files..."
	cp -a --parents -r -t "$builddir" arch/riscv/kernel/vdso/*
	cp -a --parents -r -t "$builddir" lib/vdso/*
	chmod -R g+w "$builddir/arch/riscv/kernel/vdso"

	echo "Installing certificate files..."
	install -Dt "$builddir/certs" -m640 certs/*.pem
	install -Dt "$builddir/certs" -m640 certs/*.x509

	echo "Installing headers..."
	cp -t        "$builddir" -a include
	chmod -R g+w "$builddir/include/generated"
	cp -t        "$builddir/arch/riscv" -a arch/riscv/include
	install -Dt  "$builddir/arch/riscv/kernel" -m644 arch/riscv/kernel/asm-offsets.s

	install -Dt "$builddir/drivers/md"   -m644 drivers/md/*.h
	install -Dt "$builddir/net/mac80211" -m644 net/mac80211/*.h

	# https://bugs.archlinux.org/task/13146
	install -Dt "$builddir/drivers/media/i2c" -m644 drivers/media/i2c/msp3400-driver.h

	# https://bugs.archlinux.org/task/20402
	install -Dt "$builddir/drivers/media/usb/dvb-usb"   -m644 drivers/media/usb/dvb-usb/*.h
	install -Dt "$builddir/drivers/media/dvb-frontends" -m644 drivers/media/dvb-frontends/*.h
	install -Dt "$builddir/drivers/media/tuners"        -m644 drivers/media/tuners/*.h

	# https://bugs.archlinux.org/task/71392
	install -Dt "$builddir/drivers/iio/common/hid-sensors" -m644 drivers/iio/common/hid-sensors/*.h

	echo "Installing KConfig files..."
	find . -name 'Kconfig*' -exec install -Dm644 {} "$builddir/{}" \;

	echo "Removing unneeded architectures..."
	local arch
	for arch in "$builddir"/arch/*/; do
		[[ $arch = */riscv/ ]] && continue
		echo "Removing $(basename "$arch")"
		rm -r "$arch"
	done

	echo "Removing documentation..."
	rm -r "$builddir/Documentation"

	echo "Removing broken symlinks..."
	find -L "$builddir" -type l -printf 'Removing %P\n' -delete

	echo "Removing loose objects..."
	find "$builddir" -type f -name '*.o' -printf 'Removing %P\n' -delete


	# commented out, as I do not know how to do the striphow to do the stripping compiler independantt are
	#echo "Stripping build tools..."
	#local file
	#while read -rd '' file; do
	#	case "$(file -bi "$file")" in
	#	application/x-sharedlib\;*) # Libraries (.so)
	#		llvm-strip -v $STRIP_SHARED "$file" ;;
	#	application/x-archive\;*) # Libraries (.a)
	#		llvm-strip -v $STRIP_STATIC "$file" ;;
	#	application/x-executable\;*) # Binaries
	#		llvm-strip -v $STRIP_BINARIES "$file" ;;
	#	application/x-pie-executable\;*) # Relocatable binaries
	#		llvm-strip -v $STRIP_SHARED "$file" ;;
	#	esac
	#done < <(find "$builddir" -type f -perm -u+x ! -name vmlinux -print0)

	echo "Adding symlink..."
	mkdir -p "${D}/usr/src"
	ln -sr "$builddir" "${D}/usr/src/$pkgbase"
}






src_prepare() {
	cwte_prepare_kern
	cwte_prepare_3rdpart

	eapply_user
}

src_compile() {
	cwte_compile
}

src_install() {
	cwte_install_kern
	cwte_install_3rdpart
	cwte_install_headers

	# how to error:
	# `<command> || die "<error>"`

	# DESTDIR=${D}
}



