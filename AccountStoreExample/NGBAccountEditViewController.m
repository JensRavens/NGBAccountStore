#import "NGBAccountEditViewController.h"

@interface NGBAccountEditViewController () <UITextFieldDelegate>

@end

@implementation NGBAccountEditViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	self.identifierField.text = self.account.identifier;
    self.nameField.text = self.account.username;
    self.passwordField.text = self.account.password? @"secret" : @"";
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.identifierField) {
        self.account.identifier = textField.text;
    } else if (textField == self.nameField) {
        self.account.username = textField.text;
    } else if (textField == self.passwordField) {
        self.account.password = textField.text;
    }
}

@end
