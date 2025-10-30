#include <AppKit/AppKit.h>
#include <dispatch/dispatch.h>

@interface DVTBuildVersion
@property(copy) NSString *name;
@end

@interface DVTToolsInfo
+ (instancetype)toolsInfo;
@property(copy) DVTBuildVersion *toolsBuildVersion;
@end

@interface NSApplication (DVTNSApplicationAdditions)
+ (void)adjustApplicationIconWithAppVersion:(NSString *)version;
@end

__attribute__((constructor)) static void init() {
	dispatch_async(dispatch_get_main_queue(), ^{
		[NSApplication adjustApplicationIconWithAppVersion:((DVTToolsInfo *)[NSClassFromString(@"DVTToolsInfo") toolsInfo]).toolsBuildVersion.name];
	});
}
