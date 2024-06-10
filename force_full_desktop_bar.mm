#import "swizzler/swizzler.h"
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#include <cstdlib>

#define dockSwipeGesturePhase 123
#define dockSwipeGestureMotion 134
#define dockSwipeEvent 30
#define kIOHIDGestureMotionVerticalY 2
#define kIOHIDGestureMotionDoubleTap 6

static int mouseOverrideCount;

static Swizzler<void, id, long long> Dock_WVExpose_changeMode_ {
	NSClassFromString(@"WVExpose"), @selector(changeMode:), [](auto self, auto mode) {
		if (mode == 1) {
			mouseOverrideCount = 1;
		}
		Dock_WVExpose_changeMode_(self, mode);
	}
};

static auto isStartOfTrackpadSwipeUpEvent(CGEventType type, CGGesturePhase phase, uint64_t direction) {
	return type == dockSwipeEvent && phase == kCGGesturePhaseBegan && direction == kIOHIDGestureMotionVerticalY;
}

static auto isDoubleTapEvent(CGEventType type, CGGesturePhase phase, uint64_t direction) {
	return type == dockSwipeEvent && phase == kCGGesturePhaseNone && direction == kIOHIDGestureMotionDoubleTap;
}

static Swizzler<void, id, CGEventRef, CGEventType> DOCKGestures_handleEvent_type_ {
	NSClassFromString(@"DOCKGestures"), @selector(handleEvent:type:), [](auto self, auto event, auto type) {
		auto phase = (CGGesturePhase)CGEventGetIntegerValueField(event, static_cast<CGEventField>(dockSwipeGestureMotion));
		auto direction = (CGGesturePhase)CGEventGetIntegerValueField(event, static_cast<CGEventField>(dockSwipeGesturePhase));

		if (isStartOfTrackpadSwipeUpEvent(type, phase, direction) || isDoubleTapEvent(type, phase, direction)) {
			mouseOverrideCount = 2;
		}
		DOCKGestures_handleEvent_type_(self, event, type);
	}
};

extern "C" {
CGPoint CGSCurrentInputPointerPosition(void);
};

static CGPoint moveToTopOfScreen(CGPoint p) {
	CGDirectDisplayID displayContainingCursor;
	uint32_t matchingDisplayCount = 0;

	CGGetDisplaysWithPoint(p, 1, &displayContainingCursor, &matchingDisplayCount);

	if (matchingDisplayCount >= 1) {
		CGRect rect = CGDisplayBounds(displayContainingCursor);
		p.y = rect.origin.y + 1;
		return p;
	} else {
		NSLog(@"forceFullDesktopBar error: could not determine which screen contains mouse coordinates (%f %f)", p.x, p.y);
		return p;
	}
}

static CGPoint overriden_CGSCurrentInputPointerPosition() {
	CGPoint result = CGSCurrentInputPointerPosition();

	if (mouseOverrideCount > 0) {
		mouseOverrideCount -= 1;
		result = moveToTopOfScreen(result);
	}

	return result;
}

__attribute__((used, section("__DATA,__interpose"))) static struct {
	CGPoint (*overridden_CGSCurrentInputPointerPosition)();
	CGPoint (*CGSCurrentInputPointerPosition)();
} CGSCurrentInputPointerPosition_overrides[] = {
    {overriden_CGSCurrentInputPointerPosition, CGSCurrentInputPointerPosition},
};

__attribute__((constructor)) static void init() {
	unsetenv("DYLD_INSERT_LIBRARIES");
}
