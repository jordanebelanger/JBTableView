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

static UIColor *kLightBlueColor;

@interface RedditViewController () <UITableViewDataSource, UITableViewDelegate, JBTableViewPullToRefreshViewDelegate>

@property (assign, nonatomic) Class pullToRefreshViewClass;

@property (strong, nonatomic) JBTableView *tableView;
@property (strong, nonatomic) NSArray *links;

@end

@implementation RedditViewController

+ (void)initialize
{
    kLightBlueColor = [UIColor colorWithRed:0.1 green:0.4 blue:0.7 alpha:1.0];
}

- (instancetype)initWithPullToRefreshViewClass:(Class<JBPullToRefreshView>)pullToRefreshViewClass;
{
    self = [super init];
    if (self) {
        _pullToRefreshViewClass = pullToRefreshViewClass;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor:kLightBlueColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationItem.title = @"Reddit /r/all";

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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self.links count] == 0) {
        [self refreshLinks];
    }
}

#pragma mark - Private

- (void)refreshLinks
{
    NSURL *frontURL = [NSURL URLWithString:@"http://www.reddit.com/r/all/hot/.json?count=25"];
    
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
    // Using the JBTableViewPullToRefreshViewDelegate delegate method to set public properties on
    // our pullToRefreshView before they're setuped by the JBTableView
    if (tableView.pullToRefreshViewClass == [JBPullToRefreshView class]) {
        [(JBPullToRefreshView *)pullToRefreshView setActivityIndicatorColor:kLightBlueColor];
    } else if (tableView.pullToRefreshViewClass == [CirclePullToRefreshView class]) {
        [(CirclePullToRefreshView *)pullToRefreshView setCircleColor:kLightBlueColor];
    } else if (tableView.pullToRefreshViewClass == [BallsPullToRefreshView class]) {
        [(BallsPullToRefreshView *)pullToRefreshView setBallsColor:kLightBlueColor];
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
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *linkTitle = self.links[indexPath.row][@"data"][@"title"];
    return [RedditLinkTableViewCell cellHeightForCellWidth:CGRectGetWidth(self.tableView.bounds) withLinkTitle:linkTitle];
}

@end
