#import "NGBAccount.h"
#import <Security/Security.h>
#import "NGBAccountStore.h"

@interface NGBAccount ()

@property (readonly, nonatomic) NSArray* encodedValues;

@end

@implementation NGBAccount


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        for (NSString* key in self.encodedValues) {
            id value = [aDecoder decodeObjectForKey:key];
            if (value) {
                [self setValue:value forKey:key];
            }
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    for (NSString* key in self.encodedValues) {
        [aCoder encodeObject:[self valueForKey:key] forKey:key];
    }
}

- (NSArray*)encodedValues
{
    return @[
             @"username",
             @"identifier",
             @"thumbnailUrl",
             @"lastLogin"
             ];
}


- (NSString *)description
{
    NSMutableString* description = [NSMutableString string];
    for (NSString* key in self.encodedValues) {
        [description appendFormat:@"%@: %@\n", key, [self valueForKey:key]];
    }
    return description;
}

- (NSString *)password
{
    return [self.accountStore passwordForAccount:self];
}

- (void)setPassword:(NSString *)password
{
    [self.accountStore setPassword:password forAccount:self];
}

@end
