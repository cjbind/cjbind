typedef void (^CompletionHandler)(BOOL success);

@interface AsyncOp : NSObject
- (void)executeWithCompletion:(CompletionHandler)handler;
- (void)performBlock:(void (^)(int result))block;
@end
