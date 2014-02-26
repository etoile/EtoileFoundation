include $(GNUSTEP_MAKEFILES)/common.make

FRAMEWORK_NAME = UnitKit
# We declare PROJECT_NAME to export the dependencies (see etoile.make)
PROJECT_NAME = $(FRAMEWORK_NAME)
UnitKit_VERSION = 1.3

UnitKit_OBJCFLAGS = -std=c99 
UnitKit_LIBRARIES_DEPEND_UPON = $(FND_LIBS) $(OBJC_LIBS) $(SYSTEM_LIBS)

UnitKit_HEADER_FILES = UKRunner.h UKTest.h UKTestHandler.h UnitKit.h

UnitKit_OBJC_FILES = UKRunner.m UKTestHandler.m

UnitKit_LOCALIZED_RESOURCE_FILES = UKTestHandler.strings
UnitKit_LANGUAGES = English

UnitKitDoc_DOC_FILES = UKTest.h UKTestHandler.h UKRunner.h

UnitKitDoc_DOCUMENTATION_DIR = ../Documentation
UnitKitDoc_MENU_TEMPLATE_FILE = ../Documentation/Templates/menu.html

UnitKitDoc_README_FILE = ../README.md
UnitKitDoc_INSTALL_FILES = ../INSTALL.Cocoa.md ../INSTALL.GNUstep.md
UnitKitDoc_NEWS_FILE = ../NEWS.md

include $(GNUSTEP_MAKEFILES)/framework.make
-include ../../../etoile.make
-include ../../../documentation.make
