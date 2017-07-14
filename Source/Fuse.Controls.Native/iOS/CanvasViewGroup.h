#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@interface CanvasViewGroup : UIView

@property (copy) void (^onDrawCallback)(CGContextRef);

@end
