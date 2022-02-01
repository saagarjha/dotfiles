#import "swizzler/swizzler.h"
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

auto scaleFactorOverride = []([[maybe_unused]] auto self) {
	return 1.0;
};

static Swizzler<CGFloat, id> UINSSceneView_sceneToSceneViewScaleFactor {
	NSClassFromString(@"UINSSceneView"), @selector(sceneToSceneViewScaleFactor), scaleFactorOverride
};

static Swizzler<CGFloat, id> UINSSceneView_fixedSceneToSceneViewScaleFactor {
	NSClassFromString(@"UINSSceneView"), @selector(fixedSceneToSceneViewScaleFactor), scaleFactorOverride
};

static Swizzler<CGFloat, id> UINSSceneContainerView_sceneToSceneViewScaleForLayout {
	NSClassFromString(@"UINSSceneContainerView"), @selector(sceneToSceneViewScaleForLayout), scaleFactorOverride
};
