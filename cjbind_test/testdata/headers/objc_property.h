// Test ObjC properties with various attributes
@interface PropClass : NSObject
@property (nonatomic, readonly) int count;
@property (nonatomic, assign) float value;
@property (nonatomic, copy, getter=isEnabled) BOOL enabled;
@end
