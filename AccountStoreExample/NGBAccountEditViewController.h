#import <UIKit/UIKit.h>
#import "NGBAccount.h"

@interface NGBAccountEditViewController : UIViewController

@property (nonatomic) NGBAccount* account;

@property (weak, nonatomic) IBOutlet UITextField* nameField;
@property (weak, nonatomic) IBOutlet UITextField* passwordField;
@property (weak, nonatomic) IBOutlet UITextField* identifierField;

@end
