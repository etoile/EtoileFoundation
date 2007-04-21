
#import "OSBundleExtensionLoader.h"

#import <Foundation/Foundation.h>

@interface OSBundleExtensionLoader (Private)

- (NSSearchPathDomainMask) determineDomainsMaskWithDefaultsKey: (NSString *)
  defaultsKey;

- (void) loadBundlesOfType: (NSString *) fileType
                 protocols: (NSArray *) protocols
               inDirectory: (NSString *) dir
                 intoArray: (NSMutableArray *) array;

- (NSBundle *) validateBundleAtPath: (NSString *) bundlePath
                   againstProtocols: (NSArray *) protocols;

@end

@implementation OSBundleExtensionLoader (Private)

- (NSSearchPathDomainMask) determineDomainsMaskWithDefaultsKey: (NSString *)
  defaultsKey
{
        NSUserDefaults * df;
        NSSearchPathDomainMask mask;

        df = [NSUserDefaults standardUserDefaults];
        mask = NSAllDomainsMask|OSMainBundleDomainMask;

        if (defaultsKey == nil)
                defaultsKey = @"OSBundleExtensionLoader";

        if ([df boolForKey: [defaultsKey stringByAppendingString:
          @"-ExcludeLoadingFromSystem"]])
                mask ^= NSSystemDomainMask;
        if ([df boolForKey: [defaultsKey stringByAppendingString:
          @"-ExcludeLoadingFromLocal"]])
                mask ^= NSLocalDomainMask;
        if ([df boolForKey: [defaultsKey stringByAppendingString:
          @"-ExcludeLoadingFromNetwork"]])
                mask ^= NSNetworkDomainMask;
        if ([df boolForKey: [defaultsKey stringByAppendingString:
          @"-ExcludeLoadingFromUser"]])
                mask ^= NSUserDomainMask;
        if ([df boolForKey: [defaultsKey stringByAppendingString:
          @"-ExcludeLoadingFromMainBundle"]])
                mask ^= OSMainBundleDomainMask;

        return mask;
}

- (void) loadBundlesOfType: (NSString *) fileType
                 protocols: (NSArray *) protocols
               inDirectory: (NSString *) dir
                 intoArray: (NSMutableArray *) array
{
        NSEnumerator * e;
        NSString * filename;

        e = [[[NSFileManager defaultManager]
          directoryContentsAtPath: dir] objectEnumerator];

        while ((filename = [e nextObject]) != nil) {
                NSBundle * bundle;

                if (fileType != nil && ![[[filename pathExtension]
                  lowercaseString] isEqualToString: fileType])
                        continue;

                filename = [dir stringByAppendingPathComponent: filename];
                if ((bundle = [self validateBundleAtPath: filename
                                        againstProtocols: protocols]) != nil)
                        [array addObject: bundle];
        }
}

- (NSBundle *) validateBundleAtPath: (NSString *) bundlePath
                   againstProtocols: (NSArray *) protocols
{
        NSBundle * bundle;

        bundle = [NSBundle bundleWithPath: bundlePath];

        if (bundle != nil && protocols != nil) {
                Protocol * proto;
                NSEnumerator * e;
                Class principalClass;

                principalClass = [bundle principalClass];
                if (principalClass == Nil)
                        return nil;

                e = [protocols objectEnumerator];
                while ((proto = [e nextObject]) != nil) {
                        if (![principalClass conformsToProtocol: proto])
                                return nil;
                }
        }

        return bundle;
}

@end

@implementation OSBundleExtensionLoader

static OSBundleExtensionLoader * shared = nil;

+ shared
{
        if (shared == nil)
                shared = [self new];

        return shared;
}

- (NSArray *) extensionsForBundleType: (NSString *) bundleFileExt
               principalClassProtocol: (Protocol *) protocol
                   bundleSubdirectory: (NSString *) subDirName
                            inDomains: (NSSearchPathDomainMask) domainMask
                 domainDetectionByKey: (NSString *) defaultsKey
{
        NSArray * protocolArray = nil;

        if (protocol != nil)
                protocolArray = [NSArray arrayWithObject: protocol];

        return [self extensionsForBundleType: bundleFileExt
                     principalClassProtocols: protocolArray
                          bundleSubdirectory: subDirName
                                   inDomains: domainMask
                        domainDetectionByKey: defaultsKey];
}

- (NSArray *) extensionsForBundleType: (NSString *) bundleFileExt
              principalClassProtocols: (NSArray *) protocols
                   bundleSubdirectory: (NSString *) subDirName
                            inDomains: (NSSearchPathDomainMask) domainMask
                 domainDetectionByKey: (NSString *) defaultsKey
{
        NSEnumerator * e;
        NSString * libDir;
        NSMutableArray * bundles;

        if (domainMask == 0)
                domainMask = [self determineDomainsMaskWithDefaultsKey:
                  defaultsKey];

        bundles = [NSMutableArray array];
        bundleFileExt = [bundleFileExt lowercaseString];

        e = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
          domainMask, YES) objectEnumerator];
        while ((libDir = [e nextObject]) != nil) {
                NSString * bundleSubdirectoryPath;

                if (subDirName) {
                        bundleSubdirectoryPath = [libDir
                          stringByAppendingPathComponent: [@"Bundles"
                          stringByAppendingPathComponent: subDirName]];
                        libDir = [libDir stringByAppendingPathComponent:
                          subDirName];
                } else {
                        bundleSubdirectoryPath = nil;
                        libDir = [libDir stringByAppendingPathComponent:
                          @"Bundles"];
                }

                if (bundleSubdirectoryPath != nil)
                        [self loadBundlesOfType: bundleFileExt
                                      protocols: protocols
                                    inDirectory: bundleSubdirectoryPath
                                      intoArray: bundles];

                [self loadBundlesOfType: bundleFileExt
                              protocols: protocols
                            inDirectory: libDir
                              intoArray: bundles];
        }

#ifdef GNUSTEP
        e = [NSSearchPathForDirectoriesInDomains(GSApplicationSupportDirectory,
          domainMask, YES) objectEnumerator];
        while ((libDir = [e nextObject]) != nil) {
                if (subDirName)
                        libDir = [libDir stringByAppendingPathComponent:
                          subDirName];

                [self loadBundlesOfType: bundleFileExt
                              protocols: protocols
                            inDirectory: libDir
                              intoArray: bundles];
        }
#endif

        if (domainMask & OSMainBundleDomainMask) {
                NSString * resource;

                e = [[[NSBundle mainBundle]
                  pathsForResourcesOfType: bundleFileExt
                              inDirectory: nil]
                  objectEnumerator];
                while ((resource = [e nextObject]) != nil) {
                        NSBundle * bundle;

                        if (bundleFileExt != nil &&
                          ![[[resource pathExtension] lowercaseString]
                          isEqualToString: bundleFileExt])
                                continue;

                        bundle = [self validateBundleAtPath: resource
                                           againstProtocols: protocols];
                        if (bundle != nil)
                                [bundles addObject: bundle];
                }
        }

        return [bundles copy];
}

@end
