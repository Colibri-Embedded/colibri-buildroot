################################################################################
#
# fatresize
#
################################################################################

FATRESIZE_VERSION = 1.0.2
FATRESIZE_SOURCE = fatresize_$(FATRESIZE_VERSION).orig.tar.gz
#FATRESIZE_SITE = http://sunet.dl.sourceforge.net/project/fatresize/fatresize/$(FATRESIZE_VERSION)
FATRESIZE_SITE = http://http.debian.net/debian/pool/main/f/fatresize/
FATRESIZE_DEPENDENCIES = parted util-linux

# For patches
FATRESIZE_AUTORECONF = YES
FATRESIZE_LICENSE = GPLv2
FATRESIZE_LICENSE_FILES = COPYING

$(eval $(autotools-package))
