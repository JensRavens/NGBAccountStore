#import <Foundation/Foundation.h>
#import "NGBManagedAccount.h"

/**
 A convinience class that implements the NGBManagedAccount protocol. You can use this class directly to have a ready to go account class or roll your own by implementing the NGBManagedAccount protocol in your own class.
 */
@interface NGBAccount : NSObject <NGBManagedAccount>

/**
 The username. Sometimes this might also be your identifier.
 */
@property (copy, nonatomic) NSString* username;

/**
 A unique user identifier. This might be a server ID.
 */
@property (copy, nonatomic) NSString* identifier;

/**
 The password for this account. Setting the password will fail if the account is not yet added to an accountstore (and therefore accountStore is nil).
 */
@property (copy, nonatomic) NSString* password;

/**
 An url to an avatar image.
 */
@property (copy, nonatomic) NSURL* thumbnailUrl;

/**
 The last login date. May be used for sorting of accounts.
 */
@property (copy, nonatomic) NSDate* lastLogin;

/**
 A setting if this account should be saved in iCloud. If you return yes, this account will be accessible on alle connected devices.
 
 @warning If you delete an account that is synchronized, it will be deleted on all iCloud connected devices!
 */
@property (nonatomic, getter = isSynchronizable) BOOL synchronizable;

/**
 A direct link to the account store where this account is stored.
 */
@property (weak, nonatomic) NGBAccountStore* accountStore;


@end
