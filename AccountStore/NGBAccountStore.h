#import <Foundation/Foundation.h>
#import "NGBManagedAccount.h"

extern NSString* const NGBAccountStoreDidChangeAccountsNotification;

/**
 A basic store for storing accounts that implement the NGBManagedAccount protocol. Each account store loads all accounts accessible from the keychain. For most implementations you can use the convenience implementation NGBAccount.
 */
@interface NGBAccountStore : NSObject

/**
 A list of all saved and unsafed NGBAccounts, sorted by last login date.
 */
@property (readonly, nonatomic) NSArray* accounts;

/**
 Optional sort descriptior. If this property is set, the accounts property will always be sorted by this descriptor.
 */
@property (strong, nonatomic) NSSortDescriptor* accountsSortDescriptor;

/**
 A singleton for easy access.
 
 @return the singleton object.
 */
+ (NGBAccountStore*)defaultStore;

/**
 Add a NGBManagedAccount. This will automatically save the account. You must add an account before setting the password for it.
 
 @param account An object implementin the NGBManagedAccount protocol. You can also use the convenience implementation NGBAccount.
 
 @return A flag indicating if the account was added and saved successfully.
 */
- (BOOL)addAccount:(id<NGBManagedAccount>)account;

/**
 Deletes an account from the database (including the password). If the account is synchronizable via iCloud it will also be removed from all connected devices.
 
 @param account The account to be removed
 
 @return A flag inidicating if the account was removed successfully.
 */
- (BOOL)removeAccount:(id<NGBManagedAccount>)account;

/**
 Retrieve the password for the suplied account. Please note that the password is not saved in the accounts object for security reasons and is saved directly in the keychain instead.
 
 @param account The account you want to get the password for.
 
 @return The password.
 */
- (NSString*)passwordForAccount:(id<NGBManagedAccount>)account;

/**
 Retrieve the password for the suplied account. Please note that the password is not saved in the accounts object for security reasons and is saved directly in the keychain instead.
 
 @note You can only set the password for an account if the account was added to the store before.
 
 @param password The password as a plain text string.
 @param account  The account you want to set the password for.
 
 @return A flag inidcating if the password was set successfully.
 */
- (BOOL)setPassword:(NSString*)password forAccount:(id<NGBManagedAccount>)account;

@end
