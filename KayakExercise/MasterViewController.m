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
#import "DataObject.h"
#import <UIImageView+AFNetworking.h>
#import <MBProgressHUD.h>
#import "Constant.h"
#import "AppDelegate.h"
#import "Airline.h"

static NSString *dataUrl = @"https://www.kayak.com/h/mobileapis/directory/airlines";
static NSString *kCellIndentifier = @"Cell";

@interface MasterViewController ()
@property NSMutableArray *objects;
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
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark get favorite

-(void)toggleFavButton:(id)sender{
    
    if(!self.showFavMode){
        
        [self.navigationItem.rightBarButtonItem setTitle:@"Show All"];
        self.showFavMode = YES;
        [self getfavouriteObjects];
        
    }
    else{
        
        [self.navigationItem.rightBarButtonItem setTitle:@"Show Favorite"];
        self.showFavMode = NO;
        [self getAllObjects];
        
    }
    
}

-(void)getfavouriteObjects{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Airline"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kJSONDataKeyCode ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavorite == %@", [NSNumber numberWithBool:YES]];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setPredicate:predicate];
    self.objects = [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    [self.tableView reloadData];
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
        NSManagedObject *airlineObject = [self.objects objectAtIndex:indexPath.row];
        [detailVC setManagedObject:airlineObject];
        detailVC.delegate = self;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIndentifier forIndexPath:indexPath];
    
    NSManagedObject *airline = [self.objects objectAtIndex:indexPath.row];
    NSString *imageUrl = [kBaseURL stringByAppendingString:[airline valueForKey:kJSONDataKeyLogoURL]];
    [cell.imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cell.textLabel.text = [airline valueForKey:kJSONDataKeyName];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark delete delegate

- (void)didRemoveFavoriteObject:(NSManagedObject *)objectToRemove{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    [objectToRemove setValue:[NSNumber numberWithBool:NO] forKey:kJSONDataKeyIsFavorite];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
        return;
    }
    else{
        NSLog(@"Saved %@", objectToRemove);
    }
    
    [self.tableView reloadData];
    
}

-(void)didInsertFavoriteObject:(NSManagedObject *)objectToAdd{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    [objectToAdd setValue:[NSNumber numberWithBool:YES] forKey:kJSONDataKeyIsFavorite];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Can't add! %@ %@", error, [error localizedDescription]);
        return;
    }
    else{
        NSLog(@"Saved %@", objectToAdd);
    }
    
    [self.tableView reloadData];
    
}


@end
