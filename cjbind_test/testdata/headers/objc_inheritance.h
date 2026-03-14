@interface Base : NSObject
- (void)baseMethod;
@end

@interface Child : Base
- (void)childMethod;
@end

@interface GrandChild : Child
- (void)grandChildMethod;
@end
