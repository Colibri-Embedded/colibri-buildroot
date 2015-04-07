################################################################################
# Virtual package infrastructure
#
# This file implements an infrastructure that eases development of
# package .mk files for virtual packages. It should be used for all
# virtual packages.
#
# See the Buildroot documentation for details on the usage of this
# infrastructure
#
# In terms of implementation, this virtual infrastructure requires
# the .mk file to only call the 'virtual-package' macro.
#
################################################################################

define bundle-install-package
	$$($(2)_FAKEROOT) $$($(2)_FAKEROOT_ENV) $(TAR) --overwrite -C $(3) -xf $$($(2)_TARGET_ARCHIVE);
	@echo "Importing $(2)";
endef

ifeq ($(BR2_BR2_ROOTFS_REMOVE_DOCUMENTATION),y)
define bundle-remove-documentation
	rm -rf $(1)/usr/share/{doc,man,info,gtk-doc,aclocal}/*
endef
endif

ifeq ($(BR2_ROOTFS_REMOVE_DEVELOPMENT),y)
define bundle-remove-development
	rm -rf $(1)/usr/lib/cmake
    rm -rf $(1)/usr/include/*
    rm -rf $(1)/usr/lib/pkgconfig/*
	rm -f $(1)/usr/lib/*.{a,la,sh,py}
    rm -f $(1)/lib/*.{a,la,sh,py}
    rm -f $(1)/usr/bin/*-config
    rm -f $(1)/usr/bin/*_config
endef
endif

ifeq ($(BR2_TARGET_ROOTFS_COLIBRI_LZ4),y)
BUNDLE_SQUASHFS_ARGS += -comp lz4
else
ifeq ($(BR2_TARGET_ROOTFS_COLIBRI_LZO),y)
BUNDLE_SQUASHFS_ARGS += -comp lzo
else
ifeq ($(BR2_TARGET_ROOTFS_COLIBRI_LZMA),y)
BUNDLE_SQUASHFS_ARGS += -comp lzma
else
ifeq ($(BR2_TARGET_ROOTFS_COLIBRI_XZ),y)
BUNDLE_SQUASHFS_ARGS += -comp xz
else
BUNDLE_SQUASHFS_ARGS += -comp gzip
endif
endif
endif
endif

BUNDLE_SQUASHFS_ARGS += -b 512K -no-xattrs -noappend

################################################################################
# inner-bundle-package -- defines the dependency rules of the virtual
# package against its provider.
#
#  argument 1 is the lowercase package name
#  argument 2 is the uppercase package name, including a HOST_ prefix
#             for host packages
#  argument 3 is the uppercase package name, without the HOST_ prefix
#             for host packages
#  argument 4 is the type (target or host)
################################################################################

# Note: putting this comment here rather than in the define block, otherwise
# make would try to expand the $(error ...) in the comment, which is not
# really what we want.
# We need to use second-expansion for the $(error ...) call, below,
# so it is not evaluated now, but as part of the generated make code.

MKSQUASHFS := $(HOST_DIR)/usr/bin/mksquashfs

define inner-bundle-package

ifndef $(2)_MKSQUASHFS
 ifdef $(3)_MKSQUASHFS
  $(2)_MKSQUASHFS = $$($(3)_MKSQUASHFS)
 else
  $(2)_MKSQUASHFS ?= $$(MKSQUASHFS)
 endif
endif

# Ensure the virtual package has an implementation defined.
#~ ifeq ($$(BR2_PACKAGE_HAS_$(2)),y)
#~ ifeq ($$(call qstrip,$$(BR2_PACKAGE_PROVIDES_$(2))),)
#~ $$(error No implementation selected for virtual package $(1). Configuration error)
#~ endif
#~ endif

$(2)_ADD_TOOLCHAIN_DEPENDENCY = NO

$(2)_ARCHIVE_TARGET = NO

# A virtual package does not have any source associated
$(2)_SOURCE =

$(2)_BUNDLE_IMAGE = $(1)-$$($(2)_VERSION).cb

# Fake a version string, so it looks nicer in the build log
#$(2)_VERSION = virtual

# This must be repeated from inner-generic-package, otherwise we get an empty
# _DEPENDENCIES
#ifeq ($(4),host)
#$(2)_DEPENDENCIES ?= $$(filter-out host-toolchain $(1),\
#	$$(patsubst host-host-%,host-%,$$(addprefix host-,$$($(3)_DEPENDENCIES))))
#endif

# Add dependency against the provider
$(2)_DEPENDENCIES += $$(call qstrip,$$($(2)_PACKAGES)) host-squashfs

#~ ifeq ($(2)_ADD_ROOTFS,YES)
#~ 	$(2)_DEPENDENCIES += rootfs-tar
#~ endif

#
# Target installation step. Only define it if not already defined by
# the package .mk file.
#



ifndef $(2)_INSTALL_TARGET_CMDS
define $(2)_INSTALL_TARGET_CMDS
	mkdir -p $$($(2)_TARGET_DIR)
	if [ "x$($(2)_ADD_ROOTFS)" == "xYES" ] ; then \
		$$($(2)_FAKEROOT) $$($(2)_FAKEROOT_ENV) $(TAR) --overwrite -C $$($(2)_TARGET_DIR) -xf $(BINARIES_DIR)/rootfs.tar; \
	fi
	$(foreach pkgname,$($(2)_PACKAGES),$(call bundle-install-package,$(pkgname),$(call UPPERCASE,$(pkgname)), $$($(2)_TARGET_DIR)))
	
	$(call bundle-remove-documentation,$$($(2)_TARGET_DIR))
	$(call bundle-remove-development,$$($(2)_TARGET_DIR))
	
	$$($(2)_FAKEROOT) $$($(2)_FAKEROOT_ENV) $$($(2)_MKSQUASHFS) $$($(2)_TARGET_DIR) $(BUNDLES_DIR)/$$($(2)_BUNDLE_IMAGE) $(BUNDLE_SQUASHFS_ARGS) 
	rm -rf $$($(2)_TARGET_DIR)
endef
endif

# Call the generic package infrastructure to generate the necessary
# make targets
$(call inner-generic2-package,$(1),$(2),$(3),$(4))

endef

################################################################################
# virtual-package -- the target generator macro for virtual packages
################################################################################

bundle-package = $(call inner-bundle-package,$(pkgname),$(call UPPERCASE,$(pkgname)),$(call UPPERCASE,$(pkgname)),target)

