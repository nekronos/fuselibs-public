#import "CanvasViewGroup.h"

@implementation CanvasViewGroup

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	if (self.onDrawCallback != NULL)
		self.onDrawCallback(context);
}

@end