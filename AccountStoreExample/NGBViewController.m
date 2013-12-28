#import "NGBViewController.h"
#import "NGBAccountStore.h"
#import "NGBAccount.h"
#import "NGBAccountEditViewController.h"

@interface NGBViewController ()

@property (strong, nonatomic) NGBAccountStore* accountStore;

@end

@implementation NGBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.accountStore = [NGBAccountStore defaultStore];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.accountStore.accounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NGBAccount* account = self.accountStore.accounts[indexPath.row];
    cell.textLabel.text = account.username;
    cell.detailTextLabel.text = account.identifier;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NGBAccount* account = self.accountStore.accounts[indexPath.row];
    [[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"user selected account %@ with password: %@", account.username, account.password] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NGBAccount* account = self.accountStore.accounts[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.accountStore removeAccount:account];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) { //clicked on the add button
        NGBAccount* account = [[NGBAccount alloc] init];
        account.identifier = [NSString stringWithFormat:@"%d",arc4random()];
        [self.accountStore addAccount:account];
        [segue.destinationViewController setAccount:account];
    } else if ([sender isKindOfClass:[UITableViewCell class]]){
        NSInteger index = [self.tableView indexPathForCell:sender].row;
        NGBAccount* account = self.accountStore.accounts[index];
        [segue.destinationViewController setAccount:account];
    }
}

- (void)didEndEditingAccount:(UIStoryboardSegue *)segue
{
    NGBAccount* account = [segue.sourceViewController account];
    [[segue.sourceViewController view] endEditing:YES];
    [self.accountStore addAccount:account];
    [self.tableView reloadData];
}


@end
