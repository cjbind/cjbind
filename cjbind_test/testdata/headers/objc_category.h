@interface NSString : NSObject
- (int)length;
@end

@interface NSString (Utilities)
- (BOOL)containsSubstring:(NSString *)str;
@end
