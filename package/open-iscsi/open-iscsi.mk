################################################################################
#
# open-iscsi
#
################################################################################

OPEN_ISCSI_VERSION = f633c09a7a2976069b1dfd98d9979349e92c38b5
OPEN_ISCSI_SITE = $(call github,open-iscsi,open-iscsi,$(OPEN_ISCSI_VERSION))
OPEN_ISCSI_LICENSE = GPL-2.0+
OPEN_ISCSI_LICENSE_FILES = COPYING
OPEN_ISCSI_DEPENDENCIES = kmod openssl util-linux-libs

OPEN_ISCSI_CONF_OPTS = -Ddbroot=/var/lib/iscsi

ifeq ($(BR2_PACKAGE_SYSTEMD),y)
OPEN_ISCSI_DEPENDENCIES += systemd
OPEN_ISCSI_CONF_OPTS += -Dno_systemd=false
else
OPEN_ISCSI_CONF_OPTS += -Dno_systemd=true
endif

ifeq ($(BR2_PACKAGE_OPEN_ISNS),)
define OPEN_ISCSI_DISABLE_ISNS
	$(SED) "/'isns'/s/^/#/" $(@D)/meson.build
	$(SED) "/'iscsid'/s/^/#/" $(@D)/usr/meson.build
	$(SED) "/'iscsiadm'/s/^/#/" $(@D)/usr/meson.build
endef
OPEN_ISCSI_PRE_CONFIGURE_HOOKS += OPEN_ISCSI_DISABLE_ISNS
else
OPEN_ISCSI_DEPENDENCIES += open-isns
endif

define OPEN_ISCSI_INSTALL_TARGET_CMDS
	$(INSTALL) -d -m 755 $(TARGET_DIR)/usr/lib
	cp -dpf $(@D)/build/libopeniscsiusr.so{,.0,.0.2.0} \
		$(TARGET_DIR)/usr/lib/
	$(OPEN_ISCSI_INSTALL_ISCSID)
	$(OPEN_ISCSI_INSTALL_ISCSISTART)
endef

ifeq ($(BR2_PACKAGE_OPEN_ISCSI_ISCSID),y)
define OPEN_ISCSI_INSTALL_ISCSID
	$(INSTALL) -d -m 755 $(TARGET_DIR)/usr/sbin
	$(INSTALL) -m 755 -t $(TARGET_DIR)/usr/sbin \
		$(@D)/build/{iscsi-iname,iscsiadm,iscsid}
	$(INSTALL) -D -m 644 {$(@D)/etc,$(TARGET_DIR)/etc/iscsi}/iscsid.conf
endef

define OPEN_ISCSI_INSTALL_INIT_SYSTEMD
	$(INSTALL) -d -m 755 $(TARGET_DIR)/usr/lib/systemd/system
	$(INSTALL) -m 644 -t $(TARGET_DIR)/usr/lib/systemd/system \
		$(@D)/build/{iscsi,iscsi-init,iscsid}.service \
		$(@D)/etc/systemd/iscsid.socket
endef
endif

ifeq ($(BR2_PACKAGE_OPEN_ISCSI_ISCSISTART),y)
define OPEN_ISCSI_INSTALL_ISCSISTART
	$(INSTALL) -D -m 755 {$(@D)/build,$(TARGET_DIR)/usr/sbin}/iscsistart
endef
endif

define OPEN_ISCSI_LINUX_CONFIG_FIXUPS
	$(call KCONFIG_ENABLE_OPT,CONFIG_SCSI_LOWLEVEL)
	$(call KCONFIG_ENABLE_OPT,CONFIG_ISCSI_TCP)
endef

$(eval $(meson-package))
