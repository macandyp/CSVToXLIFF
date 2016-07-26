//
//  CSVOptionsViewController.m
//  CSVToXLIFF
//
//  Created by Andy Pereira on 11/12/15.
//  Copyright © 2015 Andy Pereira. All rights reserved.
//

#import "CSVOptionsViewController.h"

@interface CSVOptionsViewController ()
@property (weak) IBOutlet NSPopUpButton *sourcePopup;
@property (weak) IBOutlet NSPopUpButton *targetPopup;
@property (weak) IBOutlet NSPopUpButton *notePopup;
@end

@implementation CSVOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.sourcePopup removeAllItems];
    [self.targetPopup removeAllItems];
    [self.notePopup removeAllItems];
    
    [self.sourcePopup addItemsWithTitles:self.options];
    [self.targetPopup addItemsWithTitles:self.options];
    [self.notePopup addItemsWithTitles:self.options];
    if ([self.options containsObject:@"source"]) {
        [self.sourcePopup selectItemWithTitle:@"source"];
    }
    if ([self.options containsObject:@"target"]) {
        [self.targetPopup selectItemWithTitle:@"target"];
    }
    if ([self.options containsObject:@"note"]) {
        [self.notePopup selectItemWithTitle:@"note"];
    }
}

- (IBAction)convert:(id)sender {
    if (self.sourcePopup.selectedItem.title == self.targetPopup.selectedItem.title || self.sourcePopup.selectedItem.title == self.notePopup.selectedItem.title || self.targetPopup.selectedItem.title == self.notePopup.selectedItem.title) {
        NSLog(@"Selected same!");
        return;
    } else if (!self.sourcePopup.selectedItem || !self.targetPopup.selectedItem || !self.notePopup.selectedItem) {
        NSLog(@"Missing 1");
        return;
    }
    [self.delegate csvOptions:self didSelectSourceField:self.sourcePopup.selectedItem.title targetField:self.targetPopup.title andNoteField:self.notePopup.title];
}

@end
