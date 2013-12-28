#import <Foundation/Foundation.h>

@class NGBAccountStore;

@protocol NGBManagedAccount <NSCoding, NSObject>

- (NSString*)identifier;
- (void)setIdentifier:(NSString *)identifier;

- (BOOL)isSynchronizable;

@optional

@property (weak, nonatomic) NGBAccountStore* accountStore;

@end
