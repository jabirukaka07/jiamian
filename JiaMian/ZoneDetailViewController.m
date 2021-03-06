//
//  ZoneDetailViewController.m
//  JiaMian
//
//  Created by wy on 14-6-27.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "ZoneDetailViewController.h"
#import "AreaModel.h"
#import "SelectZoneViewController.h"

#define kZoneNameLabelTag    9000
#define kZoneHotImageViewTag 9001
@interface ZoneDetailViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UINavigationBarDelegate>
{
    NSMutableArray* zonesArr;
    NSMutableArray* searchRes;
    NSInteger lastSelectZoneId;
}
@property (strong, nonatomic) UISearchDisplayController *searchDispalyController;
@end

@implementation ZoneDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"viewDidLoad");
    [self configureNavigationBar];
    [self configureTableHeaderView:1];
    [self configureTableFooterView];


    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    zonesArr = [NSMutableArray array];
    searchRes = [NSMutableArray array];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray* result = [[NetWorkConnect sharedInstance] areaList:0
                                                              maxId:INT_MAX
                                                              count:20
                                                           areaType:(int)_zoneType
                                                         filterType:0
                                                            keyWord:nil];
        [zonesArr addObjectsFromArray:result];
        
        NSData* confData = [[NSUserDefaults standardUserDefaults] objectForKey:kCongigureDict];
        NSDictionary* confDict = [NSKeyedUnarchiver unarchiveObjectWithData:confData];
        NSDictionary* zoneConf = [confDict objectForKey:[NSNumber numberWithInteger:_zoneType]];
        lastSelectZoneId = [[zoneConf objectForKey:@"zoneId"] integerValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            
        });
    });
    
    if (IOS_NEWER_OR_EQUAL_TO_7)
    {
        CGRect frame = self.searchBar.frame;
        [self.searchBar setFrame:CGRectMake(frame.origin.x, frame.origin.y + 20, frame.size.width, frame.size.height)];
    }
    else
    {
        //   [_searchDisplayController.searchResultsTableView setContentInset:UIEdgeInsetsMake(44, 0, 0, 0)];
    }
    _searchDispalyController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    _searchDispalyController.delegate = self;
    _searchDispalyController.searchResultsDataSource = self;
    _searchDispalyController.searchResultsDelegate = self;
}
- (AreaModel*)filterArray:(NSArray*)array
{
    AreaModel* res = nil;
    for(AreaModel* zone in array)
    {
        if (zone.type == _zoneType)
        {
            res = zone;
        }
    }
    return res;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView DataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _searchDispalyController.searchResultsTableView)
    {
        return [searchRes count];
    }
    else
    {
        return [zonesArr count];
    }
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"ZoneCellIdentifier";
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    AreaModel* zone = nil;
    if (tableView == _searchDispalyController.searchResultsTableView)
    {
        zone = (AreaModel*)[searchRes objectAtIndex:indexPath.row];
    }
    else
    {
        zone = (AreaModel*)[zonesArr objectAtIndex:indexPath.row];
    }
    UILabel* zoneNameLabel = (UILabel*)[cell viewWithTag:kZoneNameLabelTag];
    [zoneNameLabel setText:zone.area_name];
    UIImageView* hotImageView = (UIImageView*)[cell viewWithTag:kZoneHotImageViewTag];
    if (zone.hots >= 5000) {
        [hotImageView setImage:[UIImage imageNamed:@"ic_index_star5"]];
    } else if (zone.hots > 2000) {
        [hotImageView setImage:[UIImage imageNamed:@"ic_index_star4"]];
    } else if (zone.hots > 500) {
        [hotImageView setImage:[UIImage imageNamed:@"ic_index_star3"]];
    } else if (zone.hots > 100) {
        [hotImageView setImage:[UIImage imageNamed:@"ic_index_star2"]];
    } else {
        [hotImageView setImage:[UIImage imageNamed:@"ic_index_star1"]];
    }
    
    if (lastSelectZoneId == zone.area_id)
    {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else
    {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    return cell;
}

#pragma mark - UITableView Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AreaModel* zone = nil;
    if (tableView == _searchDispalyController.searchResultsTableView)
    {
        zone = (AreaModel*)[searchRes objectAtIndex:indexPath.row];
    }
    else
    {
        zone = (AreaModel*)[zonesArr objectAtIndex:indexPath.row];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate zoneDetailViewController:self didFinishSelectZone:zone];
    }];
}
- (void)selectAreaDone:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UISearchDispalyController delegate
//- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
//{
//    dispatch_async(dispatch_get_main_queue(), ^(void) {
//        for (UIView *v in controller.searchResultsTableView.subviews) {
//            if ([v isKindOfClass:[UILabel self]]) {
//                //((UILabel *)v).text = @"您搜索的圈子暂未开放,\r\n请关注其它圈子进入假面";
//                AlertContent(@"您搜索的圈子暂未开放,\r\n请关注其它圈子进入假面");
//                break;
//            }
//        }
//    });
//    return YES;
//}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if([searchText length] == 0)
        return;
    [searchRes removeAllObjects];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray* res = [[NetWorkConnect sharedInstance] areaList:0
                                                           maxId:INT_MAX
                                                           count:100
                                                        areaType:(int)_zoneType
                                                      filterType:1
                                                         keyWord:searchText];
        [searchRes addObjectsFromArray:res];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_searchDispalyController.searchResultsTableView reloadData];
        });
    });
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString* searchText = [searchBar text];
    if([searchText length] == 0)
        return;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray* res = [[NetWorkConnect sharedInstance] areaList:0 maxId:INT_MAX count:100 areaType:_zoneType filterType:2 keyWord:searchText];
        [searchRes removeAllObjects];
        [searchRes addObjectsFromArray:res];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_searchDispalyController.searchResultsTableView reloadData];
        });
    });
}
- (void)configureNavigationBar
{
    UINavigationBar* navigationBar = nil;
    if (IOS_NEWER_OR_EQUAL_TO_7)
    {
        navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44 + StatusBarHeight)];
        [self.tableView setContentInset:UIEdgeInsetsMake(StatusBarHeight, 0, 0, 0)];
        [navigationBar setBarTintColor:UIColorFromRGB(0x242730)];
        [navigationBar setTranslucent:NO];
    }
    else
    {
        navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        [navigationBar setTintColor:UIColorFromRGB(0x242730)];
    }
    [navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],
                                            NSForegroundColorAttributeName, nil]];
    UINavigationItem* navigationItem = [[UINavigationItem alloc] initWithTitle:@"选择你的圈子"];
    [navigationBar pushNavigationItem:navigationItem animated:YES];
    [self.view addSubview:navigationBar];
    
    UINavigationItem* backBtnItem = [[UINavigationItem alloc] initWithTitle:@"假面"];
    NSArray* items = [[NSArray alloc] initWithObjects:backBtnItem, navigationItem, nil];
    [navigationBar setItems:items animated:NO];
    navigationBar.delegate = self;
}
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    if ([item.title isEqualToString:@"选择你的圈子"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    return YES;
}

- (void)configureTableHeaderView:(int)scopeId
{
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
    if (_zoneType == ZoneTypeCompany) {
        [label setText:@"目前支持全国几十万家公司，以下是热门公司"];
    }else if (_zoneType == ZoneTypeIndustry){
        [label setText:@"目前支持全国几十个行业，以下是热门行业"];
    }else{
        [label setText:@"目前支持全国几千所学校，以下是热门学校"];
    }
    
    [label setTextColor:[UIColor lightGrayColor]];
    [label setFont:[UIFont systemFontOfSize:14]];
    [label sizeToFit];
    label.center = headerView.center;
    [headerView addSubview:label];
    [_tableView setTableHeaderView:headerView];
}
- (void)configureTableFooterView
{
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 5, 320, 40)];
    [btn setTitle:@"加载更多" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(loadMoreZones:) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundColor:UIColorFromRGB(0xff6f6f)];
    [footerView addSubview:btn];
    [_tableView setTableFooterView:footerView];
    _tableView.tableFooterView.userInteractionEnabled = YES;
    
}
- (void)loadMoreZones:(id)sender
{
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 35)];
    [SVProgressHUD setFont:[UIFont systemFontOfSize:16]];
    [SVProgressHUD showWithStatus:@"获取中..."];
    
    [self performSelector:@selector(loadMoreBtnPressHelp) withObject:nil afterDelay:0.5];
}
- (void)loadMoreBtnPressHelp
{
    AreaModel* zone = (AreaModel*)[zonesArr lastObject];
    NSArray* result = [[NetWorkConnect sharedInstance] areaList:zone.sequence
                                                          maxId:INT_MAX
                                                          count:20
                                                       areaType:(int)_zoneType
                                                     filterType:0
                                                        keyWord:nil];
    [SVProgressHUD dismiss];

    if ([result count]<1) {
        
        [UIAlertView showWithTitle:@"提示" message:@"以无更多!" cancelButtonTitle:@"确定" otherButtonTitles:nil tapBlock:nil  ];
        [_tableView.tableFooterView setHidden:YES];
    }else
    {
        [zonesArr addObjectsFromArray:result];
        [_tableView reloadData];


    }
}

// fix bug on ios7
- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}
- (void)keyboardWillHide {
    UITableView *tableView = [[self searchDisplayController] searchResultsTableView];
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}
@end
