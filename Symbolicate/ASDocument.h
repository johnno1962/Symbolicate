//
//  ASDocument.h
//  Symbolicate
//
//  Created by John Holdsworth on 16/02/2014.
//  Copyright (c) 2014 John Holdsworth. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ASDocument : NSDocument {
    IBOutlet NSTextView *text;
}

- (void)symbolicate:(NSString *)archive;

@end
