PACKAGE_NAME = EtoileFoundation

include $(GNUSTEP_MAKEFILES)/common.make

SUBPROJECTS = EtoileThread

#
# kqueue support check
#
ifneq ($(findstring freebsd, $(GNUSTEP_HOST_OS)),)

    kqueue_supported ?= yes

endif

ifneq ($(findstring darwin, $(GNUSTEP_HOST_OS)),)

    kqueue_supported ?= yes

endif

ifneq ($(findstring netbsd, $(GNUSTEP_HOST_OS)),)

    kqueue_supported ?= yes

endif

kqueue_supported ?= no

FRAMEWORK_NAME = EtoileFoundation
VERSION = 0.1

# -lm for FreeBSD at least
LIBRARIES_DEPEND_UPON += -lm -lEtoileThread \
	$(FND_LIBS) $(OBJC_LIBS) $(SYSTEM_LIBS)

EtoileFoundation_SUBPROJECTS = Source

EtoileFoundation_HEADER_FILES_DIR = Headers

EtoileFoundation_HEADER_FILES = \
	EtoileFoundation.h \
	EtoileCompatibility.h \
	ETCArray.h \
	Macros.h \
	NSArray+map.h \
	NSObject+Mixins.h \
	NSFileManager+TempFile.h \
	UKMainThreadProxy.h \
	UKPluginsRegistry.h \
	UKPushbackMessenger.h \
	UKThreadMessenger.h \
	UKFileWatcher.h \
	OSBundleExtensionLoader.h \
	ETCollection.h \
	ETFilter.h \
	ETObjectChain.h \
	ETObjectRegistry.h \
	ETPropertyValueCoding.h \
	ETPrototype.h \
	ETRendering.h \
	ETTransform.h \
	NSIndexPath+Etoile.h \
	NSIndexSet+Etoile.h \
	NSObject+Etoile.h \
	NSObject+Model.h \
	NSString+Etoile.h \
	NSURL+Etoile.h

ifeq ($(kqueue_supported), yes)

EtoileFoundation_HEADER_FILES += \
        UKKQueue.h

endif

include $(GNUSTEP_MAKEFILES)/aggregate.make
-include ../../etoile.make
-include etoile.make
include $(GNUSTEP_MAKEFILES)/framework.make
