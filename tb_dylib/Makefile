# 明确指定目标为 iOS
TARGET := iphone:clang:latest:14.0

# 明确指定架构（必须包含 arm64，建议带上 arm64e）
ARCHS = arm64 arm64e

# 确保编译为最终发布版本，移除多余调试符号
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TaobaoCleanShare
TaobaoCleanShare_FILES = Tweak.x
TaobaoCleanShare_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
