//  Created by Monte Hurd on 2/10/14.

#import "LoginViewController.h"
#import "NavController.h"
#import "QueuesSingleton.h"
#import "LoginTokenOp.h"
#import "LoginOp.h"
#import "EditTokenOp.h"
#import "SessionSingleton.h"
#import "UIViewController+Alert.h"

#define NAV ((NavController *)self.navigationController)

@interface LoginViewController (){
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationItem.hidesBackButton = YES;

    if ([self.scrollView respondsToSelector:@selector(keyboardDismissMode)]) {
        self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureNavBar];
}

-(void)configureNavBar
{
    NAV.navBarStyle = NAVBAR_STYLE_LOGIN;
    
    [[NAV getNavBarItem:NAVBAR_BUTTON_CHECK] addTarget: self
                                                action: @selector(save)
                                      forControlEvents: UIControlEventTouchUpInside];
    
    [[NAV getNavBarItem:NAVBAR_BUTTON_X] addTarget: self
                                            action: @selector(cancel)
                                  forControlEvents: UIControlEventTouchUpInside];
    
    ((UILabel *)[NAV getNavBarItem:NAVBAR_LABEL]).text = @"Sign In";
}

-(void)save
{
    [self login];
}

-(void)cancel
{
    // Remove these listeners before popping the VC or you get sadness and crashes.
    [[NAV getNavBarItem:NAVBAR_BUTTON_CHECK] removeTarget: self
                                                   action: @selector(save)
                                         forControlEvents: UIControlEventTouchUpInside];
    
    [[NAV getNavBarItem:NAVBAR_BUTTON_X] removeTarget: self
                                               action: @selector(cancel)
                                     forControlEvents: UIControlEventTouchUpInside];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NAV.navBarStyle = NAVBAR_STYLE_SEARCH;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



















-(void)login
{

[self showAlert:@""];

    
    
/*
    login credentials should only be placed in the keychain if they've been authenticated.
 
    -editing interface: if we have login credentials in the keychain, have each edit do all 3 ops below . just change it to save off the edit token by language code, then go to the place the edit token is used and have it use the language code edit token for the article being edited

        (later update to only do all 3 ops if we don't have a lang code edit token or if we do and try to use it and get an "invalid token" response when trying to use save the edit with it)

    -editing interface: if no login credentials in the keychain, ask once per session if the user would like to log in before editing, or edit anonymously, if login show the login interface, if not continue with the edit w/o doing any ops (will default to "+\\" for edit token)
 
    -login interface: do LoginTokenOp and LoginOp
*/
    
    
    
    
void (^printCookies)() =  ^void(){
    NSLog(@"\n\n\n\n\n\n\n\n\n\n");
    for (NSHTTPCookie *cookie in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
        NSLog(@"cookies = %@", cookie.properties);
    }
    NSLog(@"\n\n\n\n\n\n\n\n\n\n");
};
    
    
    
    
    
    
    
    
    
    
//[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];

NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
NSLog(@"cookies = %@", cookies);

//return;
    
    
    

//NSString *editToken = [SessionSingleton sharedInstance].keychainCredentials.editToken;
//if (editToken) return;

    
    
    
    
NSString *userName = self.usernameField.text;
NSString *password = self.passwordField.text;


LoginOp *loginOp = [[LoginOp alloc] initWithUsername: userName
                                            password: password
                                              domain: [SessionSingleton sharedInstance].domain
                                     completionBlock: ^(NSString *loginResult){
                                         
[SessionSingleton sharedInstance].keychainCredentials.userName = userName;
[SessionSingleton sharedInstance].keychainCredentials.password = password;

NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
NSLog(@"LoginOp cookies = %@", cookies);






//NSString *result = loginResult[@"login"][@"result"];
[self showAlert:loginResult];





















// Pass it 2 cookie names. If they're both found, it will discard cookie 1 and recreate it
// using cookie 2 as a template. All of cookie 2's properties will be used, except "Name",
// "Value" and "Created", which will come from the original cookie 1.
void (^cloneCookie)(NSString *, NSString *) =  ^void(NSString *name1, NSString *name2){
    NSUInteger (^getIndexOfCookie)(NSString *) =  ^NSUInteger(NSString *name){
        return [cookies indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
         NSHTTPCookie *cookie = (NSHTTPCookie *)obj;
         if (cookie.properties[@"Name"]) {
             if ([cookie.properties[@"Name"] isEqualToString:name]) {
                 *stop = YES;
                 return YES;
             }
         }
         return NO;
        }];
    };
    
    NSUInteger indexCookie1 = getIndexOfCookie(name1);
    NSUInteger indexCookie2 = getIndexOfCookie(name2);
    
    if ((indexCookie1 != NSNotFound) && (indexCookie2 != NSNotFound)) {

        NSLog(@"indexCookie1 = %d", indexCookie1);
        NSLog(@"indexCookie2 = %d", indexCookie2);

        NSHTTPCookie *cookie1 = cookies[indexCookie1];
        NSHTTPCookie *cookie2 = cookies[indexCookie2];
        NSString *cookie1Name = cookie1.name;
        NSString *cookie1Value = cookie1.value;

        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie1];

        NSMutableDictionary *cookie2Props = [cookie2.properties mutableCopy];
        cookie2Props[@"Created"] = [NSDate date];
        cookie2Props[@"Name"] = cookie1Name;
        cookie2Props[@"Value"] = cookie1Value;
        NSHTTPCookie *newCookie = [NSHTTPCookie cookieWithProperties:cookie2Props];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:newCookie];
    }
};

// Make the session cookies expire at same time user cookies. We can't count on them
// being valid as the server may expire them, but at least make them last as long as we can
// to lessen number of server requests.
cloneCookie(
    [NSString stringWithFormat:@"%@wikiSession", [SessionSingleton sharedInstance].domain],
    [NSString stringWithFormat:@"%@wikiUserID", [SessionSingleton sharedInstance].domain]
);

cloneCookie(
    @"centralauth_Session",
    @"centralauth_User"
);



//printCookies();






/*
for (NSHTTPCookie *cookie in [cookies copy]) {
    if (cookie.isSessionOnly) {
    
    
        NSMutableDictionary *props = [cookie.properties mutableCopy];

[[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];

props[@"Discard"] = @"FALSE";
NSHTTPCookie* newCookie = [NSHTTPCookie cookieWithProperties:props];
[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:newCookie];
    
    
    }

}

NSArray *cookies2 = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
NSLog(@"LoginTokenOp cookies2 = %@", cookies2);
*/












//                                         NSLog(@"LoginOp completionBlock result = %@", loginResult);
                                         
                                     } cancelledBlock:^(NSError *error){
                                     
                                         NSString *errorMsg = error.localizedDescription;
                                         [self showAlert:errorMsg];
                                         
                                     } errorBlock:^(NSError *error){
                                     
                                         NSString *errorMsg = error.localizedDescription;
                                         [self showAlert:errorMsg];
                                         
                                     }];


