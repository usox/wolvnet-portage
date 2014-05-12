# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $

EAPI=5
DESCRIPTION="A stream recorder"
RESTRICT="nomirror"
SRC_URI="http://github.com/Pavion/tvstreamrecord/archive/${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
HOMEPAGE="http://github.com/Pavion/tvstreamrecord"
SLOT=0
RDEPEND="dev-lang/python:2.7[sqlite]
		media-video/ffmpeg
		dev-db/sqlite:3"

src_install() {
	newinitd "${FILESDIR}"/tvstreamrecord-init tvstreamrecord
	dodir /opt/tvstreamrecord/
	cp -R "${S}/"* "${D}/opt/tvstreamrecord" || die "Install failed!"
	fperms u=rwx,g=rx,o=rx /opt/tvstreamrecord/tvstreamrecord.py
}
