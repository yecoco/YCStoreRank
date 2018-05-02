export TARGET_CODESIGN_FLAGS="-SEntitlements.plist"
export ARCHS = armv7 arm64
export TARGET=iphone:10.3:7.0
THEOS_DEVICE_IP=10.0.1.80
ARCHS = arm64
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AppRank
AppRank_FILES = Tweak.xm RankAppModel.m AppleAccountModel.m RankManager.m SBAutoManager.m LotoDeviceManager.m RateModel.m
AppRank_FRAMEWORKS = Foundation UIKit CoreGraphics CoreFoundation
AppRank_PRIVATE_FRAMEWORKS = MobileCoreServices

include $(THEOS_MAKE_PATH)/tweak.mk
after-install::
	install.exec "killall -9 AppStore & killall -9 itunesstored & killall -9 SpringBoard & killall -9 itunescloudd & killall -9 storebookkeeperd & killall -9 akd"
