################################################################################
#
# python3
#
################################################################################

PYTHON3_VERSION_MAJOR = 3.5
PYTHON3_VERSION = $(PYTHON3_VERSION_MAJOR).2
PYTHON3_SOURCE = Python-$(PYTHON3_VERSION).tar.xz
PYTHON3_SITE = http://python.org/ftp/python/$(PYTHON3_VERSION)
PYTHON3_LICENSE = Python software foundation license v2, others
PYTHON3_LICENSE_FILES = LICENSE

# Python itself doesn't use libtool, but it includes the source code
# of libffi, which uses libtool. Unfortunately, it uses a beta version
# of libtool for which we don't have a matching patch. However, this
# is not a problem, because we don't use the libffi copy included in
# the Python sources, but instead use an external libffi library.
PYTHON3_LIBTOOL_PATCH = NO

# Python needs itself and a "pgen" program to build itself, both being
# provided in the Python sources. So in order to cross-compile Python,
# we need to build a host Python first. This host Python is also
# installed in $(HOST_DIR), as it is needed when cross-compiling
# third-party Python modules.

HOST_PYTHON3_CONF_OPTS += 	\
	--without-ensurepip	\
	--without-cxx-main 	\
	--disable-sqlite3	\
	--disable-tk		\
	--with-expat=system	\
	--disable-curses	\
	--disable-codecs-cjk	\
	--disable-nis		\
	--enable-unicodedata	\
	--disable-test-modules	\
	--disable-idle3		\
	--disable-ossaudiodev

# Make sure that LD_LIBRARY_PATH overrides -rpath.
# This is needed because libpython may be installed at the same time that
# python is called.
HOST_PYTHON3_CONF_ENV += \
	LDFLAGS="$(HOST_LDFLAGS) -Wl,--enable-new-dtags"

PYTHON3_DEPENDENCIES = host-python3 libffi

HOST_PYTHON3_DEPENDENCIES = host-expat host-zlib

PYTHON3_INSTALL_STAGING = YES

ifeq ($(BR2_PACKAGE_PYTHON3_READLINE),y)
PYTHON3_DEPENDENCIES += readline
endif

ifeq ($(BR2_PACKAGE_PYTHON3_CURSES),y)
PYTHON3_DEPENDENCIES += ncurses
else
PYTHON3_CONF_OPTS += --disable-curses
endif

ifeq ($(BR2_PACKAGE_PYTHON3_DECIMAL),y)
PYTHON3_DEPENDENCIES += mpdecimal
PYTHON3_CONF_OPTS += --with-libmpdec=system
else
PYTHON3_CONF_OPTS += --with-libmpdec=none
endif

ifeq ($(BR2_PACKAGE_PYTHON3_PYEXPAT),y)
PYTHON3_DEPENDENCIES += expat
PYTHON3_CONF_OPTS += --with-expat=system
else
PYTHON3_CONF_OPTS += --with-expat=none
endif

ifeq ($(BR2_PACKAGE_PYTHON3_PYC_ONLY),y)
PYTHON3_CONF_OPTS += --enable-old-stdlib-cache
endif

ifeq ($(BR2_PACKAGE_PYTHON3_SQLITE),y)
PYTHON3_DEPENDENCIES += sqlite
else
PYTHON3_CONF_OPTS += --disable-sqlite3
endif

ifeq ($(BR2_PACKAGE_PYTHON3_SSL),y)
PYTHON3_DEPENDENCIES += openssl
endif

ifneq ($(BR2_PACKAGE_PYTHON3_CODECSCJK),y)
PYTHON3_CONF_OPTS += --disable-codecs-cjk
endif

ifneq ($(BR2_PACKAGE_PYTHON3_UNICODEDATA),y)
PYTHON3_CONF_OPTS += --disable-unicodedata
endif

ifeq ($(BR2_PACKAGE_PYTHON3_BZIP2),y)
PYTHON3_DEPENDENCIES += bzip2
endif

ifeq ($(BR2_PACKAGE_PYTHON3_ZLIB),y)
PYTHON3_DEPENDENCIES += zlib
endif

ifeq ($(BR2_PACKAGE_PYTHON3_OSSAUDIODEV),y)
PYTHON3_CONF_OPTS += --enable-ossaudiodev
else
PYTHON3_CONF_OPTS += --disable-ossaudiodev
endif

PYTHON3_CONF_ENV += \
	ac_cv_have_long_long_format=yes \
	ac_cv_file__dev_ptmx=yes \
	ac_cv_file__dev_ptc=yes \
	ac_cv_working_tzset=yes

