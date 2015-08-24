//
//  DetailViewController.h
//  KayakExercise
//
//  Created by Er Li on 8/16/15.
//  Copyright (c) 2015 elieric. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@protocol FavoriteObjectDelegate <NSObject>
@optional
- (void)didUpdateFavoriteObject:(NSManagedObject *)objectToUpdate;
- (BOOL)checkIsFavoriteObject:(NSManagedObject *)objectToCheck;
@end

@interface DetailViewController : UIViewController<UITableViewDataSource,UITabBarDelegate,UIAlertViewDelegate>

@property (nonatomic) NSManagedObject *detailObject;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITableView *detailTable;
@property (weak, nonatomic) IBOutlet UIButton *favButton;
- (IBAction)toggleFavButton:(id)sender;
@property (nonatomic, weak) id <FavoriteObjectDelegate> delegate;

@end

