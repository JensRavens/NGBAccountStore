#import <Foundation/Foundation.h>

@class NGBAccountStore;

/**
 A basic protocol for all different types of accounts. If you want to use your own account class instead of NGBAccount, you're supposed to implement this protocol. Serialization is done by NSCoding, so implement this protocol for all important properties of your class.
 
 @warning You must not serialize the password! Password saving is done by the NGBAccountStore.
 
 */
@protocol NGBManagedAccount <NSCoding, NSObject>

/**
 Provides a unique identifier for this account. Accounts are considered the same if identifiers match.
 
 @return A unique identifier.
 */
- (NSString*)identifier;

/**
 Called on init after the account is deserialized from the account store. You're supposed to save the identifier for later use.
 
 @param identifier A unique Identifier.
 */
- (void)setIdentifier:(NSString*)identifier;

/**
 A setting if this account should be saved in iCloud. If you return yes, this account will be accessible on alle connected devices.
 
 @warning If you delete an account that is synchronized, it will be deleted on all iCloud connected devices!
 
 @return A flag inidicating if this account should be synchronized via iCloud keychain.
 */
- (BOOL)isSynchronizable;

@optional

/**
 An optional property that provides a weak reference to the corresponding account store. This might be convinient if you want to provide a direct access to the password from the accounts object. This reference is automatically set after adding the account to the accounts store or after deserializing from disk is finished.
 */
@property (weak, nonatomic) NGBAccountStore* accountStore;

@end
