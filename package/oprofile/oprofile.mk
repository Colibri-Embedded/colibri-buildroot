################################################################################
#
# oprofile
#
################################################################################

OPROFILE_VERSION = 1.0.0
OPROFILE_SITE = http://downloads.sourceforge.net/project/oprofile/oprofile/oprofile-$(OPROFILE_VERSION)
OPROFILE_LICENSE = GPLv2+
OPROFILE_LICENSE_FILES = COPYING
OPROFILE_CONF_OPTS = \
	--disable-account-check \
	--enable-gui=no \
	--with-kernel=$(STAGING_DIR)/usr

OPROFILE_BINARIES = \
	utils/ophelp pp/opannotate pp/oparchive pp/opgprof \
	pp/opreport opjitconv/opjitconv \
	utils/op-check-perfevents libabi/opimport \
	pe_counting/ocount

# No perf_events support in kernel for avr32
ifneq ($(BR2_avr32),y)
OPROFILE_BINARIES += pe_profiling/operf
endif

ifeq ($(BR2_i386),y)
OPROFILE_ARCH = i386
endif
ifeq ($(BR2_mipsel),y)
OPROFILE_ARCH = mips
endif
ifeq ($(BR2_powerpc),y)
OPROFILE_ARCH = ppc
endif
ifeq ($(BR2_x86_64),y)
OPROFILE_ARCH = x86-64
endif
ifeq ($(OPROFILE_ARCH),)
OPROFILE_ARCH = $(BR2_ARCH)
endif

OPROFILE_DEPENDENCIES = popt binutils host-pkgconf

ifeq ($(BR2_PACKAGE_LIBPFM4),y)
OPROFILE_DEPENDENCIES += libpfm4
endif

define OPROFILE_INSTALL_TARGET_CMDS
	$(INSTALL) -d -m 755 $(OPROFILE_TARGET_DIR)/usr/bin
	$(INSTALL) -d -m 755 $(OPROFILE_TARGET_DIR)/usr/share/oprofile
	$(INSTALL) -d -m 755 $(OPROFILE_TARGET_DIR)/usr/lib/oprofile
	if [ -d $(@D)/events/$(OPROFILE_ARCH) ]; then \
		cp -dpfr $(@D)/events/$(OPROFILE_ARCH) \
			$(OPROFILE_TARGET_DIR)/usr/share/oprofile; \
	fi
	$(INSTALL) -m 644 $(@D)/libregex/stl.pat $(OPROFILE_TARGET_DIR)/usr/share/oprofile
	$(INSTALL) -m 755 $(addprefix $(@D)/, $(OPROFILE_BINARIES)) $(OPROFILE_TARGET_DIR)/usr/bin
	$(INSTALL) -m 755 $(@D)/libopagent/.libs/*.so* $(OPROFILE_TARGET_DIR)/usr/lib/oprofile
endef

$(eval $(autotools-package))
