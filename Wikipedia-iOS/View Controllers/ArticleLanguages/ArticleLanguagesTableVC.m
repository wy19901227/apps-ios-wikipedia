//  Created by Monte Hurd on 1/23/14.

#import "ArticleLanguagesTableVC.h"
#import "SessionSingleton.h"
#import "DownloadLangLinksOp.h"
#import "QueuesSingleton.h"
#import "ArticleLanguagesCell.h"
//#import "UIViewController+Alert.h"

@interface ArticleLanguagesTableVC ()

@property (strong, nonatomic) NSArray *languagesData;

@end

@implementation ArticleLanguagesTableVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.languagesData = @[];

    [self downloadLangLinkData];
}

-(void)downloadLangLinkData
{
//TODO: fix "showAlert" to work with table view controllers.
    //[self showAlert:@"Loading language links..."];

    DownloadLangLinksOp *langLinksOp = [[DownloadLangLinksOp alloc] initForPageTitle:[SessionSingleton sharedInstance].currentArticleTitle domain:[SessionSingleton sharedInstance].currentArticleDomain completionBlock:^(NSArray *result){
        
        [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
            //[self showAlert:@"Language links loaded."];
            //[self showAlert:@""];

            self.languagesData = result;
            [self.tableView reloadData];
        }];
        
    } cancelledBlock:^(NSError *error){
       //NSString *errorMsg = error.localizedDescription;
       //[self showAlert:errorMsg];
        
    } errorBlock:^(NSError *error){
       //NSString *errorMsg = error.localizedDescription;
       //[self showAlert:errorMsg];
        
    }];
    
    [[QueuesSingleton sharedInstance].langLinksQ addOperation:langLinksOp];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.languagesData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"ArticleLanguagesCell";
    ArticleLanguagesCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    NSDictionary *d = self.languagesData[indexPath.row];

    cell.textLabel.text = d[@"name"];
    cell.canonicalLabel.text = d[@"canonical_name"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *d = self.languagesData[indexPath.row];

    [SessionSingleton sharedInstance].currentArticleTitle = d[@"*"];
    [SessionSingleton sharedInstance].currentArticleDomain = d[@"code"];

    [self.navigationController popViewControllerAnimated:NO];
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
