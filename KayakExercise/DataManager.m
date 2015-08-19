//
//  DataManager.m
//  KayakExercise
//
//  Created by Er Li on 8/16/15.
//  Copyright (c) 2015 elieric. All rights reserved.
//

#import "DataManager.h"
#import "DataObject.h"
@implementation DataManager

+(DataManager *)sharedInstance{
    
    static DataManager *_sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[DataManager alloc] init];
        
    });
    
    return _sharedInstance;
    
}

-(NSArray *)parseInfoFromJSON:(NSData *)JSONData error:(NSError **)error {
    
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableArray *parsedInfoArray = [[NSMutableArray alloc] init];
    
    NSArray *results = [parsedObject valueForKey:@"results"];
    
    for (NSDictionary *dataDic in results) {
        DataObject *object = [[DataObject alloc] init];
        
        for (NSString *key in dataDic) {
            if ([object respondsToSelector:NSSelectorFromString(key)]) {
                [object setValue:[dataDic valueForKey:key] forKey:key];
            }
        }
        
        [parsedInfoArray addObject:object];
    }
    
    return parsedInfoArray;
    
}

@end
