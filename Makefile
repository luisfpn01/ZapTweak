ARCHS = arm64 arm64e
TARGET = iphone:clang:16.0:15.0
FINALPACKAGE = 1
DEBUG = 0

# No container Theos, o SDK está em $THEOS/sdk
# Não precisa setar THEOS_DEVICE_IP para build only

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ZapTweak
ZapTweak_FILES = Tweak.xm
ZapTweak_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
ZapTweak_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WhatsApp"
