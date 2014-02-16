//
//  ASDocument.m
//  Symbolicate
//
//  Created by John Holdsworth on 16/02/2014.
//  Copyright (c) 2014 John Holdsworth. All rights reserved.
//

#import "ASDocument.h"

@implementation ASDocument

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"ASDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
#if 1
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return nil;
#else
    return &OOString( text.string ).utf8Data();
#endif
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return YES;
}

- (BOOL)loadFileWrapperRepresentation:(NSFileWrapper *)wrapper ofType:(NSString *)type {
    NSString *path = [[self fileURL] path];
    if ( [path hasSuffix:@".xcarchive"] ) {
        for ( ASDocument *doc in [[NSDocumentController sharedDocumentController] documents] )
            if ( [[[doc fileURL] path] hasSuffix:@".crash"] )
                [doc symbolicate:path];
        return NO;
    }
    else
        return YES;
}

- (void)awakeFromNib {
    if ( [self fileURL] )
        text.string = OOFile( [self fileURL] ).string();
}

- (void)symbolicate:(NSString *)archive {
    OOString script = [[NSBundle mainBundle] resourcePath]+OO"/symbolicate.pl",
        command = @"'"+script+@"' '"+[[self fileURL] path]+@"' '"+archive+@"'", out;
    FILE *in = popen(command, "r");

    char buffer[PATH_MAX];
    while ( fgets( buffer, sizeof buffer, in ) )
        out += OOString( buffer );

    pclose( in );
    text.string = out;
}

@end
