################################################################################
#
# open-isns
#
################################################################################

OPEN_ISNS_VERSION = 0.102
OPEN_ISNS_SITE = $(call github,open-iscsi,open-isns,v$(OPEN_ISNS_VERSION))
OPEN_ISNS_LICENSE = LGPL-2.1+
OPEN_ISNS_LICENSE_FILES = COPYING
OPEN_ISNS_INSTALL_STAGING = YES

OPEN_ISNS_CONF_OPTS = -Dslp=disabled

ifeq ($(BR2_PACKAGE_OPENSSL),y)
OPEN_ISNS_DEPENDENCIES += openssl
OPEN_ISNS_CONF_OPTS += -Dsecurity=enabled
else
OPEN_ISNS_CONF_OPTS += -Dsecurity=disabled
endif

define OPEN_ISNS_INSTALL_STAGING_CMDS
	$(INSTALL) -d -m 755 $(STAGING_DIR)/usr/{include/libisns,lib}
	$(INSTALL) -m 644 -t $(STAGING_DIR)/usr/include/libisns \
		$(@D)/{,build/}include/libisns/*.h
	cp -dpf $(if $(BR2_STATIC_LIBS),$(@D)/build/libisns.a,$(@D)/build/libisns.so{,.0}) \
		$(STAGING_DIR)/usr/lib/
	$(INSTALL) -D -m 644 {$(@D),$(STAGING_DIR)/usr/lib/pkgconfig}/libisns.pc
endef

define OPEN_ISNS_INSTALL_TARGET_CMDS
	$(OPEN_ISNS_INSTALL_LIBS)
	$(OPEN_ISNS_INSTALL_PROGS)
endef

ifeq ($(BR2_STATIC_LIBS),)
define OPEN_ISNS_INSTALL_LIBS
	$(INSTALL) -d -m 755 $(TARGET_DIR)/usr/lib
	cp -dpf $(@D)/build/libisns.so{,.0} $(TARGET_DIR)/usr/lib/
endef
endif

ifeq ($(BR2_PACKAGE_OPEN_ISNS_PROGS),y)
define OPEN_ISNS_INSTALL_PROGS
	$(INSTALL) -d -m 755 $(TARGET_DIR)/{etc/isns,usr/sbin}
	$(INSTALL) -d -m 700 $(TARGET_DIR)/var/lib/isns
	$(INSTALL) -m 555 -t $(TARGET_DIR)/usr/sbin \
		$(@D)/build/{isnsadm,isnsd,isnsdd}
	$(INSTALL) -m 644 -t $(TARGET_DIR)/etc/isns $(@D)/etc/*.conf
endef

define OPEN_ISNS_INSTALL_INIT_SYSTEMD
	$(INSTALL) -d -m 755 $(TARGET_DIR)/usr/lib/systemd/system
	$(INSTALL) -m 644 -t $(TARGET_DIR)/usr/lib/systemd/system \
		$(@D)/isnsd.{service,socket}
endef
endif

$(eval $(meson-package))
