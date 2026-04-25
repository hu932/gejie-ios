export THEOS ?= /opt/theos
export TARGET := iphone:clang:latest:14.0
export ARCHS = arm64

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = GeJie

GeJie_FILES = \
    Sources/main.mm \
    Sources/AppDelegate.mm \
    Sources/APIClient.mm \
    Sources/LoginViewController.mm \
    Sources/TaskViewController.mm \
    Sources/FloatWindowManager.mm \
    Sources/FloatBubbleView.mm \
    Sources/TaskDetailViewController.mm \
    Sources/GJTheme.mm

GeJie_FRAMEWORKS = UIKit Foundation CoreGraphics SystemConfiguration
GeJie_PRIVATE_FRAMEWORKS = AppSupport
GeJie_CFLAGS = -fobjc-arc -IHeaders -Wno-error
GeJie_LDFLAGS = -lz

GeJie_BUNDLE_ID = com.gejie.app
GeJie_DISPLAY_NAME = 格界

include $(THEOS)/makefiles/application.mk

after-install::
	install.exec "uicache -p /Applications/GeJie.app"
