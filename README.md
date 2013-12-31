# NGBAccountStore

NGBAccountStore is a simple drop-in class for storing complete account objects encrypted in the system keychain. iCloud sync is supported, too.

## Requirements

NGBAccountStore works only on iOS7 as it uses the built in base64 decoder. But I'm happy to accept pull requests adding backwards compability.

## Adding NGBAccountStore to your project

### Cocoapods

[CocoaPods](http://cocoapods.org) is the recommended way to add NGBAccountStore to your project.

1. Add a pod entry for MBProgressHUD to your Podfile `pod 'NGBAccountStore', '~> 0.1.0'`
2. Install the pod(s) by running `pod install`.

### Source files

Alternatively you can directly add the source files to your project.

1. Download the [latest code version](https://github.com/jensravens/NGBAccountStore/archive/master.zip) or add the repository as a git submodule to your git-tracked project. 
2. Open your project in Xcode, then drag and drop all classes in the AccountStore folder onto your project (use the "Product Navigator view"). Make sure to select Copy items when asked if you extracted the code archive outside of your project. 

## Usage

Just instantiate an instance of NGBAccountStore or use the provided Singleton, then add your accounts. You can use the provided convenience class NGBAccount or roll your own account class by implementing the NGBManagedAccount protocol on your account.

Password saving is decoupled from the account object as the password should not stay in memory for security reasons.


### Get all accounts in the keychain:

```objective-c

NSArray* accounts = [NGBAccountStore defaultStore].accounts;
```

### create a new account

```objective-c

NGBAccount* account = [[NGBAccount alloc] init];
account.identifier = @"thisismyid";
account.username = "John Doe";
[[NGBAccountStore defaultStore] addAccount: account];
[[NGBAccountStore defaultStore] setPassword:'secret!' forAccount:account];
```

### read the password from an account:

```objective-c

NGBAccount* account = [NGBAccountStore defaultStore].accounts.firstObject;
NSString* password = [[NGBAccountStore defaultStore] passwordForAccount:account];

// or use the convenience method:

password = account.password;
```

## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE). 

## Contributing

Have a new idea or found a bug? Please support this project by contributing pull requests.

First open an issue and state that you're working on something so there is no doubled work. Then submit your pull request.

## Coding guidelines

* All public methods need to be documented with appledoc syntax.
* If you provide additional functionality, add a unit test.
* If you fix a bug, please add a unit test so the bug will not happen again.