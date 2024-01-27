#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>

@interface DVTLogAspect
+(instancetype)logAspectWithName:(NSString *)name;
@property NSUInteger logLevel;
@end

static void image_loaded(const struct mach_header *header, intptr_t slide) {
	for (NSString *name in @[@"DTDKRemoteDeviceConnection", @"DTDeviceKit", @"iPhoneConnect"]) {
		DVTLogAspect *log = [NSClassFromString(@"DVTLogAspect") logAspectWithName:name];
		log.logLevel = 0;
	}
}

__attribute__((constructor)) static void init() {
	_dyld_register_func_for_add_image(image_loaded);
}
