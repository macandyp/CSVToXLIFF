//
//  CSVOptionsViewController.h
//  CSVToXLIFF
//
//  Created by Andy Pereira on 11/12/15.
//  Copyright © 2015 Andy Pereira. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CSVOptionsViewController;

@protocol CSVOptionsDelegate <NSObject>
- (void)csvOptions:(CSVOptionsViewController*)viewController didSelectSourceField:(NSString*)source targetField:(NSString*)target andNoteField:(NSString*)notes;
@end

@interface CSVOptionsViewController : NSViewController
@property (nonatomic, assign) id<CSVOptionsDelegate> delegate;
@property (nonatomic) NSArray *options;
@end
