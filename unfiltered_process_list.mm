#import "swizzler/swizzler.h"
#import <Foundation/Foundation.h>

static Swizzler<BOOL, id> XRFeatureFlag_unfilteredProcessList {
	objc_getMetaClass("XRFeatureFlag"), @selector(unfilteredProcessList), [](auto self) {
		return YES;
	}
};

__attribute__((constructor))
static void init() {
	unsetenv("DYLD_INSERT_LIBRARIES");
}
