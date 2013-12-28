#import <Foundation/Foundation.h>
#import "NGBManagedAccount.h"

@interface NGBAccount : NSObject <NGBManagedAccount>

@property (copy, nonatomic) NSString* username;
@property (copy, nonatomic) NSString* identifier;

@property (copy, nonatomic) NSString* password;

@property (copy, nonatomic) NSURL* thumbnailUrl;
@property (copy, nonatomic) NSDate* lastLogin;
@property (nonatomic, getter = isSynchronizable) BOOL synchronizable;

@property (weak, nonatomic) NGBAccountStore* accountStore;


@end