LoginTokenOp *loginTokenOp = [[LoginTokenOp alloc] initWithUsername: userName
                                                           password: password
                                                             domain: [SessionSingleton sharedInstance].domain
                                                    completionBlock: ^(NSString *tokenRetrieved){
                                                        
                                                        NSLog(@"loginTokenOp token = %@", tokenRetrieved);
                                                        loginOp.token = tokenRetrieved;

NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
NSLog(@"LoginTokenOp cookies = %@", cookies);


                                                        
                                                    } cancelledBlock:^(NSError *error){
                                                    
                                                        [self showAlert:@""];
                                                        
                                                    } errorBlock:^(NSError *error){
                                                    
                                                        NSString *errorMsg = error.localizedDescription;
                                                        [self showAlert:errorMsg];
                                                        
                                                    }];




EditTokenOp *editTokenOp = [[EditTokenOp alloc] initWithDomain: [SessionSingleton sharedInstance].domain
                                               completionBlock: ^(NSDictionary *result){
                                                   NSLog(@"editTokenOp result = %@", result);
                                                   NSLog(@"editTokenOp result tokens = %@", result[@"tokens"][@"edittoken"]);

NSString *editToken = result[@"tokens"][@"edittoken"];
//[[NSUserDefaults standardUserDefaults] setObject:editToken forKey:@"EditToken"];
//[[NSUserDefaults standardUserDefaults] synchronize];
[SessionSingleton sharedInstance].keychainCredentials.editToken = editToken;

//NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
//NSLog(@"EditTokenOp cookies = %@", cookies);

printCookies();








                                               } cancelledBlock:^(NSError *error){
                                                   
                                                   [self showAlert:@""];
                                                   
                                               } errorBlock: ^(NSError *error){
                                                   
                                                   NSString *errorMsg = error.localizedDescription;
                                                   [self showAlert:errorMsg];
                                                   
                                               }];


loginTokenOp.delegate = self;
loginOp.delegate = self;
editTokenOp.delegate = self;


[loginOp addDependency:loginTokenOp];
[editTokenOp addDependency:loginOp];

//TODO: make/use a login Q for these
[QueuesSingleton sharedInstance].articleRetrievalQ.suspended = YES;
[[QueuesSingleton sharedInstance].articleRetrievalQ addOperation:editTokenOp];
[[QueuesSingleton sharedInstance].articleRetrievalQ addOperation:loginTokenOp];
[[QueuesSingleton sharedInstance].articleRetrievalQ addOperation:loginOp];
[QueuesSingleton sharedInstance].articleRetrievalQ.suspended = NO;


    
    
    
    
    


}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
