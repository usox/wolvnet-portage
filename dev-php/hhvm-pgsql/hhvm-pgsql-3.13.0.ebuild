# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils git-2 user

EGIT_REPO_URI="https://github.com/PocketRent/hhvm-pgsql.git"

EGIT_COMMIT="${PV}"
KEYWORDS="-* amd64"

IUSE="hack"

DESCRIPTION="Postgres extension for HHVM"
HOMEPAGE="https://github.com/PocketRent/hhvm-pgsql"

DEPEND="
	=dev-php/hhvm-3.13.1
	dev-db/postgresql
	>=dev-util/cmake-2.8.7
"

SLOT="0"
LICENSE="PHP-3"

src_prepare()
{
	epatch "${FILESDIR}/fix_pg_config_header_path.patch"
}

src_configure()
{
	if use hack; then
		OPTS="${OPTS} -DHACK_FRIENDLY=ON"
	fi

	hphpize
	cmake ${OPTS} .
}

src_install()
{
	emake install DESTDIR="${D}"
	
	cp -a "${S}/hphp/hack/tools" "${D}/usr/share/hhvm/hack/"
	ln -s "${D}/usr/lib64/hhvm/extensions/20150212/pgsql.so" "${D}/usr/lib64/hhvm/extensions/pgsql.so"
	
	insinto /etc/hhvm
	newins "${FILESDIR}"/server.ini server.ini
	newins "${FILESDIR}"/server.ini server.ini.pgsql.dist
}
