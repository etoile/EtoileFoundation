include $(GNUSTEP_MAKEFILES)/common.make

LIBRARY_NAME = UnitKit

UnitKit_LIBRARIES_DEPEND_UPON = -lgnustep-base -lgnustep-gui

UnitKit_OBJC_FILES = UKRunner.m UKTestHandler.m UKTask.m
UnitKit_HEADER_FILES= UKRunner.h UKTest.h UKTestHandler.h UKTask.h UnitKit.h
UnitKit_HEADER_FILES_INSTALL_DIR = /UnitKit
UnitKit_LOCALIZED_RESOURCE_FILES = UKRunner.strings UKTestHandler.strings
UnitKit_LANGUAGES = English

ADDITIONAL_OBJCFLAGS= -Wall -Wno-import

include $(GNUSTEP_MAKEFILES)/library.make


