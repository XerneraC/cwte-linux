EAPI=8


vf2_sw_ver=3.8.2

DESCRIPTION="This is the GLES and Vulkan implementation provided by StarFive for the IMG_GPU"
HOMEPAGE="
	https://github.com/starfive-tech/soft_3rdpart/tree/JH7110_VisionFive2_devel
	https://github.com/cwt-vf2/img-gpu-vf2
"
SRC_URI="https://github.com/starfive-tech/soft_3rdpart/raw/VF2_v${vf2_sw_ver}/IMG_GPU/out/img-gpu-powervr-bin-${PV}.tar.gz"


# relevant use flags:
# - opengl
# - vulkan
# - opencl



LICENSE=""
SLOT="0"
KEYWORDS="-* ~riscv"
IUSE=""
RESTRICT="mirror strip"

#DEPEND=""
#RDEPEND="${DEPEND}"
#BDEPEND="
#	sys-devel/bc
#	dev-util/pahole
#	dev-lang/perl
#	app-arch/tar
#"

S="${WORKDIR}/img-gpu-powervr-bin-${PV}"

src_install() {
	cd "${S}/target"

	# Config files
	install -Dm755 etc/init.d/rc.pvr             "${D}/etc/init.d/rc.pvr"
	install -Dm644 etc/OpenCL/vendors/IMG.icd    "${D}/etc/OpenCL/vendors/IMG.icd"
	install -Dm644 etc/vulkan/icd.d/icdconf.json "${D}/etc/vulkan/icd.d/icdconf.json"

	# Library files with version
	install -Dm755 usr/lib/libglslcompiler.so.${PV}       "${D}/lib/libglslcompiler.so.${PV}"
	install -Dm755 usr/lib/libpvr_dri_support.so.${PV}    "${D}/lib/libpvr_dri_support.so.${PV}"
	install -Dm755 usr/lib/libsrv_um.so.${PV}             "${D}/lib/libsrv_um.so.${PV}"
	install -Dm755 usr/lib/libsutu_display.so.${PV}       "${D}/lib/libsutu_display.so.${PV}"
	install -Dm755 usr/lib/libGLESv1_CM_PVR_MESA.so.${PV} "${D}/lib/libGLESv1_CM_PVR_MESA.so.${PV}"
	install -Dm755 usr/lib/libPVROCL.so.${PV}             "${D}/lib/libPVROCL.so.${PV}"
	install -Dm755 usr/lib/libPVRScopeServices.so.${PV}   "${D}/lib/libPVRScopeServices.so.${PV}"
	install -Dm755 usr/lib/libufwriter.so.${PV}           "${D}/lib/libufwriter.so.${PV}"
	install -Dm755 usr/lib/libusc.so.${PV}                "${D}/lib/libusc.so.${PV}"
	install -Dm755 usr/lib/libVK_IMG.so.${PV}             "${D}/lib/libVK_IMG.so.${PV}"
	install -Dm755 usr/lib/libGLESv2_PVR_MESA.so.${PV}    "${D}/lib/libGLESv2_PVR_MESA.so.${PV}"

	# Executables
	install -Dm755 usr/local/bin/rgx_triangle_test      "${D}/usr/bin/rgx_triangle_test"
	install -Dm755 usr/local/bin/pvrhtbd                "${D}/usr/bin/pvrhtbd"
	install -Dm755 usr/local/bin/rogue2d_unittest       "${D}/usr/bin/rogue2d_unittest"
	install -Dm755 usr/local/bin/pvrsrvctl              "${D}/usr/bin/pvrsrvctl"
	install -Dm755 usr/local/bin/rgx_compute_test       "${D}/usr/bin/rgx_compute_test"
	install -Dm755 usr/local/bin/pvr_memory_test        "${D}/usr/bin/pvr_memory_test"
	install -Dm755 usr/local/bin/ocl_unit_test          "${D}/usr/bin/ocl_unit_test"
	install -Dm755 usr/local/bin/pvrdebug               "${D}/usr/bin/pvrdebug"
	install -Dm755 usr/local/bin/hwperfbin2jsont        "${D}/usr/bin/hwperfbin2jsont"
	install -Dm755 usr/local/bin/pvrhtb2txt             "${D}/usr/bin/pvrhtb2txt"
	install -Dm755 usr/local/bin/pvr_mutex_perf_test_mx "${D}/usr/bin/pvr_mutex_perf_test_mx"
	install -Dm755 usr/local/bin/rogue2d_fbctest        "${D}/usr/bin/rogue2d_fbctest"
	install -Dm755 usr/local/bin/rgx_twiddling_test     "${D}/usr/bin/rgx_twiddling_test"
	install -Dm755 usr/local/bin/hwperfjsonmerge.py     "${D}/usr/bin/hwperfjsonmerge.py"
	install -Dm755 usr/local/bin/rgx_blit_test          "${D}/usr/bin/rgx_blit_test"
	install -Dm755 usr/local/bin/ocl_extended_test      "${D}/usr/bin/ocl_extended_test"
	install -Dm755 usr/local/bin/pvrtld                 "${D}/usr/bin/pvrtld"
	install -Dm755 usr/local/bin/pvrlogsplit            "${D}/usr/bin/pvrlogsplit"
	install -Dm755 usr/local/bin/pvrlogdump             "${D}/usr/bin/pvrlogdump"
	install -Dm755 usr/local/bin/pvrhwperf              "${D}/usr/bin/pvrhwperf"
	install -Dm755 usr/local/bin/tqplayer               "${D}/usr/bin/tqplayer"

	# Symbolic links
	cp --no-dereference usr/lib/libPVROCL.so             "${D}/lib/libPVROCL.so"
	cp --no-dereference usr/lib/libVK_IMG.so             "${D}/lib/libVK_IMG.so"
	cp --no-dereference usr/lib/libPVRScopeServices.so   "${D}/lib/libPVRScopeServices.so"
	cp --no-dereference usr/lib/libsutu_display.so       "${D}/lib/libsutu_display.so"
	cp --no-dereference usr/lib/libpvr_dri_support.so    "${D}/lib/libpvr_dri_support.so"
	cp --no-dereference usr/lib/libglslcompiler.so       "${D}/lib/libglslcompiler.so"
	cp --no-dereference usr/lib/libufwriter.so           "${D}/lib/libufwriter.so"
	cp --no-dereference usr/lib/libGLESv1_CM_PVR_MESA.so "${D}/lib/libGLESv1_CM_PVR_MESA.so"
	cp --no-dereference usr/lib/libGLESv2_PVR_MESA.so    "${D}/lib/libGLESv2_PVR_MESA.so"
	cp --no-dereference usr/lib/libsrv_um.so             "${D}/lib/libsrv_um.so"
	cp --no-dereference usr/lib/libPVROCL.so.1           "${D}/lib/libPVROCL.so.1"
	cp --no-dereference usr/lib/libGLESv1_CM.so.1        "${D}/lib/libGLESv1_CM.so.1"
	cp --no-dereference usr/lib/libGLESv1_CM.so          "${D}/lib/libGLESv1_CM.so"
	cp --no-dereference usr/lib/libVK_IMG.so.1           "${D}/lib/libVK_IMG.so.1"
	cp --no-dereference usr/lib/libusc.so                "${D}/lib/libusc.so"

	# Firmware files
	install -Dm644 lib/firmware/rgx.fw.36.50.54.182 "${D}/lib/firmware/rgx.fw.36.50.54.182"
	install -Dm644 lib/firmware/rgx.sh.36.50.54.182 "${D}/lib/firmware/rgx.sh.36.50.54.182"

	# dracut initramfs config
	install -Dm644 "${FILESDIR}/img-gpu-firmware-dracut.conf" "${D}/etc/dracut.conf.d/${PN}.conf"
}





