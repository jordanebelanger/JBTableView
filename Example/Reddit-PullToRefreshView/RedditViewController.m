//
//  JBRedditViewController.m
//  JBTableView Example
//
//  Created by tehjord on 2014-09-04.
//  Copyright (c) 2014 Jordan Belanger. All rights reserved.
//

#import "RedditViewController.h"
#import "RedditLinkTableViewCell.h"
#import "JBTableView/JBTableView.h"
#import "CirclePullToRefreshView.h"
#import "BallsPullToRefreshView.h"

@interface RedditViewController () <UITableViewDataSource, UITableViewDelegate, JBTableViewPullToRefreshViewDelegate>

@property (assign, nonatomic) Class pullToRefreshViewClass;

@property (strong, nonatomic) JBTableView *tableView;
@property (strong, nonatomic) NSArray *links;

@end

@implementation RedditViewController

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
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.1 green:0.4 blue:0.7 alpha:1.0]];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationItem.title = @"Reddit";

    JBTableView *tableView = [[JBTableView alloc] initWithFrame:self.view.bounds];
    tableView.pullToRefreshViewClass = self.pullToRefreshViewClass;
    tableView.pullToRefreshViewDelegate = self;
    tableView.dataSource = self;
    tableView.delegate = self;
    [tableView registerClass:[RedditLinkTableViewCell class] forCellReuseIdentifier:kRedditLinkTableViewCellIdentifier];
    self.tableView = tableView;
    
    [tableView setPullToRefreshBlock:^{
        [self refreshLinks];
    }];
    
    [self.view addSubview:tableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self refreshLinks];
}

#pragma mark - Private

- (void)refreshLinks
{
    NSURL *frontURL = [NSURL URLWithString:@"http://www.reddit.com/hot/.json?count=25"];
    
    // The
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
            
            //            [weakself.tableView stopRefreshing];
        });
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself.tableView stopRefreshing];
    });
    
    [linkDataTask resume];
}

#pragma mark - JBTableViewPullToRefreshViewDelegate

- (void)JBTableView:(JBTableView *)tableView willSetupPullToRefreshView:(UIView<JBPullToRefreshView> *)pullToRefreshView
{
    
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
