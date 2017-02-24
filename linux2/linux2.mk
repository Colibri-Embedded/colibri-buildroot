################################################################################
#
# Secondary Linux kernel target
#
################################################################################

LINUX2_VERSION = $(call qstrip,$(BR2_LINUX2_KERNEL_VERSION))
LINUX2_LICENSE = GPLv2
LINUX2_LICENSE_FILES = COPYING

# BR2_LINUX2_KERNEL_SAME_AS_PRIMARY_VERSION

# Compute LINUX2_SOURCE and LINUX2_SITE from the configuration
ifeq ($(BR2_LINUX2_KERNEL_CUSTOM_TARBALL),y)
LINUX2_TARBALL = $(call qstrip,$(BR2_LINUX2_KERNEL_CUSTOM_TARBALL_LOCATION))
LINUX2_SITE = $(patsubst %/,%,$(dir $(LINUX2_TARBALL)))
LINUX2_SOURCE = $(notdir $(LINUX2_TARBALL))
else ifeq ($(BR2_LINUX2_KERNEL_CUSTOM_LOCAL),y)
LINUX2_SITE = $(call qstrip,$(BR2_LINUX2_KERNEL_CUSTOM_LOCAL_PATH))
LINUX2_SITE_METHOD = local
else ifeq ($(BR2_LINUX2_KERNEL_CUSTOM_GIT),y)
LINUX2_SITE = $(call qstrip,$(BR2_LINUX2_KERNEL_CUSTOM_REPO_URL))
LINUX2_SITE_METHOD = git
else ifeq ($(BR2_LINUX2_KERNEL_CUSTOM_HG),y)
LINUX2_SITE = $(call qstrip,$(BR2_LINUX2_KERNEL_CUSTOM_REPO_URL))
LINUX2_SITE_METHOD = hg
else

ifeq ($(BR2_LINUX2_KERNEL_SAME_AS_PRIMARY_VERSION),y)
LINUX2_SOURCE = linux-$(LINUX2_VERSION).tar.gz
else
LINUX2_SOURCE = linux-$(LINUX2_VERSION).tar.xz
endif
# In X.Y.Z, get X and Y. We replace dots and dashes by spaces in order
# to use the $(word) function. We support versions such as 4.0, 3.1,
# 2.6.32, 2.6.32-rc1, 3.0-rc6, etc.
ifeq ($(findstring x2.6.,x$(LINUX2_VERSION)),x2.6.)
LINUX2_SITE = $(BR2_KERNEL_MIRROR)/linux/kernel/v2.6
else ifeq ($(findstring x3.,x$(LINUX2_VERSION)),x3.)
LINUX2_SITE = $(BR2_KERNEL_MIRROR)/linux/kernel/v3.x
else ifeq ($(findstring x4.,x$(LINUX2_VERSION)),x4.)
LINUX2_SITE = $(BR2_KERNEL_MIRROR)/linux/kernel/v4.x
endif
# release candidates are in testing/ subdir
ifneq ($(findstring -rc,$(LINUX2_VERSION)),)
LINUX2_SITE := $(LINUX2_SITE)/testing/
endif # -rc
endif

LINUX2_PATCHES = $(call qstrip,$(BR2_LINUX2_KERNEL_PATCH))

LINUX2_INSTALL_IMAGES = YES
LINUX2_DEPENDENCIES += host-kmod host-lzop

ifeq ($(BR2_LINUX2_KERNEL_UBOOT_IMAGE),y)
	LINUX2_DEPENDENCIES += host-uboot-tools
endif

LINUX2_TARGET_DIR = $(PACKAGES_DIR)/linux

LINUX2_MAKE_FLAGS = \
	HOSTCC="$(HOSTCC)" \
	HOSTCFLAGS="$(HOSTCFLAGS)" \
	ARCH=$(KERNEL_ARCH) \
	INSTALL_MOD_PATH=$(LINUX2_TARGET_DIR) \
	CROSS_COMPILE="$(CCACHE) $(TARGET_CROSS)" \
	DEPMOD=$(HOST_DIR)/sbin/depmod

