EtoileFoundation
================

Maintainers
: Quentin Mathe <quentin.mathe@gmail.com>, David Chisnall
Authors
: David Chisnall, Quentin Mathe, Uli Kusterer, Yen-Ju Chen, Eric Wasylishen
License
: Modified BSD License
Version
: 0.6

[![Build Status](https://travis-ci.org/etoile/EtoileFoundation.png?branch=master)](https://travis-ci.org/etoile/EtoileFoundation)

EtoileFoundation is the core framework for all Etoile projects, providing 
numerous convenience methods on top of the OpenStep foundation and significantly 
better support for reflection. Here is a summary of some the interesting features:

- mirror-based reflection (work-in-progress)
- mixins and traits
- prototypes
- double-dispatch
- collection class protocol and additions
- UUID
- convenient macros such as FOREACH
- dynamic C array
- metamodel
- UTI
- generic history model
- socket
- stack trace recording

**Note:** Restartable exceptions are not available in this release.

Two sub-frameworks are bundled with it: 

- *EtoileThread* which allows objects to transparently be run in a separate thread. 
- *EtoileXML* which is a light-weight and tolerant XML parsing framework whose 
main ability is to handle truncated and not well-formed XML documents. For 
example, with XML streams used by the XMPP protocol, the XML is received in 
fragments.

**Warning:** EtoileThread is not available in this release.


Build and Install
-----------------

Read INSTALL.Cocoa or INSTALL.GNUstep documents.


Mac OS X and iOS support
------------------------

EtoileFoundation is supported on Mac OS X (10.6 or higher) and iOS (5 or higher), 
minus the parts that only work with the GNUstep runtime (prototypes, restartable 
exceptions and some introspection stuff).

An Xcode project is bundled to build both EtoileFoundation and EtoileXML on 
Mac OS X, and EtoileFoundation on iOS. 

**Note:** EtoileXML is unsupported on iOS presently. For now, ETSocket and 
NSData(ETHash) are also missing  on iOS, because the system doesn't include the 
OpenSSL library.

NSObject+Prototypes.m, NSBlocks.m and CArray.m are not compiled on Mac OS X.

ETSocket.m, ETStackTraceRecorder.m, NSData+Hash.m, NSObject+Prototypes.m, 
NSBlocks.m and CArray.m are not compiled on iOS.

**Warning:** Xcode 4.6 or higher is required to build these projects.


Developer Notes
===============

If you want to use classes from EtoileThread or EtoileXML, their headers must be 
imported explicitly and EtoileThread or EtoileXML must be linked explicitly. 
EtoileFoundation doesn't link them.

Unlike EtoileThread which has no dependency, EtoileXML depends on 
EtoileFoundation and links it.


EtoileThread (not available)
----------------------------

See the README in the EtoileThread subdirectory.


EtoileXML
---------

See the README in the EtoileXML subdirectory.
