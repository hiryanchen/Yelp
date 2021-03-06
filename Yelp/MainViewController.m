//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpClient.h"
#import "BusinessCell.h"
#import "UIImageView+AFNetworking.h"
#import "FilterViewController.h"

NSString * const kYelpConsumerKey = @"vxKwwcR_NMQ7WaEiQBK_CA";
NSString * const kYelpConsumerSecret = @"33QCvh5bIF5jIHR5klQr7RtBDhQ";
NSString * const kYelpToken = @"uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV";
NSString * const kYelpTokenSecret = @"mqtKIxMIR4iBtBPZCmCLEb-Dz3Y";

@interface MainViewController ()

@property (nonatomic, strong) YelpClient *client;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrBusinesses;
@property (nonatomic, assign) NSInteger collapsedSectionIndex;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
        [self searchWithTerm:@"Thai"];
    }
    return self;
}

- (void)searchWithTerm:(NSString *)term {
    [self.client searchWithTerm:term success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"response: %@", response);
        NSDictionary *dict = response;
        dict = [dict objectForKey:@"businesses"];
        
        self.arrBusinesses = [[NSMutableArray alloc] init];
        for(id business in dict) {
            NSLog(@"business name: %@ %@", [business objectForKey:@"name"], [business objectForKey:@"image_url"]);
            [self.arrBusinesses addObject:business];
        }
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BusinessCell" bundle:nil] forCellReuseIdentifier:@"BusinessCell"];
    self.tableView.rowHeight = 80;
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(50.0, 0.0, self.view.frame.size.width - 50.0, 45.0)];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIView *searchBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 47.0)];
    searchBarView.autoresizingMask = 0;
    searchBar.delegate = self;
    searchBar.barTintColor = [UIColor redColor];
    
    [searchBarView addSubview:searchBar];
    self.navigationItem.titleView = searchBarView;
    
    UIBarButtonItem	*addButton = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(filterClicked)];
    [addButton setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor], NSForegroundColorAttributeName,nil]
                          forState:UIControlStateNormal];

    self.navigationItem.leftBarButtonItem = addButton;
    self.navigationItem.leftBarButtonItem.enabled = YES;
}

- (void)filterClicked {
    [self.navigationController pushViewController:[[FilterViewController alloc] init] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.collapsedSectionIndex == section) {
        return 10;
    } else {
        return 10;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *business = self.arrBusinesses[[indexPath row]];
    /*
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = [business objectForKey:@"name"];
     */
    BusinessCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
    cell.name.text = [business objectForKey:@"name"];
    //NSLog(@"%@", [[business objectForKey:@"location"] objectForKey:@"address"][0]);
    cell.addressLabel.text = [[business objectForKey:@"location"] objectForKey:@"address"][0];
    
    cell.numberReviews.text = [NSString stringWithFormat:@"%@ Reviews",[business objectForKey:@"review_count"]];

    [cell.posterImage setImageWithURL:[NSURL URLWithString:[business objectForKey:@"image_url"]]];
    [cell.ratingImage setImageWithURL:[NSURL URLWithString:[business objectForKey:@"rating_img_url"]]];

    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    headerView.backgroundColor = [UIColor colorWithRed:arc4random() % 255 / 255.0 green:arc4random() % 255 / 255.0 blue: arc4random() % 255 / 255.0 alpha:1];
    return headerView;
}

-(CGFloat)tableView:(UITableView *) tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self.view endEditing:YES];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger previousCollapsedSectionIndex = self.collapsedSectionIndex;
    self.collapsedSectionIndex = indexPath.section;

    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndex:previousCollapsedSectionIndex];
    [indexSet addIndex:self.collapsedSectionIndex];

    [tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self searchWithTerm:searchBar.text];
}

@end