# Get the real Linux version, which tells us where kernel modules are
# going to be installed in the target filesystem.
LINUX2_VERSION_PROBED = $(shell $(MAKE) $(LINUX2_MAKE_FLAGS) -C $(LINUX2_DIR) --no-print-directory -s kernelrelease)

ifeq ($(BR2_LINUX2_KERNEL_USE_INTREE_DTS),y)
KERNEL2_DTS_NAME = $(call qstrip,$(BR2_LINUX2_KERNEL_INTREE_DTS_NAME))
else ifeq ($(BR2_LINUX2_KERNEL_USE_CUSTOM_DTS),y)
KERNEL2_DTS_NAME = $(basename $(notdir $(call qstrip,$(BR2_LINUX2_KERNEL_CUSTOM_DTS_PATH))))
endif

ifeq ($(BR2_LINUX2_KERNEL_DTS_SUPPORT)$(KERNEL2_DTS_NAME),y)
$(error No kernel device tree source specified, check your \
BR2_LINUX2_KERNEL_USE_INTREE_DTS / BR2_LINUX2_KERNEL_USE_CUSTOM_DTS settings)
endif

ifeq ($(BR2_LINUX2_KERNEL_APPENDED_DTB),y)
ifneq ($(words $(KERNEL2_DTS_NAME)),1)
$(error Kernel with appended device tree needs exactly one DTS source. \
	Check BR2_LINUX2_KERNEL_INTREE_DTS_NAME or BR2_LINUX2_KERNEL_CUSTOM_DTS_PATH.)
endif
endif

KERNEL2_DTBS = $(addsuffix .dtb,$(KERNEL2_DTS_NAME))

ifeq ($(BR2_LINUX2_KERNEL_IMAGE_TARGET_CUSTOM),y)
LINUX2_IMAGE_NAME = $(call qstrip,$(BR2_LINUX2_KERNEL_IMAGE_NAME))
LINUX2_TARGET_NAME = $(call qstrip,$(BR2_LINUX2_KERNEL_IMAGE_TARGET_NAME))
ifeq ($(LINUX2_IMAGE_NAME),)
LINUX2_IMAGE_NAME = $(LINUX2_TARGET_NAME)
endif
else
ifeq ($(BR2_LINUX2_KERNEL_UIMAGE),y)
LINUX2_IMAGE_NAME = uImage
else ifeq ($(BR2_LINUX2_KERNEL_APPENDED_UIMAGE),y)
LINUX2_IMAGE_NAME = uImage
else ifeq ($(BR2_LINUX2_KERNEL_BZIMAGE),y)
LINUX2_IMAGE_NAME = bzImage
else ifeq ($(BR2_LINUX2_KERNEL_ZIMAGE),y)
LINUX2_IMAGE_NAME = zImage
else ifeq ($(BR2_LINUX2_KERNEL_APPENDED_ZIMAGE),y)
LINUX2_IMAGE_NAME = zImage
else ifeq ($(BR2_LINUX2_KERNEL_CUIMAGE),y)
LINUX2_IMAGE_NAME = cuImage.$(KERNEL2_DTS_NAME)
else ifeq ($(BR2_LINUX2_KERNEL_SIMPLEIMAGE),y)
LINUX2_IMAGE_NAME = simpleImage.$(KERNEL2_DTS_NAME)
else ifeq ($(BR2_LINUX2_KERNEL_LINUX_BIN),y)
LINUX2_IMAGE_NAME = linux.bin
else ifeq ($(BR2_LINUX2_KERNEL_VMLINUX_BIN),y)
LINUX2_IMAGE_NAME = vmlinux.bin
else ifeq ($(BR2_LINUX2_KERNEL_VMLINUX),y)
LINUX2_IMAGE_NAME = vmlinux
else ifeq ($(BR2_LINUX2_KERNEL_VMLINUZ),y)
LINUX2_IMAGE_NAME = vmlinuz
endif
# The if-else blocks above are all the image types we know of, and all
# come from a Kconfig choice, so we know we have LINUX2_IMAGE_NAME set
# to something
LINUX2_TARGET_NAME = $(LINUX2_IMAGE_NAME)
endif

