//
//  ViewController.h
//  iCLI - iCommand Line Interface
//
//  Created by Emily Jennyne Carroll Walls on 2014-04-22.
//  A UNIX-like "OS" for iOS
//

#import <UIKit/UIKit.h>
#import "ioSession.h"

@interface ViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UITextView * textview;
    IBOutlet UITextField * userText;
    NSString * currentDirectory;
    NSString * prevDirectory;
    NSString * ioSessionCommand;
    ioSession * theIOSession;
    BOOL inRmSession;
    NSString * fileToRM;
    NSString * contentsFromOpen;
}

@property (nonatomic, strong) UITextView * textview;
@property (nonatomic, strong) UITextField * userText;
@property (nonatomic, strong) NSString * currentDirectory;
@property (nonatomic, strong) NSString * prevDirectory;
@property (nonatomic, strong) NSString * ioSessionCommand;
@property (nonatomic, strong) ioSession * theIOSession;
@property (nonatomic) BOOL inRmSession;
@property (nonatomic, strong) NSString * fileToRM;
@property (nonatomic, strong) NSString * contentsFromOpen;

- (BOOL) textFieldShouldReturn:(UITextField *) textField;

@end
