#
#	GNUmakefile
#
#	Makefile for EtoileExtensionsKit
#
#	Copyright (C) 2005 Quentin Mathe <qmathe@club-internet.fr>
#
#	This Makefile is free software; you can redistribute it and/or
#	modify it under the terms of the GNU General Public License
#	as published by the Free Software Foundation; either version 2
#	of the License, or (at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
#	See the GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with this program; if not, write to:
#
#		Free Software Foundation, Inc.
#		59 Temple Place - Suite 330
#		Boston, MA  02111-1307, USA
#

include $(GNUSTEP_MAKEFILES)/common.make

ADDITIONAL_OBJCFLAGS = -Wno-import

ADDITIONAL_INCLUDE_DIRS = -I../Headers

#
# Main application
#
LIBRARY_NAME = libEtoileExtensions	
VERSION = 0.1

FRAMEWORKS = #TrackerKit

#
# Resource files
#
libEtoileExtensions_MAIN_MODEL_FILE=

libEtoileExtensions_RESOURCE_FILES=

libEtoileExtensions_LOCALIZED_RESOURCE_FILES=

#
# Languages we're localized for
#
libEtoileExtensions_LANGUAGES= \
	English
	
#
# Class files
#
libEtoileExtensions_OBJC_FILES= \
	NSBezierPathCappedBoxes.m \
	NSFileManager+NameForTempFile.m \
	NSImage+NiceScaling.m \
	UKDistributedView.m \
	UKFinderIconCell.m \
	UKMainThreadProxy.m \
	UKNibOwner.m \
	UKPushbackMessenger.m \
	UKKQueue.m \
	UKThreadMessenger.m

libEtoileExtensions_HEADER_FILES = \
	Cocoa/Cocoa.h \
	NSBezierPathCappedBoxes.h \
	NSFileManager+NameForTempFile.h \
	NSImage+NiceScaling.h \
	UKDistributedView.h \
	UKFinderIconCell.h \
	UKMainThreadProxy.h \
	UKNibOwner.h \
	UKPushbackMessenger.h \
	UKKQueue.h \
	UKThreadMessenger.h

#
# Header files
#
libEtoileExtensions_HEADER_FILES_DIR = ../Headers

libEtoileExtensions_HEADER_FILES_INSTALL_DIR = /EtoileExtensions

libEtoileExtensions_HEADER_FILES = \
	NSBezierPathCappedBoxes.h \
	NSFileManager+NameForTempFile.h \
	NSImage+NiceScaling.h \
	UKDistributedView.h \
	UKFinderIconCell.h \
	UKMainThreadProxy.h \
	UKNibOwner.h \
	UKPushbackMessenger.h \
	UKKQueue.h \
	UKThreadMessenger.h

#
# C files
#
libEtoileExtensions_C_FILES=

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/library.make

-include GNUmakefile.postamble
