#import <XCTest/XCTest.h>
#import "NGBAccount.h"

@interface NGBAccountTests : XCTestCase

@property (strong, nonatomic) NGBAccount* account;
@property (strong, nonatomic) NSString* password;

@end

@implementation NGBAccountTests

- (void)setUp
{
    [super setUp];
    
    self.account = [[NGBAccount alloc] init];
    self.account.username = @"ChatDude";
    self.account.identifier = @"7262238";
    
    self.password = @"testpass";
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testSerializability
{
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self.account];
    NGBAccount* account2 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssertEqualObjects(self.account.identifier, account2.identifier, @"should have the same user id");
}

- (void)testUrlSerialization
{
    self.account.thumbnailUrl = [NSURL URLWithString:@"http://placekitten.com/200/200"];
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self.account];
    NGBAccount* account2 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssertEqualObjects(self.account.thumbnailUrl, account2.thumbnailUrl, @"should have the same user id");
}

- (void)testPasswordShouldNotBeSerialized
{
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self.account];
    NGBAccount* account2 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssertNil(account2.password, @"password should not be serialized for security reasons");
}

@end
