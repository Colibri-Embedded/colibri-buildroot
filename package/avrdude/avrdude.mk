################################################################################
#
# avrdude
#
################################################################################

AVRDUDE_VERSION = 6.3
AVRDUDE_SITE = http://download.savannah.gnu.org/releases/avrdude
AVRDUDE_SOURCE = avrdude-$(AVRDUDE_VERSION).tar.gz
AVRDUDE_LICENSE = GPLv2+
AVRDUDR_LICENSE_FILES = avrdude/COPYING

AVRDUDE_CONF_OPTS += --enable-linuxgpio

AVRDUDE_AUTORECONF = YES
AVRDUDE_DEPENDENCIES += elfutils libusb libusb-compat ncurses \
	host-flex host-bison
AVRDUDE_LICENSE = GPLv2+
AVRDUDE_LICENSE_FILES = avrdude/COPYING

ifeq ($(BR2_PACKAGE_LIBFTDI),y)
AVRDUDE_DEPENDENCIES += libftdi
endif

# if /etc/avrdude.conf exists, the installation process creates a
# backup file, which we do not want in the context of Buildroot.
define AVRDUDE_REMOVE_BACKUP_FILE
	$(AVRDUDE_FAKEROOT) $(RM) -f $(AVRDUDE_TARGET_DIR)/etc/avrdude.conf.bak
endef

AVRDUDE_POST_INSTALL_TARGET_HOOKS += AVRDUDE_REMOVE_BACKUP_FILE

$(eval $(autotools-package))
