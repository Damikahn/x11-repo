TERMUX_PKG_MAINTAINER="Leonid Plyushch <leonid.plyushch@gmail.com> @xeffyr"

TERMUX_PKG_HOMEPAGE=http://qt-project.org/
TERMUX_PKG_DESCRIPTION="A cross-platform application and UI framework"
TERMUX_PKG_VERSION=5.11.1
TERMUX_PKG_SRCURL="http://download.qt.io/official_releases/qt/${TERMUX_PKG_VERSION%.*}/$TERMUX_PKG_VERSION/single/qt-everywhere-src-$TERMUX_PKG_VERSION.tar.xz"
TERMUX_PKG_SHA256=39602cb08f9c96867910c375d783eed00fc4a244bffaa93b801225d17950fb2b
TERMUX_PKG_BUILD_IN_SRC=true

## Note: we need proot for qmake wrapper since there currently no adequate fix
## for the qmake's search paths.
TERMUX_PKG_DEPENDS="harfbuzz, libandroid-support, libandroid-shmem, libc++, libice, libicu, libjpeg-turbo, libpng, libsm, libxcb, libxkbcommon, openssl, pcre2, proot, xcb-util-image, xcb-util-keysyms, xcb-util-renderutil"

termux_step_pre_configure () {
    ## qmake.conf for cross-compiling
    sed \
        -e "s|@TERMUX_CC@|${TERMUX_HOST_PLATFORM}-clang|" \
        -e "s|@TERMUX_CXX@|${TERMUX_HOST_PLATFORM}-clang++|" \
        -e "s|@TERMUX_AR@|${TERMUX_HOST_PLATFORM}-ar|" \
        -e "s|@TERMUX_NM@|${TERMUX_HOST_PLATFORM}-nm|" \
        -e "s|@TERMUX_OBJCOPY@|${TERMUX_HOST_PLATFORM}-objcopy|" \
        -e "s|@TERMUX_PKGCONFIG@|${TERMUX_HOST_PLATFORM}-pkg-config|" \
        -e "s|@TERMUX_STRIP@|${TERMUX_HOST_PLATFORM}-strip|" \
        -e "s|@TERMUX_CFLAGS@|${CPPFLAGS} ${CFLAGS}|" \
        -e "s|@TERMUX_CXXFLAGS@|${CPPFLAGS} ${CXXFLAGS}|" \
        -e "s|@TERMUX_LDFLAGS@|${LDFLAGS}|" \
        "${TERMUX_PKG_BUILDER_DIR}/qmake.conf" > "${TERMUX_PKG_SRCDIR}/qtbase/mkspecs/termux/qmake.conf"

    ## qmake.conf for target.
    ## Should be put to correct place in post_install step.
    sed \
        -e "s|@TERMUX_CC@|clang|" \
        -e "s|@TERMUX_CXX@|clang++|" \
        -e "s|@TERMUX_AR@|ar|" \
        -e "s|@TERMUX_NM@|nm|" \
        -e "s|@TERMUX_OBJCOPY@|objcopy|" \
        -e "s|@TERMUX_PKGCONFIG@|pkg-config|" \
        -e "s|@TERMUX_STRIP@|strip|" \
        -e "s|@TERMUX_CFLAGS@|${CPPFLAGS} ${CFLAGS}|" \
        -e "s|@TERMUX_CXXFLAGS@|${CPPFLAGS} ${CXXFLAGS}|" \
        -e "s|@TERMUX_LDFLAGS@|${LDFLAGS}|" \
        "${TERMUX_PKG_BUILDER_DIR}/qmake.conf" > "/tmp/target-qmake.conf"
}

