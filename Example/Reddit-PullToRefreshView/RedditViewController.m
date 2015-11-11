//
//  JBRedditViewController.m
//  JBTableView Example
//
//  Created by tehjord on 2014-09-04.
//  Copyright (c) 2014 Jordane Belanger. All rights reserved.
//

#import "RedditViewController.h"
#import "RedditLinkTableViewCell.h"
#import "JBTableView/JBTableView.h"
#import "JBTableView/JBPullToRefreshView.h"
#import "CirclePullToRefreshView.h"
#import "BallsPullToRefreshView.h"

@interface RedditViewController () <UITableViewDataSource, UITableViewDelegate, JBTableViewPullToRefreshViewDelegate>

@property (strong, nonatomic) UIColor *defaultColor;
@property (assign, nonatomic) Class pullToRefreshViewClass;
@property (strong, nonatomic) NSString *subredditLink;
@property (copy, nonatomic) PullToRefreshViewCustomizationBlock customizationBlock;

@property (strong, nonatomic) JBTableView *tableView;
@property (strong, nonatomic) NSArray *links;

@end

@implementation RedditViewController

- (instancetype)initWithDefaultColor:(UIColor *)color
              pullToRefreshViewClass:(Class<JBPullToRefreshView>)pullToRefreshViewClass
                       subredditLink:(NSString *)subredditLink
     pullToRefreshCustomizationBlock:(PullToRefreshViewCustomizationBlock)customizationBlock {
    self = [super init];
    if (self) {
        self.defaultColor = color;
        self.pullToRefreshViewClass = pullToRefreshViewClass;
        self.subredditLink = subredditLink;
        self.customizationBlock = customizationBlock;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor:self.defaultColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationItem.title = self.subredditLink;

    JBTableView *tableView = [[JBTableView alloc] initWithFrame:self.view.bounds];
    tableView.pullToRefreshViewClass = self.pullToRefreshViewClass;
    tableView.pullToRefreshViewDelegate = self;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.minimumRefreshTimeInMs = 1500;
    [tableView registerClass:[RedditLinkTableViewCell class] forCellReuseIdentifier:kRedditLinkTableViewCellIdentifier];
    self.tableView = tableView;
    
    __weak __typeof(self) weakself = self;
    [tableView setPullToRefreshBlock:^{
        [weakself refreshLinks];
    }];
    
    [self.view addSubview:tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tabBarController.tabBar setTintColor:self.defaultColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self refreshLinks];
}

#pragma mark - Private

- (void)refreshLinks
{
    NSURL *frontURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.reddit.com%@/hot/.json?count=25", self.subredditLink]];
    
    // Start the pullToRefreshView animation
    [self.tableView startRefreshing];
    
    __weak __typeof(self) weakself = self;
    NSURLSessionDataTask *linkDataTask = [[NSURLSession sharedSession] dataTaskWithURL:frontURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                NSError *jsonParsingError;
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonParsingError];
                if (jsonParsingError) {
                    [[[UIAlertView alloc] initWithTitle:nil message:[jsonParsingError description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                } else {
                    weakself.links = [NSArray arrayWithArray:jsonResponse[@"data"][@"children"]];
                }
            } else {
                [[[UIAlertView alloc] initWithTitle:nil message:[error description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
            
            [weakself.tableView reloadData];

            // Stop the pullToRefreshView animation
            [weakself.tableView stopRefreshing];
        });
    }];
    
    [linkDataTask resume];
}

#pragma mark - JBTableViewPullToRefreshViewDelegate

- (void)JBTableView:(JBTableView *)tableView willSetupPullToRefreshView:(UIView<JBPullToRefreshView> *)pullToRefreshView
{
    if (self.customizationBlock) {
        self.customizationBlock(pullToRefreshView);
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.links count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RedditLinkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRedditLinkTableViewCellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *linkTitle = self.links[indexPath.row][@"data"][@"title"];
    cell.textLabel.text = linkTitle;
    cell.defaultColor = self.defaultColor;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *linkTitle = self.links[indexPath.row][@"data"][@"title"];
    return [RedditLinkTableViewCell cellHeightForCellWidth:CGRectGetWidth(self.tableView.bounds) withLinkTitle:linkTitle];
}

@end
