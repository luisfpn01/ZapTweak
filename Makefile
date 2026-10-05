ARCHS = arm64 arm64e
TARGET = iphone:clang:16.0:15.0
FINALPACKAGE = 1
DEBUG = 0

export THEOS_DEVICE_IP = localhost
export THEOS_DEVICE_PORT = 22

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ZapTweak
ZapTweak_FILES = Tweak.xm
ZapTweak_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
ZapTweak_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk

# Hook para instalador (opcional)
after-install::
	install.exec "killall -9 WhatsApp"
