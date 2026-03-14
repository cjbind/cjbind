// Test ObjC protocol with required and optional methods
@protocol MyProtocol
- (void)requiredMethod;
- (int)protocolMethodWithArg:(int)arg;
@optional
- (void)optionalMethod;
@end
