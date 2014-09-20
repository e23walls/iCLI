//
//  ioSession.m
//  iCLI
//
//  Created by Emily Jennyne Carroll Walls on 2014-04-22.
//  A UNIX-like "OS" for iOS
//

#import "ioSession.h"
#define STRINGENCODING NSUTF8StringEncoding

@implementation ioSession

@synthesize fileName, filePath, fileContents, currMode, lastCommand, consoleOut, wasSaved, error;
- (id) initWithName:(NSString *)fName andFPath:(NSString *)fPath // fName should include file extension
{
    self = [super init];
    if (self != nil)
    {
        fileName = fName;
        filePath = fPath;
        wasSaved = NO;
    }
    return self;
}
- (NSString *) readFile
{
    if ([self doesFileExist:fileName andFPath:filePath] == YES)
    {
        NSError * e = nil;
        fileContents = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@%@", filePath, fileName] encoding:STRINGENCODING error:&e];
        error = e;
        if (error != nil)
        {
            NSLog(@"Error reading file \"%@\": %@", fileName, error);
            if ([error code] == 257)
                return @"Permission denied";
            else
                return @"Unspecified error";
        }
        else
        {
            return fileContents;
        }
    }
    
    return nil;
}
- (NSError *) writeFile
{
    error = nil;
    NSLog(@"User wishes to save changes to file %@", fileName);
    // We can assume the path is legal, but we still need to make sure an error doesn't occur
    NSError * e;
    NSString * fullPath = [NSString stringWithFormat:@"%@%@", filePath, fileName];
    [fileContents writeToFile:fullPath atomically:YES encoding:STRINGENCODING error:&e];
    error = e;
    if (error != nil)
    {
        //NSLog(@"File write was unsuccessful: %@", [[error userInfo] objectForKey:@"NSUnderlyingError"]);
        NSLog(@"%@", [error description]);
    }
    return error;
}
- (NSString *) respondToLastCommand // commands given in the vim-like program, not in the main one, so no reading
{
    if ([lastCommand hasPrefix:@":qw"] || [lastCommand hasPrefix:@":w"])
    {
        [self writeFile];
    }
    // else, command doesn't exist or isn't implemented yet, (or does nothing here, like :q) so do nothing
    return nil;
}
- (BOOL) doesFileExist:(NSString *)fName andFPath:(NSString *)fPath
{
    return ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@", filePath, fileName]]);
}
- (void) setCommand:(NSString *)command
{
    lastCommand = command;
}

@end
