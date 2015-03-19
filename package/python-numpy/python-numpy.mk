################################################################################
#
# python-numpy
#
################################################################################

PYTHON_NUMPY_VERSION = 1.8.0
PYTHON_NUMPY_SOURCE = numpy-$(PYTHON_NUMPY_VERSION).tar.gz
PYTHON_NUMPY_SITE = http://downloads.sourceforge.net/numpy
PYTHON_NUMPY_LICENSE = BSD-3c
PYTHON_NUMPY_LICENSE_FILES = LICENSE.txt
PYTHON_NUMPY_SETUP_TYPE = distutils

ifeq ($(BR2_PACKAGE_CLAPACK),y)
PYTHON_NUMPY_DEPENDENCIES += clapack
PYTHON_NUMPY_SITE_CFG_LIBS += blas lapack
endif

PYTHON_NUMPY_BUILD_OPTS = --fcompiler=None

define PYTHON_NUMPY_CONFIGURE_CMDS
	rm -f $(@D)/site.cfg
	echo "[DEFAULT]" >> $(@D)/site.cfg
	echo "library_dirs = $(STAGING_DIR)/usr/lib" >> $(@D)/site.cfg
	echo "include_dirs = $(STAGING_DIR)/usr/include" >> $(@D)/site.cfg
	echo "libraries =" $(subst $(space),$(comma),$(PYTHON_NUMPY_SITE_CFG_LIBS)) >> $(@D)/site.cfg
endef

# Some package may include few headers from NumPy, so let's install it
# in the staging area.
PYTHON_NUMPY_INSTALL_STAGING = YES

# host-python will be used for building SciPy but it is linked to host blas libraries
# therefore the target site.cfg is copied to link it to target libraries
define HOST_PYTHON_NUMPY_COPY_TARGET_FILES
	cp $(STAGING_DIR)/usr/lib/python2.7/site-packages/numpy/distutils/site.cfg $(HOST_DIR)/usr/lib/python2.7/site-packages/numpy/distutils/
	rm -f $(HOST_DIR)/usr/lib/python2.7/site-packages/numpy/core/lib/libnpymath.a
	cp $(STAGING_DIR)/usr/lib/python2.7/site-packages/numpy/core/lib/libnpymath.a $(HOST_DIR)/usr/lib/python2.7/site-packages/numpy/core/lib/
endef

define HOST_PYTHON_NUMPY_FORCE_CROSS_GFORTRAN
	sed -e "s@possible_executables = \['gfortran'\]@possible_executables = \['$(TARGET_CROSS)gfortran'\]@" -i $(HOST_DIR)/usr/lib/python2.7/site-packages/numpy/distutils/fcompiler/gnu.py
endef

HOST_PYTHON_NUMPY_POST_INSTALL_HOOKS += HOST_PYTHON_NUMPY_COPY_TARGET_FILES \
										HOST_PYTHON_NUMPY_FORCE_CROSS_GFORTRAN

$(eval $(python-package))
$(eval $(host-python-package))
