TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e

# 【关键：静态链接 Hook 引擎】
DEBUG = 0
FINALPACKAGE = 1
# 这一行告诉 Theos 不要寻找系统的 Substrate
# 如果你的 Theos 环境支持，建议直接使用以下配置
TaobaoCleanShare_LDFLAGS = -undefined dynamic_lookup

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TaobaoCleanShare
TaobaoCleanShare_FILES = Tweak.x
TaobaoCleanShare_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
