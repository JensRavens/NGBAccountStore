#import <Foundation/Foundation.h>
#import "NGBManagedAccount.h"

extern NSString* const NGBAccountStoreDidChangeAccountsNotification;

@interface NGBAccountStore : NSObject

/**
 A list of all saved and unsafed accounts, sorted by last login date.
 */
@property (readonly, nonatomic) NSArray* accounts; //of PRAAccounts
@property (strong, nonatomic) NSSortDescriptor* accountsSortDescriptor;

+ (NGBAccountStore*)defaultStore;

- (BOOL)addAccount:(id<NGBManagedAccount>)account;
- (BOOL)removeAccount:(id<NGBManagedAccount>)account;

- (NSString*)passwordForAccount:(id<NGBManagedAccount>)account;
- (BOOL)setPassword:(NSString*)password forAccount:(id<NGBManagedAccount>)account;

@end
