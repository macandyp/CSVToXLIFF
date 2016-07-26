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

#import "ViewController.h"
#import "CHCSVParser.h"
#import "CSVOptionsViewController.h"

@interface ViewController ()<CHCSVParserDelegate, CSVOptionsDelegate>
@property (nonatomic) NSMutableArray *fields;
@property (nonatomic) NSXMLDocument *document;
@property (nonatomic) NSString *workingFileName;
@property (nonatomic) NSString *sourceKey;
@property (nonatomic) NSString *targetKey;
@property (nonatomic) NSString *noteKey;
@end

@implementation ViewController

#pragma mark - View Setup
- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - User Interaction
- (IBAction)csvToXLIFF:(id)sender {
    [self openCSV];
}

- (IBAction)xliffToCSV:(id)sender {
    [self openXLIFFWithCompletion:^(NSXMLDocument *document) {
        self.document = document;
        [self parseXLIFFToCSV];
    }];
}

#pragma mark - Open Dialogs
- (void)openCSV {
    NSOpenPanel *open = [NSOpenPanel openPanel];
    open.prompt = @"Open CSV";
    open.allowedFileTypes = @[@"csv"];
    [open beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            NSURL *csvURL = [[open URLs] objectAtIndex:0];
            self.fields = [NSMutableArray array];
            CHCSVParser *parser = [[CHCSVParser alloc] initWithContentsOfCSVURL:csvURL];
            parser.delegate = self;
            [parser parse];
        }
    }];
}

- (void)openXLIFFWithCompletion:(nonnull void(^)(NSXMLDocument *document))completion {
    NSOpenPanel *open = [NSOpenPanel openPanel];
    open.prompt = @"Open XLIFF";
    open.allowedFileTypes = @[@"xliff"];
    [open beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            NSURL *xliffURL = [[open URLs] objectAtIndex:0];
            self.workingFileName = xliffURL.lastPathComponent;
            NSError *error;
            NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:xliffURL options:0 error:&error];
            if (!error) {
                completion(xmlDoc);
            }
        }
    }];
}

#pragma mark - Save Dialogs
- (void)openSaveDialog {
    NSSavePanel *save = [NSSavePanel savePanel];
    save.allowedFileTypes = @[@"xliff"];
    if (![self.workingFileName.pathExtension isEqualToString:@"xliff"]) {
        self.workingFileName = [self.workingFileName stringByAppendingPathExtension:@"xliff"];
    }
    save.nameFieldStringValue = self.workingFileName;
    [save beginWithCompletionHandler:^(NSInteger result) {
        NSURL *saveURL = [save URL];
        NSData *saveString = [self.document XMLDataWithOptions:0];
        [saveString writeToURL:saveURL atomically:YES];
        
    }];
}

