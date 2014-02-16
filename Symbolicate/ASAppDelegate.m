//
//  ASAppDelegate.m
//  Symbolicate
//
//  Created by John Holdsworth on 16/02/2014.
//  Copyright (c) 2014 John Holdsworth. All rights reserved.
//

#import "ASAppDelegate.h"
#import "ASDocument.h"

@implementation ASAppDelegate

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename {
    NSDocumentController *dc = [NSDocumentController sharedDocumentController];
    return [dc openDocumentWithContentsOfFile:filename display:YES] != nil || YES;
}

@end