termux_step_configure () {
    export PKG_CONFIG_SYSROOT_DIR="${TERMUX_PREFIX}"
    unset CC CXX LD CFLAGS LDFLAGS

    "${TERMUX_PKG_SRCDIR}"/configure -v \
        -opensource \
        -confirm-license \
        -release \
        -xplatform termux \
        -optimized-qmake \
        -no-rpath \
        -no-use-gold-linker \
        -prefix "${TERMUX_PREFIX}" \
        -docdir "${TERMUX_PREFIX}/share/doc/qt" \
        -headerdir "${TERMUX_PREFIX}/include/qt" \
        -archdatadir "${TERMUX_PREFIX}/lib/qt" \
        -datadir "${TERMUX_PREFIX}/share/qt" \
        -sysconfdir "${TERMUX_PREFIX}/etc/xdg" \
        -examplesdir "${TERMUX_PREFIX}/share/doc/qt/examples" \
        -plugindir "$TERMUX_PREFIX/libexec/qt" \
        -nomake examples \
        -skip qt3d \
        -skip qtactiveqt \
        -skip qtandroidextras \
        -skip qtcanvas3d \
        -skip qtcharts \
        -skip qtconnectivity \
        -skip qtdatavis3d \
        -skip qtdeclarative \
        -skip qtdoc \
        -skip qtgamepad \
        -skip qtgraphicaleffects \
        -skip qtimageformats \
        -skip qtlocation \
        -skip qtmacextras \
        -skip qtmultimedia \
        -skip qtnetworkauth \
        -skip qtpurchasing \
        -skip qtquickcontrols \
        -skip qtquickcontrols2 \
        -skip qtremoteobjects \
        -skip qtscript \
        -skip qtscxml \
        -skip qtsensors \
        -skip qtserialbus \
        -skip qtserialport \
        -skip qtspeech \
        -skip qtsvg \
        -skip qttools \
        -skip qttranslations \
        -skip qtvirtualkeyboard \
        -skip qtwayland \
        -skip qtwebchannel \
        -skip qtwebengine \
        -skip qtwebglplugin \
        -skip qtwebsockets \
        -skip qtwebview \
        -skip qtwinextras \
        -skip qtx11extras \
        -skip qtxmlpatterns \
        -no-dbus \
        -no-accessibility \
        -no-glib \
        -no-eventfd \
        -no-inotify \
        -icu \
        -system-pcre \
        -system-zlib \
        -ssl \
        -openssl-linked \
        -no-system-proxies \
        -no-cups \
        -system-harfbuzz \
        -no-opengl \
        -no-vulkan \
        -qpa xcb \
        -no-eglfs \
        -no-gbm \
        -no-kms \
        -no-linuxfb \
        -no-mirclient \
        -system-xcb \
        -no-libudev \
        -no-evdev \
        -no-libinput \
        -no-mtdev \
        -no-tslib \
        -system-xkbcommon-x11 \
        -no-xkbcommon-evdev \
        -gif \
        -ico \
        -system-libpng \
        -system-libjpeg \
        -sql-sqlite \
        -no-feature-dnslookup
}

termux_step_make() {
    make -j "${TERMUX_MAKE_PROCESSES}"
}

termux_step_make_install() {
    make install

    cd "${TERMUX_PKG_SRCDIR}/qtbase/src/tools/bootstrap" && {
        make clean

        "${TERMUX_PKG_SRCDIR}/qtbase/bin/qmake" \
            -spec "${TERMUX_PKG_SRCDIR}/qtbase/mkspecs/termux"

        make -j "${TERMUX_MAKE_PROCESSES}"
    }

    for i in moc qlalr qvkgen rcc uic; do
        cd "${TERMUX_PKG_SRCDIR}/qtbase/src/tools/${i}" && {
            make clean

            "${TERMUX_PKG_SRCDIR}/qtbase/bin/qmake" \
                -spec "${TERMUX_PKG_SRCDIR}/qtbase/mkspecs/termux"

            sed \
                -i 's@-lpthread@@g' \
                "${TERMUX_PKG_SRCDIR}/qtbase/src/tools/${i}/Makefile"

            make -j "${TERMUX_MAKE_PROCESSES}"

            install \
                -Dm700 "${TERMUX_PKG_BUILDDIR}/qtbase/bin/${i}" \
                "${TERMUX_PREFIX}/bin/${i}"
        }
    done
    unset i

    cd "${TERMUX_PKG_SRCDIR}/qtbase/qmake" && {
        make clean

        make \
            -j "${TERMUX_MAKE_PROCESSES}" \
            AR="${TERMUX_HOST_PLATFORM}-ar cqs" \
            CC="${TERMUX_HOST_PLATFORM}-clang" \
            CXX="${TERMUX_HOST_PLATFORM}-clang++" \
            LINK="${TERMUX_HOST_PLATFORM}-clang++" \
            STRIP="${TERMUX_HOST_PLATFORM}-strip" \
            QMAKESPEC="${TERMUX_PKG_SRCDIR}/qtbase/mkspecs/termux" \
            QMAKE_LFLAGS="${TERMUX_PREFIX}/lib/libc++_shared.so"

        install \
            -Dm700 "${TERMUX_PKG_BUILDDIR}/qtbase/bin/qmake" \
            "${TERMUX_PREFIX}/libexec/qt-bin/qmake"

        install \
            -Dm700 "${TERMUX_PKG_BUILDER_DIR}/qmake" \
            "${TERMUX_PREFIX}/bin/qmake"
    }

    install \
        -Dm600 \
        "/tmp/target-qmake.conf" \
        "${TERMUX_PREFIX}/lib/qt/mkspecs/termux/qmake.conf"
}