# uClibc is known to have a broken wcsftime() implementation, so tell
# Python 3 to fall back to strftime() instead.
ifeq ($(BR2_TOOLCHAIN_USES_UCLIBC),y)
PYTHON3_CONF_ENV += ac_cv_func_wcsftime=no
endif

PYTHON3_CONF_OPTS += \
	--without-ensurepip	\
	--without-cxx-main 	\
	--with-system-ffi	\
	--disable-pydoc		\
	--disable-test-modules	\
	--disable-lib2to3	\
	--disable-tk		\
	--disable-nis		\
	--disable-idle3		\
	--disable-pyc-build

# Python builds two tools to generate code: 'pgen' and
# '_freeze_importlib'. Unfortunately, for the target Python, they are
# built for the target, while we need to run them at build time. So
# when installing host-python, we copy them to
# $(HOST_DIR)/usr/bin. And then, when building the target python
# package, we tell the configure script where they are located.
define HOST_PYTHON3_INSTALL_TOOLS
	cp $(@D)/Parser/pgen $(HOST_DIR)/usr/bin/python-pgen
	cp $(@D)/Programs/_freeze_importlib $(HOST_DIR)/usr/bin/python-freeze-importlib
endef

# Python from version 3.2 makes extensions have extensions of format 
# 'cpython-XXm-ARCH-SYSTEM.so'. This is a problem as the generated 
# extension is for the host python not for the target. Therefore the 
# extension is hard wired to just '.so' which is also fully supported.
define hoat_python3_fix_ext_so
	sed -e "s@ext_suffix = get_config_var('EXT_SUFFIX')@ext_suffix = '.so'@g" -i $(HOST_DIR)/usr/lib/python$(PYTHON3_VERSION_MAJOR)/distutils/command/build_ext.py
endef

HOST_PYTHON3_POST_INSTALL_HOOKS += hoat_python3_fix_ext_so
HOST_PYTHON3_POST_INSTALL_HOOKS += HOST_PYTHON3_INSTALL_TOOLS

PYTHON3_CONF_ENV += \
	PGEN_FOR_BUILD=$(HOST_DIR)/usr/bin/python-pgen \
	FREEZE_IMPORTLIB_FOR_BUILD=$(HOST_DIR)/usr/bin/python-freeze-importlib

#
# Remove useless files. In the config/ directory, only the Makefile
# and the pyconfig.h files are needed at runtime.
#
define PYTHON3_REMOVE_USELESS_FILES
	$(PYTHON3_FAKEROOT) rm -f $(PYTHON3_TARGET_DIR)/usr/bin/python$(PYTHON3_VERSION_MAJOR)-config
	$(PYTHON3_FAKEROOT) rm -f $(PYTHON3_TARGET_DIR)/usr/bin/python$(PYTHON3_VERSION_MAJOR)m-config
	$(PYTHON3_FAKEROOT) rm -f $(PYTHON3_TARGET_DIR)/usr/bin/python3-config
	$(PYTHON3_FAKEROOT) rm -f $(PYTHON3_TARGET_DIR)/usr/bin/smtpd.py.3
	for i in `find $(PYTHON3_TARGET_DIR)/usr/lib/python$(PYTHON3_VERSION_MAJOR)/config-$(PYTHON3_VERSION_MAJOR)m/ \
		-type f -not -name pyconfig.h -a -not -name Makefile` ; do \
		$(PYTHON3_FAKEROOT) rm -f $$i ; \
	done
	$(PYTHON3_FAKEROOT) rm -rf $(PYTHON3_TARGET_DIR)/usr/lib/python$(PYTHON3_VERSION_MAJOR)/__pycache__/
	$(PYTHON3_FAKEROOT) rm -rf $(PYTHON3_TARGET_DIR)/usr/lib/python$(PYTHON3_VERSION_MAJOR)/lib-dynload/sysconfigdata/__pycache__
	$(PYTHON3_FAKEROOT) rm -rf $(PYTHON3_TARGET_DIR)/usr/lib/python$(PYTHON3_VERSION_MAJOR)/collections/__pycache__
	$(PYTHON3_FAKEROOT) rm -rf $(PYTHON3_TARGET_DIR)/usr/lib/python$(PYTHON3_VERSION_MAJOR)/importlib/__pycache__
endef

PYTHON3_POST_INSTALL_TARGET_HOOKS += PYTHON3_REMOVE_USELESS_FILES

#
# Make sure libpython gets stripped out on target
#
define PYTHON3_ENSURE_LIBPYTHON_STRIPPED
	$(PYTHON3_FAKEROOT) chmod u+w $(PYTHON3_TARGET_DIR)/usr/lib/libpython$(PYTHON3_VERSION_MAJOR)*.so
endef