LINUX2_KERNEL_UIMAGE_LOADADDR = $(call qstrip,$(BR2_LINUX2_KERNEL_UIMAGE_LOADADDR))
ifneq ($(LINUX2_KERNEL_UIMAGE_LOADADDR),)
LINUX2_MAKE_FLAGS += LOADADDR="$(LINUX2_KERNEL_UIMAGE_LOADADDR)"
endif

# Compute the arch path, since i386 and x86_64 are in arch/x86 and not
# in arch/$(KERNEL_ARCH). Even if the kernel creates symbolic links
# for bzImage, arch/i386 and arch/x86_64 do not exist when copying the
# defconfig file.
ifeq ($(KERNEL_ARCH),i386)
KERNEL2_ARCH_PATH = $(LINUX2_DIR)/arch/x86
else ifeq ($(KERNEL_ARCH),x86_64)
KERNEL2_ARCH_PATH = $(LINUX2_DIR)/arch/x86
else
KERNEL2_ARCH_PATH = $(LINUX2_DIR)/arch/$(KERNEL_ARCH)
endif

ifeq ($(BR2_LINUX2_KERNEL_VMLINUX),y)
LINUX2_IMAGE_PATH = $(LINUX2_DIR)/$(LINUX2_IMAGE_NAME)
else ifeq ($(BR2_LINUX2_KERNEL_VMLINUZ),y)
LINUX2_IMAGE_PATH = $(LINUX2_DIR)/$(LINUX2_IMAGE_NAME)
else
ifeq ($(KERNEL_ARCH),avr32)
LINUX2_IMAGE_PATH = $(KERNEL2_ARCH_PATH)/boot/images/$(LINUX2_IMAGE_NAME)
else
LINUX2_IMAGE_PATH = $(KERNEL2_ARCH_PATH)/boot/$(LINUX2_IMAGE_NAME)
endif
endif # BR2_LINUX2_KERNEL_VMLINUX

