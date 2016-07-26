/*
 Copyright (c) 2016 Andrew Pereira
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

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
