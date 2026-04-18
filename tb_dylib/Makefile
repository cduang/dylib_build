TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = Taobao4iPhone

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TaobaoCleanShare

TaobaoCleanShare_FILES = Tweak.x
TaobaoCleanShare_CFLAGS = -fobjc-arc
TaobaoCleanShare_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
