//
//  JBRedditViewController.m
//  JBTableView Example
//
//  Created by tehjord on 2014-09-04.
//  Copyright (c) 2014 Jordan Belanger. All rights reserved.
//

#import "JBRedditViewController.h"
#import "JBTableView.h"
#import "JBLinkTableViewCell.h"
#import "JBPullToRefreshView.h"
//#import "JBBallsPullToRefreshView.h"

@interface JBRedditViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) JBTableView *tableView;
@property (strong, nonatomic) NSArray *links;

@end

@implementation JBRedditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor brownColor]];
    self.navigationItem.title = @"Reddit";
    
    JBTableView *tableView = [[JBTableView alloc] initWithFrame:self.view.bounds pullToRefreshViewClass:[JBPullToRefreshView class]];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundColor = [UIColor colorWithRed:80.0/255.0 green:80/255.0 blue:50.0/255.0 alpha:1.0];
    tableView.separatorColor = [UIColor brownColor];
    [tableView registerClass:[JBLinkTableViewCell class] forCellReuseIdentifier:JBLinkTableViewCellIdentifier];
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
    
    self.tableView.animatingPullToRefresh = YES;
    
    self.links = nil;
    [self.tableView reloadData];
    
    __weak __typeof(self) weakself = self;
    NSURLSessionDataTask *linkDataTask = [[NSURLSession sharedSession] dataTaskWithURL:frontURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSError *jsonParsingError;
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonParsingError];
            
            if (jsonParsingError) {
                [[[UIAlertView alloc] initWithTitle:nil message:[jsonParsingError description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            } else {
                [weakself.tableView beginUpdates];
                weakself.links = [NSArray arrayWithArray:jsonResponse[@"data"][@"children"]];
                [weakself.tableView insertRowsAtIndexPaths:[self indexPathsForLinks:weakself.links] withRowAnimation:UITableViewRowAnimationAutomatic];
                [weakself.tableView endUpdates];
            }
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:[error description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
        weakself.tableView.animatingPullToRefresh = NO;
    }];
    [linkDataTask resume];
}

- (NSArray *)indexPathsForLinks:(NSArray *)links
{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:[links count]];
    for (int i = 0; i < [links count]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    return [NSArray arrayWithArray:indexPaths];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.links count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JBLinkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:JBLinkTableViewCellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *linkTitle = self.links[indexPath.row][@"data"][@"title"];
    cell.textLabel.text = linkTitle;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *linkTitle = self.links[indexPath.row][@"data"][@"title"];
    return [JBLinkTableViewCell cellHeightForCellWidth:CGRectGetWidth(self.tableView.bounds) withLinkTitle:linkTitle];
}

@end
