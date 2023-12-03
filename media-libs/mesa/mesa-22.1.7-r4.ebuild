EAPI=8

inherit meson


DESCRIPTION="A mesa port for the Visionfive 2"
HOMEPAGE="
	https://github.com/cwt-vf2/mesa-pvr-vf2
"
SRC_URI="
	https://mesa.freedesktop.org/archive/mesa-${PV}.tar.xz
	https://github.com/cwt-vf2/mesa-pvr-vf2/archive/refs/tags/v${PV}-${PR:1}.tar.gz
"

#https://mesa.freedesktop.org/archive/mesa-22.1.7.tar.xz

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~riscv"
IUSE="wayland X video_cards_nouveau video_cards_radeonsi video_cards_r300 video_cards_r600 video_cards_amdgpu video_cards_intel"
RESTRICT="mirror"
REQUIRED_USE="|| ( wayland X )"


#  dev-libs/libelf
DEPEND="
	x11-libs/libdrm
	x11-libs/libXxf86vm
	x11-libs/libXdamage
	x11-libs/libxshmfence
	sys-libs/libunwind
	app-arch/zstd
	dev-libs/expat
	media-libs/libglvnd
"

# TODO: verify these depends
# TODO: Add wayland dependencies
# TODO: make dependencies parametric on use flags
BDEPEND="
	${DEPEND}
	app-text/dos2unix
	dev-python/mako
	x11-base/xorg-proto
	dev-libs/libxml2
	x11-libs/libX11
	x11-libs/libvdpau
	media-libs/libva
	dev-libs/elfutils
	x11-libs/libXrandr
	dev-util/meson
	dev-util/ninja
	dev-util/glslang
"

S="${WORKDIR}"

mesa_dir="${S}/mesa-${PV}"
patch_dir="${S}/mesa-pvr-vf2-${PV}-${PR:1}"

EMESON_BUILDTYPE=release
EMESON_SOURCE=$mesa_dir


src_prepare() {
	local patch
	dos2unix $mesa_dir/src/mesa/main/formats.csv || die "Failed to convert formats.csv to unix line endings"
	for patch in $patch_dir/*.patch; do
		echo "Applying patch ${patch}..."
		patch --directory="$mesa_dir" --forward --strip=1 --input="${patch}" || die "Failed to apply patch ${patch}"
	done


	eapply_user

	mesa_platforms=
	use wayland && mesa_platforms+=,wayland
	use X       && mesa_platforms+=,x11

	mesa_gallium_drivers=swrast,pvr
	use video_cards_nouveau  && mesa_gallium_drivers+=,nouveau
	use video_cards_radeonsi && mesa_gallium_drivers+=,radeonsi
	use video_cards_r300     && mesa_gallium_drivers+=,r300
	use video_cards_r600     && mesa_gallium_drivers+=,r600

	mesa_vulkan_drivers=
	use video_cards_amdgpu && mesa_vulkan_drivers+=,amd
	use video_cards_intel  && mesa_vulkan_drivers+=,intel


	# TODO: Alot here should be read out of useflags
	local emesonargs=(
		-Dshared-glapi=enabled
		-Dglx-read-only-text=true
		-Dplatforms="${mesa_platforms:1}"
		-Dgles1=disabled
		-Dgles2=enabled
		-Ddri3=disabled
		-Degl=enabled
		-Dgallium-drivers=${mesa_gallium_drivers}
		-Dllvm=disabled
		-Dgbm=enabled
		-Dlmsensors=disabled
		-Dgallium-opencl=disabled
		-Dopencl-spirv=false
		-Dopengl=true
		-Dosmesa=false
		-Dperfetto=false
		-Dlibunwind=disabled
		-Dgallium-va=disabled
		-Dgallium-vdpau=disabled
		-Dvulkan-drivers="${mesa_vulkan_drivers:1}"
		-Dgallium-xa=disabled
		-Dgallium-xvmc=disabled
		-Dglvnd=true
		#-Dprefix=/usr
		#-Dsysconfdir=/etc
		#-Dbuildtype=release
	)

	meson_src_configure || die "Failed to meson configure"
}




src_install() {
	meson_src_install || die "Meson Install Failed"
	ln -s "${D}/usr/lib/libGLX_mesa.so.0" "${D}/usr/lib/libGLX_indirect.so.0" || die "Failed to link"
}
