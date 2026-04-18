TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e

# 【核心修改 1】强制静态链接 Substrate
MS_STRICT = 1
# 【核心修改 2】关闭调试，确保 FINAL 模式
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TaobaoCleanShare
TaobaoCleanShare_FILES = Tweak.x
TaobaoCleanShare_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
