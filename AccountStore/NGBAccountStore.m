#import "NGBAccountStore.h"

#define SERVICE_NAME @"AccountStoreService"

NSString* const NGBAccountStoreDidChangeAccountsNotification = @"PRAAccountsStoreDidChangeAccountsNotification";

@interface NGBAccountStore ()

@property (strong, nonatomic) NSMutableDictionary* managedAccounts;

//this is only a cache for the sorted accounts list
@property (strong, nonatomic) NSArray* accounts;
@property (readonly, nonatomic) NSString* pathToFile;

@end

@implementation NGBAccountStore

#pragma mark - Life Cycle

+ (NGBAccountStore *)defaultStore
{
    static NGBAccountStore* store;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[self alloc] init];
    });
    return store;
}

- (id)init
{
    if (self = [super init]) {
        self.managedAccounts = [NSMutableDictionary dictionary];
        [self importFromKeychain];
    }
    return self;
}

#pragma mark - Methods

- (NSArray*)accounts
{
    if (!_accounts) {
        //if this list is not yet created, rebuild it.
        _accounts = self.managedAccounts.allValues;
        if (self.accountsSortDescriptor) {
            _accounts = [_accounts sortedArrayUsingDescriptors:@[self.accountsSortDescriptor]];
        }
    }
    return _accounts;
}

- (BOOL)addAccount:(id<NGBManagedAccount>)account
{
    if (!account.identifier) {
        return NO;
    }
    
    if ([self saveAccount:account withPassword:nil]) {
        self.managedAccounts[account.identifier] = account;
        if ([account respondsToSelector:@selector(setAccountStore:)]) {
            [account setAccountStore:self];
        }
        [self invalidateAccountsList];
        return YES;
    }
    return NO;
}

- (BOOL)removeAccount:(id<NGBManagedAccount>)account
{
    if ([self deleteAccount:account]) {
        [self.managedAccounts removeObjectForKey:account.identifier];
        if ([account respondsToSelector:@selector(setAccountStore:)]) {
            [account setAccountStore:nil];
        }
        [self invalidateAccountsList];
        return YES;
    }
    return NO;
}

#pragma mark - Private Methods

- (void)invalidateAccountsList
{
    self.accounts = nil;
}

- (void)importFromKeychain
{
    NSDictionary* query = @{
                            (__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService: SERVICE_NAME,
                            (__bridge id)kSecReturnAttributes: (id)kCFBooleanTrue,
                            (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitAll
                            };
    CFArrayRef result;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)(query), (CFTypeRef*)&result);
    if (status != errSecSuccess) {
        if (status == errSecItemNotFound) {
            //no items in the keychain. we're done.
        } else {
            NSLog(@"error reading from keychain: %d", (int)status);
        }
    } else {
        NSArray* accountData = (__bridge NSArray *)(result);
        for (NSDictionary* accountDictionary in accountData) {
            NSString* identifier = accountDictionary[(__bridge __strong id)(kSecAttrAccount)];
            NSString* accountDataString = accountDictionary[(__bridge __strong id)(kSecAttrDescription)];
            NSData* accountData = [[NSData alloc] initWithBase64EncodedString:accountDataString options:0];
            if (accountData) {
                id<NGBManagedAccount> account = [NSKeyedUnarchiver unarchiveObjectWithData:accountData];
                account.identifier = identifier; //reassign identifier to fix an error that might occur when the identifier key changed.
                if ([account respondsToSelector:@selector(setAccountStore:)]) {
                    [account setAccountStore:self];
                }
                self.managedAccounts[identifier] = account;
                [self invalidateAccountsList];
            }
        }
    }
    
}


- (NSString*)passwordForAccount:(id<NGBManagedAccount>)account
{
    NSDictionary* query = @{
                            (__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService: SERVICE_NAME,
                            (__bridge id)kSecAttrAccount: account.identifier,
                            (__bridge id)kSecReturnData: (id)kCFBooleanTrue
                            };
    CFDataRef result;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)(query), (CFTypeRef*)&result);
    if (status == errSecSuccess) {
        NSData* secret = (__bridge NSData *)(result);
        if (secret.length) {
            return [[NSString alloc] initWithData:secret encoding:NSUTF8StringEncoding];
        }
    } else {
        NSLog(@"error retrieving password for user %@", account.identifier);
    }
    return nil;
}

- (BOOL)setPassword:(NSString *)password forAccount:(id<NGBManagedAccount>)account
{
    if (self.managedAccounts[account.identifier]) {
        return [self saveAccount:account withPassword:password];
    }
    return NO;
}


- (BOOL)saveAccount:(id<NGBManagedAccount>)account withPassword:(NSString*)password
{
    NSData* secret = [password dataUsingEncoding:NSUTF8StringEncoding];
    NSData* accountData = [NSKeyedArchiver archivedDataWithRootObject:account];
    NSString* accountDataString = [accountData base64EncodedStringWithOptions:0];
    
    NSDictionary* query = @{
                            (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrAccount: account.identifier,
                            (__bridge id)kSecAttrService: SERVICE_NAME
                            };
    
    NSMutableDictionary* updates = @{
                                     (__bridge id)kSecAttrDescription: accountDataString,
                                     (__bridge id)kSecAttrService: SERVICE_NAME,
                                     (__bridge id)kSecAttrSynchronizable: @([account isSynchronizable])
                                     }.mutableCopy;
    
    if (secret) {
        updates[(__bridge id)kSecValueData] = secret;
    }
    
    NSMutableDictionary* addQuery = query.mutableCopy;
    [addQuery addEntriesFromDictionary:updates];
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)(addQuery), NULL);
    if (status != errSecSuccess) {
        if (status == errSecDuplicateItem) {
            OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)(query), (__bridge CFDictionaryRef)(updates));
            if (status != errSecSuccess) {
                NSLog(@"error while updating keychain");
            }
        } else {
            
            NSLog(@"error writing to keychain: %d", (int)status);
        }
    }
    return YES;
}

- (BOOL)deleteAccount:(id<NGBManagedAccount>)account
{
    NSDictionary* query = @{
                            (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrAccount: account.identifier,
                            (__bridge id)kSecAttrService: SERVICE_NAME
                            };
    
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)(query));
    
    if (status != errSecSuccess) {
        NSLog(@"error deleting account %@: %d", account.identifier, (int)status);
        return NO;
    }
    return YES;
}

@end
