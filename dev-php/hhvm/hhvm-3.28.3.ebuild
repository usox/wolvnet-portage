# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils git-2 user

EGIT_REPO_URI="https://github.com/facebook/hhvm.git"

# For now, git is the only way to fetch releases
# https://github.com/facebook/hhvm/issues/2806
EGIT_COMMIT="HHVM-${PV}"
KEYWORDS="-* ~amd64"

IUSE="debug jsonc mysql-socket xen zend-compat hack postgres cpu_flags_x86_sse4_2"

DESCRIPTION="Virtual Machine, Runtime, and JIT for PHP"
HOMEPAGE="http://www.hhvm.com"

RDEPEND="
	app-arch/bzip2
	dev-cpp/glog[gflags]
	dev-cpp/gflags
	dev-cpp/tbb
	dev-db/sqlite
	>=dev-libs/boost-1.49[context]
	dev-libs/elfutils
	dev-libs/expat
	dev-libs/icu
	>=dev-libs/jemalloc-3.0.0[stats]
	jsonc? ( dev-libs/json-c )
	dev-libs/libdwarf
	>=dev-libs/libevent-2.0.9
	<=dev-libs/libxml2-2.9.7
	dev-libs/libmcrypt
	dev-libs/libmemcached
	dev-libs/libpcre
	dev-libs/libxml2
	dev-libs/libxslt
	>=dev-libs/libzip-0.11.0
	dev-libs/oniguruma
	dev-libs/openssl
	media-gfx/imagemagick
	media-libs/freetype
	media-libs/gd[jpeg,png]
	net-libs/c-client[kerberos]
	>=net-misc/curl-7.28.0
	net-nds/openldap
	sys-libs/libcap
	sys-libs/ncurses
	sys-libs/readline
	sys-libs/zlib
	virtual/mysql
	dev-libs/double-conversion
	dev-libs/re2
	sys-process/numactl
"

PDEPEND="
	!dev-php/hhvm-pgsql
"

DEPEND="
	${RDEPEND}
	>=dev-util/cmake-3.7.2
	sys-devel/binutils[static-libs]
	sys-devel/bison
	sys-devel/flex
	postgres? ( dev-db/postgresql )
"

SLOT="0"
LICENSE="PHP-3"

pkg_pretend() {
	if [[ $(gcc-major-version) -lt 4 ]] || \
			( [[ $(gcc-major-version) -eq 4 && $(gcc-minor-version) -lt 8 ]] ) \
			; then
		eerror "${PN} needs to be built with gcc-4.8 or later."
		eerror "Please use gcc-config to switch to gcc-4.8 or later version."
		die
	fi
}

pkg_setup() {
	ebegin "Creating hhvm user and group"
	enewgroup hhvm
	enewuser hhvm -1 -1 "/var/lib/hhvm" hhvm
	eend $?
}

src_prepare()
{
	git submodule update --init --recursive
	epatch "${FILESDIR}/hhvm_change_library_include_path.patch"
	epatch "${FILESDIR}/revert_to_old_atomic_linking.patch"
}

src_configure()
{
	CMAKE_BUILD_TYPE="Release"

	if use debug; then
		CMAKE_BUILD_TYPE="Debug"
	fi

	if use jsonc; then
		HHVM_OPTS="${HHVM_OPTS} -DUSE_JSONC=ON"
	fi

	if use xen; then
		HHVM_OPTS="${HHVM_OPTS} -DDISABLE_HARDWARE_COUNTERS=ON"
	fi

	if use zend-compat; then
		HHVM_OPTS="${HHVM_OPTS} -DENABLE_ZEND_COMPAT=ON"
	fi

	if use mysql-socket; then
		ebegin "Searching for MySQL socket..."
		if [[ -S /var/run/mysqld/mysqld.sock ]]; then
			eend $?
		else
			eerror "Socket not found. Please start the MySQL/MariaDB server."
			die "MySQL socket support enabled but server isn't running"
		fi
	else
		HHVM_OPTS="${HHVM_OPTS} -DMYSQL_UNIX_SOCK_ADDR=/dev/null"
	fi

	# Fix for https://github.com/facebook/hhvm/issues/7503
	HHVM_OPTS="${HHVM_OPTS} -DCMAKE_C_FLAGS=-O0 -DCMAKE_CXX_FLAGS=-O0"

	export ATOMIC_LIBRARY="/usr/lib64/gcc/x86_64-pc-linux-gnu/7.3.0/"

	econf -DCMAKE_INSTALL_PREFIX="/usr" -DCMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE}" ${HHVM_OPTS}
}

src_install()
{
	emake install DESTDIR="${D}"

	if use hack; then
		dobin hphp/hack/bin/hh_client
		dobin hphp/hack/bin/hh_server
		dobin hphp/hack/bin/hh_parse
		dobin hphp/hack/bin/hh_single_type_check
		dodir "/usr/share/hhvm/hack"
		cp -a "${S}/hphp/hack/editor-plugins/emacs" "${D}/usr/share/hhvm/hack/"
		cp -a "${S}/hphp/hack/tools" "${D}/usr/share/hhvm/hack/"
	fi

	newinitd "${FILESDIR}"/hhvm.initd-r4 hhvm
	newconfd "${FILESDIR}"/hhvm.confd-r4 hhvm
	dodir "/etc/hhvm"
	insinto /etc/hhvm
	newins "${FILESDIR}"/php.ini php.ini
	newins "${FILESDIR}"/php.ini php.ini.dist
	newins "${FILESDIR}"/server.ini server.ini
	newins "${FILESDIR}"/server.ini server.ini.dist
}