PYTHON3_POST_INSTALL_TARGET_HOOKS += PYTHON3_ENSURE_LIBPYTHON_STRIPPED

PYTHON3_AUTORECONF = YES

define PYTHON3_INSTALL_SYMLINK
	$(PYTHON3_FAKEROOT) ln -fs python$(PYTHON3_VERSION_MAJOR) $(PYTHON3_TARGET_DIR)/usr/bin/python
endef

ifneq ($(BR2_PACKAGE_PYTHON),y)
PYTHON3_POST_INSTALL_TARGET_HOOKS += PYTHON3_INSTALL_SYMLINK
endif

# Some packages may have build scripts requiring python3, whatever is the
# python version chosen for the target.
# Only install the python symlink in the host tree if python3 is enabled
# for the target.
ifeq ($(BR2_PACKAGE_PYTHON3),y)
define HOST_PYTHON3_INSTALL_SYMLINK
	ln -fs python3 $(HOST_DIR)/usr/bin/python
	ln -fs python3-config $(HOST_DIR)/usr/bin/python-config
endef

HOST_PYTHON3_POST_INSTALL_HOOKS += HOST_PYTHON3_INSTALL_SYMLINK
endif

# Provided to other packages
#~ PYTHON3_PATH = $(PYTHON3_TARGET_DIR)/usr/lib/python$(PYTHON3_VERSION_MAJOR)/sysconfigdata/:$(PYTHON3_TARGET_DIR)/usr/lib/python$(PYTHON3_VERSION_MAJOR)/site-packages/
PYTHON3_PATH = $(HOST_DIR)/usr/lib/python$(PYTHON3_VERSION_MAJOR)/sysconfigdata/:$(HOST_DIR)/usr/lib/python$(PYTHON3_VERSION_MAJOR)/site-packages/:$(STAGING_DIR)/usr/lib/python$(PYTHON3_VERSION_MAJOR)/sysconfigdata/:$(STAGING_DIR)/usr/lib/python$(PYTHON3_VERSION_MAJOR)/site-packages/

ifeq ($(BR2_PACKAGE_PYTHON3),y)
SELECTED_PYTHON_VERSION_MAJOR=$(PYTHON3_VERSION_MAJOR)
endif

$(eval $(autotools-package))
$(eval $(host-autotools-package))

define PYTHON3_CREATE_PYC_FILES
	PYTHONPATH="$(PYTHON3_PATH)" \
	$(PYTHON3_FAKEROOT) $(HOST_DIR)/usr/bin/python$(PYTHON3_VERSION_MAJOR) \
		support/scripts/pycompile.py \
		$(PYTHON3_TARGET_DIR)/usr/lib/python$(PYTHON3_VERSION_MAJOR)
endef

ifeq ($(BR2_PACKAGE_PYTHON3_PYC_ONLY)$(BR2_PACKAGE_PYTHON3_PY_PYC),y)
PYTHON3_POST_INSTALL_TARGET_HOOKS += PYTHON3_CREATE_PYC_FILES
endif

ifeq ($(BR2_PACKAGE_PYTHON3_PYC_ONLY),y)
define PYTHON3_REMOVE_PY_FILES
	find $(PYTHON3_TARGET_DIR)/usr/lib/python$(PYTHON3_VERSION_MAJOR) -name '*.py' -print0 | \
		xargs -0 --no-run-if-empty rm -f
endef
PYTHON3_POST_INSTALL_TARGET_HOOKS += PYTHON3_REMOVE_PY_FILES
endif

# Normally, *.pyc files should not have been compiled, but just in
# case, we make sure we remove all of them.
ifeq ($(BR2_PACKAGE_PYTHON3_PY_ONLY),y)
define PYTHON3_REMOVE_PYC_FILES
	find $(PYTHON3_TARGET_DIR)/usr/lib/python$(PYTHON3_VERSION_MAJOR) -name '*.pyc' -print0 | \
		xargs -0 --no-run-if-empty rm -f
endef
PYTHON3_POST_INSTALL_TARGET_HOOKS += PYTHON3_REMOVE_PYC_FILES
endif

# In all cases, we don't want to keep the optimized .opt-1.pyc and
# .opt-2.pyc files, since they can't work without their non-optimized
# variant.
define PYTHON3_REMOVE_OPTIMIZED_PYC_FILES
	find $(PYTHON3_TARGET_DIR)/usr/lib/python$(PYTHON3_VERSION_MAJOR) -name '*.opt-1.pyc' -print0 -o -name '*.opt-2.pyc' -print0 | \
		xargs -0 --no-run-if-empty rm -f
endef
PYTHON3_POST_INSTALL_TARGET_HOOKS += PYTHON3_REMOVE_OPTIMIZED_PYC_FILES
