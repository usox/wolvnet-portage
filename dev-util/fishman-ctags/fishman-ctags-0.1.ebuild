# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/ctags/ctags-5.8.ebuild,v 1.11 2014/06/06 05:59:37 vapier Exp $

EAPI="4"

inherit eutils

DESCRIPTION="Exuberant Ctags creates tags files for code browsing in editors"
HOMEPAGE="https://github.com/fishman"
SRC_URI="https://github.com/fishman/ctags/archive/master.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"

DEPEND="app-admin/eselect-ctags"

src_configure() {
	econf \
		--with-posix-regex \
		--without-readlib \
		--disable-etags \
		--enable-tmpdir=/tmp
}

src_install() {
	emake prefix="${D}"/usr mandir="${D}"/usr/share/man install

	# namepace collision with X/Emacs-provided /usr/bin/ctags -- we
	# rename ctags to exuberant-ctags (Mandrake does this also).
	mv "${D}"/usr/bin/{ctags,exuberant-ctags} || die
	mv "${D}"/usr/share/man/man1/{ctags,exuberant-ctags}.1 || die

	dodoc FAQ NEWS README
	dohtml EXTENDING.html ctags.html
}

pkg_postinst() {
	eselect ctags update
	elog "You can set the version to be started by /usr/bin/ctags through"
	elog "the ctags eselect module. \"man ctags.eselect\" for details."
}

pkg_postrm() {
	eselect ctags update
}
