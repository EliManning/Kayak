//
//  MasterViewController.m
//  KayakExercise
//
//  Created by Er Li on 8/16/15.
//  Copyright (c) 2015 elieric. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import <AFHTTPRequestOperationManager.h>
#import <AFNetworking.h>
#import <UIImageView+AFNetworking.h>
#import <MBProgressHUD.h>
#import "Constant.h"
#import "AppDelegate.h"
#import "Airline.h"

static NSString *dataUrl = @"https://www.kayak.com/h/mobileapis/directory/airlines";
static NSString *kCellIndentifier = @"Cell";

@interface MasterViewController ()
@property (nonatomic) NSMutableArray *favObjects;
@property (nonatomic) NSMutableArray *objects;
@property (assign) BOOL showFavMode;
@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showFavMode = NO;
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate]managedObjectContext];
    [self getAllObjects];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Show Favorite" style:UIBarButtonItemStyleDone target:self action:@selector(toggleFavButton:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    if(self.showFavMode){
        [self getfavouriteObjects];
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark toggle buttons

-(void)toggleFavButton:(id)sender{
    
    if(!self.showFavMode){
        [self.navigationItem.rightBarButtonItem setTitle:@"Show All"];
        self.showFavMode = YES;
        [self getfavouriteObjects];
        [self.tableView reloadData];
    }
    else{
        [self.navigationItem.rightBarButtonItem setTitle:@"Show Favorite"];
        self.showFavMode = NO;
        [self.tableView reloadData];

    }
}

#pragma mark get items

-(NSMutableArray *)getfavouriteObjects{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Airline"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kJSONDataKeyCode ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavorite == %@", [NSNumber numberWithBool:YES]];
    [fetchRequest setPredicate:predicate];
    self.favObjects = [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    return self.favObjects;
}

-(void)getAllObjects{
    
    [self fetchDataWithUrlString:dataUrl block:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }
    }];
}

#pragma mark Parse Data

-(void)fetchDataWithUrlString:(NSString *)urlString  block:(void (^)(BOOL succeeded, NSError *error))completionBlock{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError *error = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
        
        if (error != nil) {
            completionBlock(NO, error);
        }
        else {
            self.objects =[self getParsedDataArray:jsonArray];
            completionBlock(YES, error);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"Loading Error", @"") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            completionBlock(NO, error);
        });
    }];
}

-(NSMutableArray *)getParsedDataArray:(NSArray *)JSONArray{
    
    NSMutableArray *parsedInfoArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dataDic in JSONArray) {
        NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"Airline" inManagedObjectContext:self.managedObjectContext];
        for (NSString *key in dataDic) {
            if ([object respondsToSelector:NSSelectorFromString(key)]) {
                [object setValue:[dataDic valueForKey:key] forKey:key];
            }
        }
        [parsedInfoArray addObject:object];
    }
    
    return parsedInfoArray;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        DetailViewController *detailVC = [segue destinationViewController];
        NSManagedObject *airlineObject ;
        if(self.showFavMode){
            airlineObject = [self.favObjects objectAtIndex:indexPath.row];
        }else{
            airlineObject = [self.objects objectAtIndex:indexPath.row];
        }
        [detailVC setDetailObject:airlineObject];
        detailVC.delegate = self;
    }
}

#pragma mark - Table View delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.showFavMode){
        return self.favObjects.count;
    }
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIndentifier forIndexPath:indexPath];
    
    NSManagedObject *airline;
    if(self.showFavMode){
        airline = [self.favObjects objectAtIndex:indexPath.row];
    }
    else{
        airline = [self.objects objectAtIndex:indexPath.row];
    }
    NSString *imageUrl = [kBaseURL stringByAppendingString:[airline valueForKey:kJSONDataKeyLogoURL]];
    [cell.imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cell.textLabel.text = [airline valueForKey:kJSONDataKeyName];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark delete delegate

-(void)didUpdateFavoriteObject:(NSManagedObject *)objectToUpdate{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
        return;
    }
}

-(BOOL)checkIsFavoriteObject:(NSManagedObject *)objectToCheck{
    
    NSMutableArray *favoriteObjects = [self getfavouriteObjects];
    
    for (NSManagedObject *object in favoriteObjects) {
        
        if([[object valueForKey:kJSONDataKeyCode] isEqualToString:[objectToCheck valueForKey:kJSONDataKeyCode]])
            return YES;
    }
    
    return NO;
}


@end
