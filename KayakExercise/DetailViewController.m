//
//  DetailViewController.m
//  KayakExercise
//
//  Created by Er Li on 8/16/15.
//  Copyright (c) 2015 elieric. All rights reserved.
//

#import "DetailViewController.h"
#import <UIImageView+AFNetworking.h>
#import <MBProgressHUD.h>
#import "Constant.h"
#import <DZNWebViewController.h>
#import <CoreData/CoreData.h>
#import "Airline.h"
#import "AppDelegate.h"

#define kPhoneIndex 0
#define kWebsiteIndex 1
#define kPhoneCallAlertTag 0
#define kFavoriteAlertTag 1
#define kUnFavouriteAlertTag 2

@interface DetailViewController ()
@property (nonatomic) NSArray *detailArray;
@property (assign) BOOL isMarkedFavorite;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        // Update the view.
        [self configureView];
    }
}

-(void)setManagedObject:(NSManagedObject *)managedObject{
    
    if (_managedObject != managedObject) {
        _managedObject = managedObject;
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {

    if (self.managedObject) {
        self.nameLabel.text = [self.managedObject valueForKey:kJSONDataKeyName];
        NSString *imageUrl = [kBaseURL stringByAppendingString:[self.managedObject valueForKey:kJSONDataKeyLogoURL]];
        [self.logoImageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        self.detailArray = [NSArray arrayWithObjects:[self.managedObject valueForKey:kJSONDataKeyPhone],[self.managedObject valueForKey:kJSONDataKeySite],nil];
        self.detailTable.scrollEnabled = NO;
        if([self.managedObject valueForKey:kJSONDataKeyIsFavorite]){
            [self.favButton setTitle:@"Favorite" forState:UIControlStateNormal];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.detailArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *kDetailCellIndentifier = @"DetailCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDetailCellIndentifier];
    
    if(cell == nil){
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDetailCellIndentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if(indexPath.row == kPhoneIndex)
          cell.textLabel.text = [NSString stringWithFormat:@"Phone: %@", [self.managedObject valueForKey:kJSONDataKeyPhone]];
        else if(indexPath.row == kWebsiteIndex)
          cell.textLabel.text = [NSString stringWithFormat:@"Website: %@", [self.managedObject valueForKey:kJSONDataKeySite]];;
        
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == kPhoneIndex){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:[NSString stringWithFormat:@"%@ %@?",NSLocalizedString(@"Make a call to ", @""),[self.managedObject valueForKey:kJSONDataKeyPhone]] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alertView.tag = kPhoneCallAlertTag;
        [alertView show];
    }
    else if (indexPath.row == kWebsiteIndex){
        
        NSString* stringURL = [NSString stringWithFormat:@"%@", [@"http://" stringByAppendingString:[self.managedObject valueForKey:kJSONDataKeySite]]];
        NSString* webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL* url = [NSURL URLWithString:webStringURL];
        DZNWebViewController *WVC = [[DZNWebViewController alloc] initWithURL:url];
        [self.navigationController pushViewController:WVC animated:YES];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == kPhoneCallAlertTag){
        
        if(buttonIndex == 1){
            NSString *phoneNumber = [@"tel://" stringByAppendingString:[self removeSpaceFromPhoneNumberString:self.dataObject.phone]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
        }
    }
    else if(alertView.tag == kFavoriteAlertTag){
        
        if(buttonIndex == 1){
            
            if(self.managedObject){
                                
                [self.delegate didInsertFavoriteObject:self.managedObject];
                
                [self.favButton setTitle:@"Favorite" forState:UIControlStateNormal];

            }
        }
    }
    else if(alertView.tag == kUnFavouriteAlertTag){
        
        if(buttonIndex == 1){
            
            if(self.managedObject){
                                
                [self.delegate didRemoveFavoriteObject:self.managedObject];
                
                [self.favButton setTitle:@"Mark as favorite" forState:UIControlStateNormal];

            }
        }
    }
}

- (IBAction)toggleFavButton:(id)sender {
    
    if([self.managedObject valueForKey:kJSONDataKeyIsFavorite]){
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"Unfavorite?", @"")delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alertView.tag = kUnFavouriteAlertTag;
        [alertView show];
        
    }
    else{
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"Marked as favorite?", @"")delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alertView.tag = kFavoriteAlertTag;
        [alertView show];
    }
    
}


-(NSString *)removeSpaceFromPhoneNumberString:(NSString *)phoneNumber{
    
    return [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    
}


@end
