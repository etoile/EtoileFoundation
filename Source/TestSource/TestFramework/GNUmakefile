include $(GNUSTEP_MAKEFILES)/common.make

FRAMEWORK_NAME = TestFramework
# We declare PROJECT_NAME to export the dependencies (see etoile.make)
PROJECT_NAME = $(FRAMEWORK_NAME)

$(FRAMEWORK_NAME)_LIBRARIES_DEPEND_UPON = -lUnitKit $(FND_LIBS)

$(FRAMEWORK_NAME)_HEADER_FILES = TestClass.h

$(FRAMEWORK_NAME)_OBJC_FILES = TestClass.m

include $(GNUSTEP_MAKEFILES)/framework.make
-include ../../../../../etoile.make