define LINUX2_DOWNLOAD_PATCHES
	$(if $(LINUX2_PATCHES),
		@$(call MESSAGE,"Download additional patches"))
	$(foreach patch,$(filter ftp://% http://% https://%,$(LINUX2_PATCHES)),\
		$(call DOWNLOAD_WGET,$(patch),$(notdir $(patch)))$(sep))
endef

LINUX2_POST_DOWNLOAD_HOOKS += LINUX2_DOWNLOAD_PATCHES

define LINUX2_APPLY_PATCHES
	for p in $(LINUX2_PATCHES) ; do \
		if echo $$p | grep -q -E "^ftp://|^http://|^https://" ; then \
			$(APPLY_PATCHES) $(@D) $(DL_DIR) `basename $$p` ; \
		elif test -d $$p ; then \
			$(APPLY_PATCHES) $(@D) $$p linux-\*.patch ; \
		else \
			$(APPLY_PATCHES) $(@D) `dirname $$p` `basename $$p` ; \
		fi \
	done
endef

LINUX2_POST_PATCH_HOOKS += LINUX2_APPLY_PATCHES


ifeq ($(BR2_LINUX2_KERNEL_USE_DEFCONFIG),y)
KERNEL2_SOURCE_CONFIG = $(KERNEL2_ARCH_PATH)/configs/$(call qstrip,$(BR2_LINUX2_KERNEL_DEFCONFIG))_defconfig
else ifeq ($(BR2_LINUX2_KERNEL_USE_CUSTOM_CONFIG),y)
KERNEL2_SOURCE_CONFIG = $(BR2_LINUX2_KERNEL_CUSTOM_CONFIG_FILE)
endif

define LINUX2_CONFIGURE_CMDS
	$(INSTALL) -m 0644 $(KERNEL2_SOURCE_CONFIG) $(KERNEL2_ARCH_PATH)/configs/buildroot_defconfig
	$(TARGET_MAKE_ENV) $(MAKE1) $(LINUX2_MAKE_FLAGS) -C $(@D) buildroot_defconfig
	rm $(KERNEL2_ARCH_PATH)/configs/buildroot_defconfig
	$(if $(BR2_arm)$(BR2_armeb),
		$(call KCONFIG_ENABLE_OPT,CONFIG_AEABI,$(@D)/.config))
	$(if $(BR2_TARGET_ROOTFS_CPIO),
		$(call KCONFIG_ENABLE_OPT,CONFIG_BLK_DEV_INITRD,$(@D)/.config))
	# As the kernel gets compiled before root filesystems are
	# built, we create a fake cpio file. It'll be
	# replaced later by the real cpio archive, and the kernel will be
	# rebuilt using the linux-rebuild-with-initramfs target.
	$(if $(BR2_TARGET_ROOTFS_INITRAMFS),
		touch $(BINARIES_DIR)/rootfs.cpio
		$(call KCONFIG_SET_OPT,CONFIG_INITRAMFS_SOURCE,"$(BINARIES_DIR)/rootfs.cpio",$(@D)/.config)
		$(call KCONFIG_SET_OPT,CONFIG_INITRAMFS_ROOT_UID,0,$(@D)/.config)
		$(call KCONFIG_SET_OPT,CONFIG_INITRAMFS_ROOT_GID,0,$(@D)/.config))
	$(if $(BR2_ROOTFS_DEVICE_CREATION_STATIC),,
		$(call KCONFIG_ENABLE_OPT,CONFIG_DEVTMPFS,$(@D)/.config)
		$(call KCONFIG_ENABLE_OPT,CONFIG_DEVTMPFS_MOUNT,$(@D)/.config))
	$(if $(BR2_ROOTFS_DEVICE_CREATION_DYNAMIC_EUDEV),
		$(call KCONFIG_ENABLE_OPT,CONFIG_INOTIFY_USER,$(@D)/.config))
	$(if $(BR2_PACKAGE_KTAP),
		$(call KCONFIG_ENABLE_OPT,CONFIG_DEBUG_FS,$(@D)/.config)
		$(call KCONFIG_ENABLE_OPT,CONFIG_EVENT_TRACING,$(@D)/.config)
		$(call KCONFIG_ENABLE_OPT,CONFIG_PERF_EVENTS,$(@D)/.config)
		$(call KCONFIG_ENABLE_OPT,CONFIG_FUNCTION_TRACER,$(@D)/.config))
	$(if $(BR2_PACKAGE_SYSTEMD),
		$(call KCONFIG_ENABLE_OPT,CONFIG_CGROUPS,$(@D)/.config)
		$(call KCONFIG_ENABLE_OPT,CONFIG_INOTIFY_USER,$(@D)/.config)
		$(call KCONFIG_ENABLE_OPT,CONFIG_FHANDLE,$(@D)/.config)
		$(call KCONFIG_ENABLE_OPT,CONFIG_AUTOFS4_FS,$(@D)/.config)
		$(call KCONFIG_ENABLE_OPT,CONFIG_TMPFS_POSIX_ACL,$(@D)/.config)
		$(call KCONFIG_ENABLE_OPT,CONFIG_TMPFS_POSIX_XATTR,$(@D)/.config))
	$(if $(BR2_PACKAGE_SMACK),
		$(call KCONFIG_ENABLE_OPT,CONFIG_SECURITY,$(@D)/.config)
		$(call KCONFIG_ENABLE_OPT,CONFIG_SECURITY_SMACK,$(@D)/.config)
		$(call KCONFIG_ENABLE_OPT,CONFIG_SECURITY_NETWORK,$(@D)/.config))
	$(if $(BR2_PACKAGE_IPTABLES),
		$(call KCONFIG_ENABLE_OPT,CONFIG_IP_NF_IPTABLES,$(@D)/.config)
		$(call KCONFIG_ENABLE_OPT,CONFIG_IP_NF_FILTER,$(@D)/.config)
		$(call KCONFIG_ENABLE_OPT,CONFIG_NETFILTER,$(@D)/.config)
		$(call KCONFIG_ENABLE_OPT,CONFIG_NETFILTER_XTABLES,$(@D)/.config))
	$(if $(BR2_PACKAGE_XTABLES_ADDONS),
		$(call KCONFIG_ENABLE_OPT,CONFIG_NF_CONNTRACK,$(@D)/.config)
		$(call KCONFIG_ENABLE_OPT,CONFIG_NF_CONNTRACK_MARK,$(@D)/.config))
	$(if $(BR2_LINUX2_KERNEL_APPENDED_DTB),
		$(call KCONFIG_ENABLE_OPT,CONFIG_ARM_APPENDED_DTB,$(@D)/.config))
	yes '' | $(TARGET_MAKE_ENV) $(MAKE1) $(LINUX2_MAKE_FLAGS) -C $(@D) oldconfig
endef

ifeq ($(BR2_LINUX2_KERNEL_DTS_SUPPORT),y)
ifeq ($(BR2_LINUX2_KERNEL_DTB_IS_SELF_BUILT),)
define LINUX2_BUILD_DTB
	$(TARGET_MAKE_ENV) $(MAKE) $(LINUX2_MAKE_FLAGS) -C $(@D) $(KERNEL2_DTBS)
endef
define LINUX2_INSTALL_DTB
	# dtbs moved from arch/<ARCH>/boot to arch/<ARCH>/boot/dts since 3.8-rc1
	cp $(addprefix \
		$(KERNEL2_ARCH_PATH)/boot/$(if $(wildcard \
		$(addprefix $(KERNEL2_ARCH_PATH)/boot/dts/,$(KERNEL2_DTBS))),dts/),$(KERNEL2_DTBS)) \
		$(BINARIES2_DIR)/
endef
define LINUX2_INSTALL_DTB_TARGET
	# dtbs moved from arch/<ARCH>/boot to arch/<ARCH>/boot/dts since 3.8-rc1
	cp $(addprefix \
		$(KERNEL2_ARCH_PATH)/boot/$(if $(wildcard \
		$(addprefix $(KERNEL2_ARCH_PATH)/boot/dts/,$(KERNEL2_DTBS))),dts/),$(KERNEL2_DTBS)) \
		$(LINUX2_TARGET_DIR)/boot/
endef
define LINUX2_INSTALL_DTB_SDCARD
	# dtbs moved from arch/<ARCH>/boot to arch/<ARCH>/boot/dts since 3.8-rc1
	cp $(addprefix \
		$(KERNEL2_ARCH_PATH)/boot/$(if $(wildcard \
		$(addprefix $(KERNEL2_ARCH_PATH)/boot/dts/,$(KERNEL2_DTBS))),dts/),$(KERNEL2_DTBS)) \
		$(SDCARD_DIR)
endef
endif
endif

ifeq ($(BR2_LINUX2_KERNEL_APPENDED_DTB),y)
# dtbs moved from arch/$ARCH/boot to arch/$ARCH/boot/dts since 3.8-rc1
define LINUX2_APPEND_DTB
	if [ -e $(KERNEL2_ARCH_PATH)/boot/$(KERNEL2_DTS_NAME).dtb ]; then \
		cat $(KERNEL2_ARCH_PATH)/boot/$(KERNEL2_DTS_NAME).dtb; \
	else \
		cat $(KERNEL2_ARCH_PATH)/boot/dts/$(KERNEL2_DTS_NAME).dtb; \
	fi >> $(KERNEL2_ARCH_PATH)/boot/zImage
endef
ifeq ($(BR2_LINUX2_KERNEL_APPENDED_UIMAGE),y)
# We need to generate a new u-boot image that takes into
# account the extra-size added by the device tree at the end
# of the image. To do so, we first need to retrieve both load
# address and entry point for the kernel from the already
# generate uboot image before using mkimage -l.
LINUX2_APPEND_DTB += $(sep) MKIMAGE_ARGS=`$(MKIMAGE) -l $(LINUX2_IMAGE_PATH) |\
	sed -n -e 's/Image Name:[ ]*\(.*\)/-n \1/p' -e 's/Load Address:/-a/p' -e 's/Entry Point:/-e/p'`; \
	$(MKIMAGE) -A $(MKIMAGE_ARCH) -O linux \
	-T kernel -C none $${MKIMAGE_ARGS} \
	-d $(KERNEL2_ARCH_PATH)/boot/zImage $(LINUX2_IMAGE_PATH);
endif
endif

# Compilation. We make sure the kernel gets rebuilt when the
# configuration has changed.
define LINUX2_BUILD_CMDS
	$(if $(BR2_LINUX2_KERNEL_USE_CUSTOM_DTS),
		cp $(call qstrip,$(BR2_LINUX2_KERNEL_CUSTOM_DTS_PATH)) $(KERNEL2_ARCH_PATH)/boot/dts/)
	$(TARGET_MAKE_ENV) $(MAKE) $(LINUX2_MAKE_FLAGS) -C $(@D) $(LINUX2_TARGET_NAME)
	@if grep -q "CONFIG_MODULES=y" $(@D)/.config; then 	\
		$(TARGET_MAKE_ENV) $(MAKE) $(LINUX2_MAKE_FLAGS) -C $(@D) modules ;	\
	fi
	$(LINUX2_BUILD_DTB)
	$(LINUX2_APPEND_DTB)
endef


ifeq ($(BR2_LINUX2_KERNEL_INSTALL_TARGET),y)
define LINUX2_INSTALL_KERNEL_IMAGE_TO_TARGET
	install -m 0644 -D $(LINUX2_IMAGE_PATH) $(LINUX2_TARGET_DIR)/boot/$(LINUX2_IMAGE_NAME)
	$(LINUX2_INSTALL_DTB_TARGET)
endef
endif

ifeq ($(BR2_LINUX2_KERNEL_INSTALL_SDCARD),y)
define LINUX2_INSTALL_KERNEL_IMAGE_TO_SDCARD
	install -m 0644 -D $(LINUX2_IMAGE_PATH) $(SDCARD_DIR)/$(BR2_LINUX2_KERNEL_INSTALL_SDCARD_NAME)
	$(LINUX2_INSTALL_DTB_SDCARD)
endef
endif


define LINUX2_INSTALL_HOST_TOOLS
	# Installing dtc (device tree compiler) as host tool, if selected
	if grep -q "CONFIG_DTC=y" $(@D)/.config; then 	\
		$(INSTALL) -D -m 0755 $(@D)/scripts/dtc/dtc $(HOST_DIR)/usr/bin/dtc ;	\
	fi
endef


define LINUX2_INSTALL_IMAGES_CMDS
	cp $(LINUX2_IMAGE_PATH) $(BINARIES2_DIR)
	$(LINUX2_INSTALL_DTB)
endef

define LINUX2_INSTALL_TARGET_CMDS
	$(LINUX2_INSTALL_KERNEL_IMAGE_TO_TARGET)
	$(LINUX2_INSTALL_KERNEL_IMAGE_TO_SDCARD)
	# Install modules and remove symbolic links pointing to build
	# directories, not relevant on the target
	@if grep -q "CONFIG_MODULES=y" $(@D)/.config; then 	\
		$(TARGET_MAKE_ENV) $(MAKE1) $(LINUX2_MAKE_FLAGS) -C $(@D) modules_install; \
		rm -f $(LINUX2_TARGET_DIR)/lib/modules/$(LINUX2_VERSION_PROBED)/build ;		\
		rm -f $(LINUX2_TARGET_DIR)/lib/modules/$(LINUX2_VERSION_PROBED)/source ;	\
	fi
	$(LINUX2_INSTALL_HOST_TOOLS)
endef

#include $(sort $(wildcard linux/linux-ext-*.mk))

$(eval $(generic-package))

ifeq ($(BR2_LINUX2_KERNEL),y)
linux2-menuconfig linux2-xconfig linux2-gconfig linux2-nconfig: linux2-configure
	$(MAKE) $(LINUX2_MAKE_FLAGS) -C $(LINUX2_DIR) \
		$(subst linux2-,,$@)
	rm -f $(LINUX2_DIR)/.stamp_{built,target_installed,images_installed}

linux2-savedefconfig: linux2-configure
	$(MAKE) $(LINUX2_MAKE_FLAGS) -C $(LINUX2_DIR) \
		$(subst linux2-,,$@)

ifeq ($(BR2_LINUX2_KERNEL_USE_CUSTOM_CONFIG),y)
linux2-update-config: linux2-configure $(LINUX2_DIR)/.config
	cp -f $(LINUX2_DIR)/.config $(BR2_LINUX2_KERNEL_CUSTOM_CONFIG_FILE)

linux2-update-defconfig: linux2-savedefconfig
	cp -f $(LINUX2_DIR)/defconfig $(BR2_LINUX2_KERNEL_CUSTOM_CONFIG_FILE)
else
linux2-update-config: ;
linux2-update-defconfig: ;
endif
endif

# Support for rebuilding the kernel after the cpio archive has
# been generated in $(BINARIES_DIR)/rootfs.cpio.
$(LINUX2_DIR)/.stamp_initramfs_rebuilt: $(LINUX2_DIR)/.stamp_target_installed $(LINUX2_DIR)/.stamp_images_installed $(BINARIES_DIR)/rootfs.cpio
	@$(call MESSAGE,"Rebuilding kernel with initramfs")
	# Build the kernel.
	$(TARGET_MAKE_ENV) $(MAKE) $(LINUX2_MAKE_FLAGS) -C $(@D) $(LINUX2_TARGET_NAME)
	$(LINUX2_APPEND_DTB)
	# Copy the kernel image to its final destination
	cp $(LINUX2_IMAGE_PATH) $(BINARIES2_DIR)
	# If there is a .ub file copy it to the final destination
	test ! -f $(LINUX2_IMAGE_PATH).ub || cp $(LINUX2_IMAGE_PATH).ub $(BINARIES2_DIR)
	$(Q)touch $@

# The initramfs building code must make sure this target gets called
# after it generated the initramfs list of files.
linux2-rebuild-with-initramfs: $(LINUX2_DIR)/.stamp_initramfs_rebuilt

# Checks to give errors that the user can understand
ifeq ($(filter source,$(MAKECMDGOALS)),)
ifeq ($(BR2_LINUX2_KERNEL_USE_DEFCONFIG),y)
ifeq ($(call qstrip,$(BR2_LINUX2_KERNEL_DEFCONFIG)),)
$(error No kernel defconfig name specified, check your BR2_LINUX2_KERNEL_DEFCONFIG setting)
endif
endif

ifeq ($(BR2_LINUX2_KERNEL_USE_CUSTOM_CONFIG),y)
ifeq ($(call qstrip,$(BR2_LINUX2_KERNEL_CUSTOM_CONFIG_FILE)),)
$(error No kernel configuration file specified, check your BR2_LINUX2_KERNEL_CUSTOM_CONFIG_FILE setting)
endif
endif

endif
