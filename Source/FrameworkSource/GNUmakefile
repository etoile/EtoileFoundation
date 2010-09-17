include $(GNUSTEP_MAKEFILES)/common.make

FRAMEWORK_NAME = UnitKit
# We declare PROJECT_NAME to export the dependencies (see etoile.make)
PROJECT_NAME = $(FRAMEWORK_NAME)
UnitKit_VERSION = 1.3

UnitKit_OBJCFLAGS = -std=c99 
UnitKit_LIBRARIES_DEPEND_UPON = $(FND_LIBS) $(OBJC_LIBS) $(SYSTEM_LIBS)

UnitKit_HEADER_FILES = UKRunner.h UKTest.h UKTestHandler.h UKTask.h UnitKit.h

UnitKit_OBJC_FILES = UKRunner.m UKTestHandler.m UKTask.m

UnitKit_LOCALIZED_RESOURCE_FILES = UKRunner.strings UKTestHandler.strings
UnitKit_LANGUAGES = English

include $(GNUSTEP_MAKEFILES)/framework.make
-include ../../../../etoile.make