- (void)openCSVSaveDialogWithString:(NSString*)csvString {
    NSSavePanel *save = [NSSavePanel savePanel];
    save.allowedFileTypes = @[@"csv"];
    if ([self.workingFileName.pathExtension isEqualToString:@"xliff"]) {
        self.workingFileName = [self.workingFileName stringByDeletingPathExtension];
    }
    if (![self.workingFileName.pathExtension isEqualToString:@"csv"]) {
        self.workingFileName = [self.workingFileName stringByAppendingPathExtension:@"csv"];
    }
    save.nameFieldStringValue = self.workingFileName;
    [save beginWithCompletionHandler:^(NSInteger result) {
        NSURL *saveURL = [save URL];
        NSData *saveString = [csvString dataUsingEncoding:NSUTF8StringEncoding];
        [saveString writeToURL:saveURL atomically:YES];
        
    }];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

#pragma mark - Parse XML Document
- (void)parseTranslationsWithXML:(NSXMLDocument*)document {
    NSArray *files = [[document rootElement] elementsForName:@"file"];
    for (NSXMLElement *element in files) {
        NSString *name = [[element attributeForName:@"original"] stringValue];
        if ([name.lowercaseString containsString:@"plist"]/* || [name.lowercaseString containsString:@"test"]*/) {
            continue;
        }
        
        NSArray *children = [element elementsForName:@"body"];
        for (NSXMLElement *body in children) {
            NSArray *translations = [body elementsForName:@"trans-unit"];
            for (NSXMLElement *translation in translations) {
                NSString *source = @"";
                NSString *target = @"";
                BOOL hasTarget = NO;
                for (NSXMLNode *node in [translation children]) {
                    if ([node.name isEqualToString:@"source"]) {
                        source = node.stringValue;
                    } else if ([node.name isEqualToString:@"target"]) {
                        target = node.stringValue;
                        hasTarget = YES;
                    }
                }
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K ==[cd] %@ AND %K !=[cd] %@", self.sourceKey, source, self.targetKey, source];
                NSArray *filtered = [self.fields filteredArrayUsingPredicate:predicate];
                if (filtered.count > 0) {
                    NSDictionary *filteredTranslation = filtered[0];
                    if (filteredTranslation[self.targetKey] && [filteredTranslation[self.targetKey] length] > 0 && ![filteredTranslation[self.targetKey] isEqualToString:source]) {
                        target = filteredTranslation[self.targetKey];
                    }
                }
                
                if (!hasTarget) {
                    NSXMLElement *target = [NSXMLElement elementWithName:@"target"];
                    [translation addChild:target];
                }
                if (target.length == 0) {
                    target = source;
                }
                [[[translation elementsForName:@"target"] objectAtIndex:0] setStringValue:target];
                NSLog(@"%@ = %@", source, target);
            }
        }
    }
    [self openSaveDialog];
}

- (void)parseXLIFFToCSV {
    NSArray *files = [[self.document rootElement] elementsForName:@"file"];
    NSString *title = @"Source,Target,Note To Translator\n";
    NSMutableString *string = [[NSMutableString alloc] init];
    for (NSXMLElement *element in files) {
        NSString *name = [[element attributeForName:@"original"] stringValue];
        if ([name.lowercaseString containsString:@"plist"] || [name.lowercaseString containsString:@"test"]) {
            continue;
        }
        
        NSArray *children = [element elementsForName:@"body"];
        for (NSXMLElement *body in children) {
            NSArray *translations = [body elementsForName:@"trans-unit"];
            for (NSXMLElement *translation in translations) {
                NSString *source = @"";
                NSString *target = @"";
                NSString *note = @"";
                BOOL hasTarget = NO;
                for (NSXMLNode *node in [translation children]) {
                    if ([node.name isEqualToString:@"source"]) {
                        source = node.stringValue;
                    } else if ([node.name isEqualToString:@"target"]) {
                        target = node.stringValue;
                        hasTarget = YES;
                    } else if ([node.name isEqualToString:@"note"]) {
                        note = node.stringValue;
                    }
                }
                if (source.length == 0) {
                    continue;
                }
                [string appendString:[NSString stringWithFormat:@"%@,%@,%@\n", source, target, note]];
            }
        }
    }
    
    [self openCSVSaveDialogWithString:[title stringByAppendingString:[string copy]]];
}

#pragma mark - CHCSV Delegate
- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    [self.fields addObject:[NSMutableDictionary dictionary]];
}

- (void)parserDidEndDocument:(CHCSVParser *)parser {
    [self openXLIFFWithCompletion:^(NSXMLDocument *document) {
        self.document = document;
        [self performSegueWithIdentifier:@"CSVOptions" sender:self];
    }];
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    if (self.fields.count == 1) {
        NSMutableDictionary *dict = self.fields.lastObject;
        dict[@(fieldIndex)] = field;
    } else {
        NSDictionary *fieldInfo = self.fields[0];
        NSString *key = fieldInfo[@(fieldIndex)];
        if (key.length > 0) {
            NSMutableDictionary *dict = self.fields.lastObject;
            dict[key] = field;
        }
    }
}

#pragma mark - CSV Delegate
- (void)csvOptions:(CSVOptionsViewController*)viewController didSelectSourceField:(NSString *)source targetField:(NSString *)target andNoteField:(NSString *)notes {
    self.sourceKey = source;
    self.targetKey = target;
    self.noteKey = notes;
    [self dismissViewController:viewController];
    [self parseTranslationsWithXML:self.document];
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CSVOptions"]) {
        CSVOptionsViewController *upcoming = segue.destinationController;
        upcoming.delegate = self;
        upcoming.options = [self.fields[0] allValues];
    }
}

@end
