//
//  ioSession.h
//  iCLI
//
//  Created by Emily Jennyne Carroll Walls on 2014-04-22.
//  A UNIX-like "OS" for iOS
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ioSession : NSObject <UITextFieldDelegate>
{
    NSString * fileName;
    NSString * filePath;
    NSString * fileContents;
    NSString * currMode; // e.g., i, a, etc.
    NSString * lastCommand; // e.g. :w, :q, :wq, etc.
    NSString * consoleOut;
    BOOL wasSaved;
    NSError * error;
}
@property (nonatomic, strong) NSString * fileName;
@property (nonatomic, strong) NSString * filePath;
@property (nonatomic, strong) NSString * fileContents;
@property (nonatomic, strong) NSString * currMode;
@property (nonatomic, strong, setter = setCommand:) NSString * lastCommand;
@property (nonatomic, strong) NSString * consoleOut;
@property (nonatomic) BOOL wasSaved;
@property NSError * error;

- (id) initWithName: (NSString *)fName andFPath:(NSString *)fPath;

- (NSError *) writeFile;
- (NSString *) readFile;
- (BOOL) doesFileExist: (NSString *) fName andFPath:(NSString *)fPath;
- (NSString *) respondToLastCommand;
- (void) setCommand: (NSString *) command;

@end
