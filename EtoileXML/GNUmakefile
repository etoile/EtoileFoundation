include $(GNUSTEP_MAKEFILES)/common.make

# We reset PROJECT_DIR provided by etoile.make to match the subproject since 
# etoile.make doesn't detect and handle such embedded project
PROJECT_DIR = $(CURDIR)

FRAMEWORK_NAME = EtoileXML
DOCUMENT_NAME = $(FRAMEWORK_NAME)

# -lm for FreeBSD at least
LIBRARIES_DEPEND_UPON += -lm $(FND_LIBS) $(OBJC_LIBS) $(SYSTEM_LIBS)

$(FRAMEWORK_NAME)_OBJCFLAGS += -std=c99

$(FRAMEWORK_NAME)_OBJC_FILES = \
	ETXMLNode.m \
	ETXMLDeclaration.m \
	ETXMLNullHandler.m \
	ETXMLParser.m \
	ETXMLXHTML-IMParser.m \
	ETXMLString.m

$(FRAMEWORK_NAME)_HEADER_FILES = \
	ETXMLNode.h \
	ETXMLDeclaration.h \
	ETXMLParser.h \
	ETXMLString.h \
	ETXMLNullHandler.h \
	ETXMLXHTML-IMParser.h \
	ETXMLParserDelegate.h \
	NSAttributedString+HTML.h

$(DOCUMENT_NAME)_AGSDOC_FILES = $($(FRAMEWORK_NAME)_HEADER_FILES)

ifneq ($(FOUNDATION_LIB), apple)
# Do not build document for Cocoa.
include $(GNUSTEP_MAKEFILES)/documentation.make
endif
-include ../../../etoile.make
include $(GNUSTEP_MAKEFILES)/framework.make
