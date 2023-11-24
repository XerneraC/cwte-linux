EAPI=8

inherit git-r3

DESCRIPTION="WiFi firmware for the in the VF2 included WiFi dongle"
HOMEPAGE="https://github.com/starfive-tech/buildroot"
EGIT_REPO_URI="https://github.com/starfive-tech/buildroot.git"
EGIT_BRANCH="JH7110_VisionFive2_devel"


LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* ~riscv"
IUSE=""
RESTRICT="mirror"


local_git_repo="${S}/blah"
wifi_fw_path="${local_git_repo}/package/starfive/usb_wifi"

infomsg="Even though we pulled an enitre buildroot repo, we only require a small part of it. As the default functions want to compile that buildroot, i need to override them"

src_prepare() {
	eapply_user
	ls "${S}"
	echo $infomsg
}

src_configure() {
	ls "${S}"
	echo $infomsg
}
src_compile() {
	echo $infomsg
}

src_install() {
	ls "${S}"
	die "Don't know how this works"
	install -o root -g root -D -m 644 ${wifi_fw_path}/ECR6600U_transport.bin "${D}/lib/firmware/ECR6600U_transport.bin"
	install -o root -g root -D -m 644 ${wifi_fw_path}/aic8800/*           -t "${D}/lib/firmware/aic8800"
	install -o root -g root -D -m 644 ${wifi_fw_path}/aic8800DC/*         -t "${D}/lib/firmware/aic8800DC"
}


