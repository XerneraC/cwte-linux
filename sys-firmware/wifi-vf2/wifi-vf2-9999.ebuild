EAPI=8

inherit git-r3

DESCRIPTION="WiFi firmware for the with the VF2 included WiFi dongle"
HOMEPAGE="https://github.com/starfive-tech/buildroot"
EGIT_REPO_URI="https://github.com/starfive-tech/buildroot.git"
EGIT_BRANCH="JH7110_VisionFive2_devel"


LICENSE="GPL-2"
SLOT="0"
RESTRICT="mirror"

wifi_fw_path="${S}/package/starfive/usb_wifi"

infomsg="Even though we pulled an enitre buildroot repo, we only require a small part of it. As the default functions want to compile that buildroot, i need to override them"

src_prepare() {
	eapply_user
	echo $infomsg
}

src_configure() {
	echo $infomsg
}
src_compile() {
	echo $infomsg
}

src_install() {
	install -o root -g root -D -m 644 ${wifi_fw_path}/ECR6600U_transport.bin "${D}/lib/firmware/ECR6600U_transport.bin"
	install -o root -g root -D -m 644 ${wifi_fw_path}/aic8800/*           -t "${D}/lib/firmware/aic8800"
	install -o root -g root -D -m 644 ${wifi_fw_path}/aic8800DC/*         -t "${D}/lib/firmware/aic8800DC"
}


