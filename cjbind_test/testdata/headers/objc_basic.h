// Test basic ObjC class with instance and class methods
@interface MyObject : NSObject
- (void)doSomething;
- (int)addA:(int)a toB:(int)b;
+ (instancetype)sharedInstance;
@end
