#import <XCTest/XCTest.h>
#import <Security/Security.h>
#import "NGBAccountStore.h"
#import "NGBAccount.h"

#define SERVICE_NAME @"AccountStoreService"

@interface NGBAccountStoreTests : XCTestCase

@property (strong, nonatomic) NGBAccountStore* accountsStore;
@property (strong, nonatomic) NGBAccount* account;
@property (strong, nonatomic) NSString* password;

@end

@interface NGBAccountStore (Testing)

@property (strong, nonatomic) NSMutableArray* managedAccounts;

@property (readonly, nonatomic) NSString* pathToFile;

@end

@implementation NGBAccountStoreTests

- (void)setUp
{
    [super setUp];
    
    [self resetStore];
    
    self.accountsStore = [[NGBAccountStore alloc] init];
    
    self.account = [[NGBAccount alloc] init];
    self.account.username = @"ChatDude";
    self.account.identifier = @"7262238";
    self.account.thumbnailUrl = [NSURL URLWithString:@"http://placekitten.com/200/200"];
    
    self.password = @"testpass";
    
}

- (void)resetStore
{
    NSDictionary* query = @{
                            (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService: SERVICE_NAME
                            };
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)(query));
    XCTAssert(status == errSecSuccess || status == errSecItemNotFound, @"error resetting the database");
}

- (void)testAccountCreation
{
    [self.accountsStore addAccount:self.account];
    XCTAssert([self.accountsStore.accounts containsObject:self.account], @"accounts list should include the newly created object");
}

- (void)testSingleton
{
    NGBAccountStore* store = [NGBAccountStore defaultStore];
    NGBAccountStore* store2 = [NGBAccountStore defaultStore];
    XCTAssertEqual(store, store2, @"singleton should return same instance");
}

- (void)testPersistenceOfAccountWithoutPassword
{
    [self.accountsStore addAccount:self.account];
    
    NGBAccountStore* newStore = [[NGBAccountStore alloc] init];
    XCTAssert(newStore.accounts.count == 1, @"should contain exactly one account");
    NGBAccount* newAccount = newStore.accounts.lastObject;
    XCTAssertEqualObjects(self.account.identifier, newAccount.identifier, @"should have a consistent id");
    XCTAssertNil(newAccount.password, @"password should not be saved");
}

- (void)testPersistenceOfAccountWithPassword
{
    [self.accountsStore addAccount:self.account];
    [self.accountsStore setPassword:self.password forAccount:self.account];
    
    NGBAccountStore* newStore = [[NGBAccountStore alloc] init];
    NGBAccount* newAccount = newStore.accounts.lastObject;
    XCTAssertEqualObjects(self.account.identifier, newAccount.identifier, @"should have a consistent id");
    NSString* password = [newStore passwordForAccount:newAccount];
    XCTAssertNotNil(password, @"password should be saved");
}

- (void)testAccountDeletion
{
    [self.accountsStore addAccount:self.account];
    [self.accountsStore removeAccount:self.account];
    XCTAssert(self.accountsStore.accounts.count == 0, @"there should be no accounts left");
    
    NGBAccountStore* newStore = [[NGBAccountStore alloc] init];
    XCTAssert(newStore.accounts.count == 0, @"there should be no accounts imported from keychain");
}

- (void)testAccountRejection
{
    NGBAccount* invalidAccount = [[NGBAccount alloc] init];
    [self.accountsStore addAccount:invalidAccount];
    XCTAssert(self.accountsStore.accounts.count == 0, @"there should be no accounts left");
}

- (void)testAccountMerging
{
    [self.accountsStore addAccount:self.account];
    
    NGBAccount* newAccount = [[NGBAccount alloc] init];
    newAccount.identifier = self.account.identifier;
    
    [self.accountsStore addAccount:newAccount];
    XCTAssertEqualObjects(self.account.identifier, newAccount.identifier, @"username should be prefilled with information from database");
}

@end
