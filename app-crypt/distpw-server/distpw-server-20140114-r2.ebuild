# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $

DESCRIPTION="Distpw password server"
SRC_URI="${P}.tar.bz2"
LICENSE="GPL-2"
KEYWORDS="~amd64"
RESTRICT="fetch"
HOMEPAGE="http://93i.de"
SLOT=0

pkg_nofetch() {
	einfo "Please download"
	einfo "  - ${P}.tar.bz2"
	einfo "and place them in ${DISTDIR}"
}

src_install() {
	newinitd "${FILESDIR}"/distpw-init-script distpw-server
	dodir /var/lib/distpw-server
	insinto /var/lib/distpw-server
	newins distpw distpw || die
	newins config.js config.js || die

	fowners root:root /var/lib/distpw-server
	fperms u=rw,g=,o= /var/lib/distpw-server/config.js
	fperms u=rwx,g=,o= /var/lib/distpw-server/distpw
}
