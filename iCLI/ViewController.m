//
//  ViewController.m
//  iCLI - iCommand Line Interface
//
//  Created by Emily Jennyne Carroll Walls on 2014-04-22.
//  A UNIX-like "OS" for iOS
//

#import "ViewController.h"

#define IS_IPHONE (!IS_IPAD)
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)

@interface ViewController ()

@end

@implementation ViewController

@synthesize textview, userText, currentDirectory, prevDirectory, ioSessionCommand;
@synthesize theIOSession, fileToRM, inRmSession, contentsFromOpen;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //[self outputText:@"\t\t      iCLI\n\n"];
    
    userText.delegate = self;
    
    [self outputText:[NSString stringWithFormat:@"%@: ~%@$ ", [[UIDevice currentDevice] name], [[UIDevice currentDevice] name]]];
    textview.editable = NO;
    currentDirectory = @"/";
    prevDirectory = @"/";
    inRmSession = NO;
    textview.layoutManager.allowsNonContiguousLayout = NO;
    userText.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@">" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITextField Delegate
- (BOOL) textFieldShouldReturn:(UITextField *)textField // enter is tapped
{
    userText.placeholder = @">";
    if (theIOSession == nil)
    {
        NSString * toAdd = userText.text;
        [self outputText:[NSString stringWithFormat:@"%@\n", toAdd]];
        userText.text = @"";
        [self getCommand:toAdd];
    }
    else
    {
        ioSessionCommand = userText.text;
        theIOSession.lastCommand = ioSessionCommand;
        userText.text = @"";
        if ([ioSessionCommand isEqualToString:@":q"])
        {
            if ([textview.text isEqualToString:contentsFromOpen])
            {
                userText.placeholder = @">";
                textview.text = theIOSession.consoleOut;
                textview.editable = NO;
                theIOSession = nil;
                [self outputText:[NSString stringWithFormat:@"%@: ~%@$ ", [[UIDevice currentDevice] name], [[UIDevice  currentDevice] name]]];
            }
            else
            {
                userText.placeholder = @"Unsaved changes! Add ! to override.";
            }
        }
        else
        {
            userText.text = @"";
            [self setUserTextPlaceholder:@""];
            theIOSession.fileContents = textview.text;
            [theIOSession respondToLastCommand];
            contentsFromOpen = textview.text;
            if (theIOSession.error != nil)
            {
                if ([theIOSession.error code] == 513)
                {
                    [self setUserTextPlaceholder:[NSString stringWithFormat:@"Permission denied."]];
                }
                else
                {
                    [self setUserTextPlaceholder:[NSString stringWithFormat:@"Error."]];
                }
            }
            else if (([ioSessionCommand hasPrefix:@":qw"] || [ioSessionCommand hasPrefix:@":wq"]) && theIOSession.error == nil)
            {
                [self setUserTextPlaceholder:@">"];
                textview.text = theIOSession.consoleOut;
                textview.editable = NO;
                theIOSession = nil;
                [self outputText:[NSString stringWithFormat:@"%@: ~%@$ ", [[UIDevice currentDevice] name], [[UIDevice currentDevice] name]]];
            }
            else if ([ioSessionCommand hasPrefix:@":q!"] || [ioSessionCommand hasPrefix:@":wq!"] || ([textview.text length] == 0 && ([ioSessionCommand hasPrefix:@":q"] || [ioSessionCommand hasPrefix:@":wq"])))
            {
                [self setUserTextPlaceholder:@">"];
                textview.text = theIOSession.consoleOut;
                textview.editable = NO;
                theIOSession = nil;
                [self outputText:[NSString stringWithFormat:@"%@: ~%@$ ", [[UIDevice currentDevice] name], [[UIDevice currentDevice] name]]];
            }
            else if (([ioSessionCommand hasPrefix:@":q!"] || [ioSessionCommand hasPrefix:@":wq!"]))
            {
                [self setUserTextPlaceholder:@">"];
                textview.text = theIOSession.consoleOut;
                textview.editable = NO;
                theIOSession = nil;
                [self outputText:[NSString stringWithFormat:@"%@: ~%@$ ", [[UIDevice currentDevice] name], [[UIDevice  currentDevice] name]]];
            }
            else if ([ioSessionCommand hasPrefix:@":h"] || [ioSessionCommand hasPrefix:@"h"])
            {
                [self setUserTextPlaceholder:[NSString stringWithFormat:@"Quit :q, Save :w Quit + Save :wq or :qw, Help :h"]];
            }
            else if ([ioSessionCommand hasPrefix:@":w"] == NO) // different command
            {
                [self setUserTextPlaceholder:[NSString stringWithFormat:@"Unknown command: %@", ioSessionCommand]];
            }
            else
            {
                [self setUserTextPlaceholder:@""];
            }
        }
    }
    [self scrollOutputToBottom];
    return NO;
}
- (void) setUserTextPlaceholder:(NSString *) placeholderText
{
    userText.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholderText attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
}
// Does the animated scrolling look cool, or is it annoying?
- (void) scrollOutputToBottom
{
    [textview scrollRangeToVisible:NSMakeRange([textview.text length], 0)];
}

#pragma mark - Commands
- (void) outputText: (NSString *) text
{
//    textview.scrollEnabled = NO;
    textview.text = [textview.text stringByAppendingString:[NSString stringWithFormat:@"%@", text]];
//    textview.scrollEnabled = YES;
}
- (void) getCommand: (NSString *) command
{
    // based on contents of userText, do something
    // commands to implement: ls, cd, vim (make main text field editable), uname
    if ([command rangeOfString:@"uname"].location != NSNotFound)
    {
        [self uname];
    }
    else if ([command hasPrefix:@"cd "])
    {
        [self changeDir:[command substringFromIndex:[@"cd " length]]];
    }
    else if ([command hasPrefix:@"ls"])
    {
        if ([command hasSuffix:@"ls"])
            [self listFiles:nil];
        else
            [self listFiles:[command substringFromIndex:[@"ls " length]]];
    }
    else if ([command hasPrefix:@"pwd"] && [command hasSuffix:@"pwd"])
    {
        [self printWorkingDir];
    }
    else if ([command hasPrefix:@"vim "])
    {
        [self vimSimulator:[command substringFromIndex:[@"vim " length]]];
    }
    else if ([command hasPrefix:@"emacs "])
    {
        [self vimSimulator:[command substringFromIndex:[@"emacs " length]]];
    }
    else if ([command hasPrefix:@"vi "])
    {
        [self vimSimulator:[command substringFromIndex:[@"vi " length]]];
    }
    else if ([command hasPrefix:@"h"])
    {
        [self outputText:@"Implemented Commands:\n"];
        [self outputText:@"ls [-l] [-F]\nuname\ncd\npwd\nvim\nemacs\n"];
        [self outputText:@"echo\nrm [-i]\nwhoami\nmkdir\n"];
    }
    else if ([command hasPrefix:@"echo "])
    {
        // TODO: fix this -- have variables and regex and what not
        [self outputText:[command substringFromIndex:5]];
        [self outputText:@"\n"];
    }
    else if ([command isEqualToString:@"whoami"])
    {
        [self outputText:@"mobile\n"]; // is there a way to get this information programmatically?
    }
    else if ([command hasPrefix:@"rm "])
    {
        [self remove:[command substringFromIndex:[@"rm " length]]];
    }
    else if ([command rangeOfString:@"logout"].location != NSNotFound && [command hasSuffix:@"logout"])
    {
        [self outputText:@"\n[Process completed]\n"];
    }
    else if ([command hasPrefix:@"mkdir "])
    {
        [self mkdir:[command substringFromIndex:[@"mkdir " length]]];
    }
    else if ([command length] == 0)
    {
        // do nothing
    }
    else if (inRmSession == YES)
    {
        if ([[command lowercaseString] hasPrefix:@"y"] || [[command lowercaseString] hasSuffix:@"y"])
        {
            [self remove:fileToRM];
        }
        inRmSession = NO;
    }
    // keep checking for commands...
    else
    {
        NSRange r = [command rangeOfString:@" "];
        if (r.location != NSNotFound)
        {
            command = [command substringToIndex:r.location];
        }
        [self outputText:[NSString stringWithFormat:@"-bash: %@: command not found\n", command]];
        // play some sound indicating this is illegal... maybe
    }
    
    // when command is done:
    if (theIOSession == nil && inRmSession == NO) // only in normal mode
        [self outputText:[NSString stringWithFormat:@"%@: ~%@$ ", [[UIDevice currentDevice] name], [[UIDevice currentDevice] name]]];
}
- (NSString *) getFileInformation: (NSString *) filePath
{
    NSString * attributeString = [NSString stringWithFormat:@""];
    NSError * error;
    NSDictionary * attributesList = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
    if (error != nil)
    {
        NSLog(@"Error getting file permissions for %@\n%@", filePath, [error description]);
        // return nil;
    }
    
    if ([[attributesList objectForKey:@"NSFileType"] isEqualToString:@"NSFileTypeDirectory"])
        attributeString = [attributeString stringByAppendingString:@"d"];
    else
        attributeString = [attributeString stringByAppendingString:@"-"];
    int dec = [[attributesList objectForKey:@"NSFilePosixPermissions"] shortValue];
    int * perm = [self convertDecIntToOct:dec];
    // only care about 3 LSB
    for (int i = 1; i < 4; i++)
    {
        switch (perm[i]) {
            case 0:
                attributeString = [attributeString stringByAppendingString:@"---"];
                break;
            case 1:
                attributeString = [attributeString stringByAppendingString:@"--x"];
                break;
            case 2:
                attributeString = [attributeString stringByAppendingString:@"-w-"];
                break;
            case 3:
                attributeString = [attributeString stringByAppendingString:@"-wx"];
                break;
            case 4:
                attributeString = [attributeString stringByAppendingString:@"r--"];
                break;
            case 5:
                attributeString = [attributeString stringByAppendingString:@"r-x"];
                break;
            case 6:
                attributeString = [attributeString stringByAppendingString:@"rw-"];
                break;
            case 7:
                attributeString = [attributeString stringByAppendingString:@"rwx"];
                break;
            default:
                NSLog(@"Something went wrong with permissions!\n");
                break;
        }
    }
    free(perm);
    attributeString = [attributeString stringByAppendingString:@" "];
    attributeString = [attributeString stringByAppendingString:[NSString stringWithFormat:@"%@", [attributesList objectForKey:@"NSFileOwnerAccountName"]]];
    attributeString = [attributeString stringByAppendingString:@" "];
    attributeString = [attributeString stringByAppendingString:[NSString stringWithFormat:@"%@", [attributesList objectForKey:@"NSFileGroupOwnerAccountName"]]];
    attributeString = [attributeString stringByAppendingString:@" "];
    attributeString = [attributeString stringByAppendingString:[NSString stringWithFormat:@"%@", [attributesList objectForKey:@"NSFileSize"]]];
    attributeString = [attributeString stringByAppendingString:@" "];
    attributeString = [attributeString stringByAppendingString:[NSString stringWithFormat:@"%@", [attributesList objectForKey:@"NSFileModificationDate"]]];
    attributeString = [attributeString stringByAppendingString:@" "];
    
    if (error != nil)
        attributeString = [attributeString stringByReplacingOccurrencesOfString:@"(null)" withString:@"(error)"];
    
    return attributeString;
}
- (int *) convertDecIntToOct: (unsigned long) decLong
{
    int * octalNum = malloc(sizeof(int) * 4);
    octalNum[0] = 0;
    octalNum[1] = 0;
    octalNum[2] = 0;
    octalNum[3] = 0;
    int i = 0;
    unsigned long quotient = decLong;
    int result = 0;
    while (quotient != 0)
    {
        octalNum[i++] = quotient % 8;
        quotient = quotient / 8;
    }
    for (int j = i - 1; j >= 0; j--) // remember: octalNum is backwards!
    {
        result += octalNum[j] * pow(10.0, j);
    }
    int * actual = malloc(sizeof(int) * 4);
    actual[0] = octalNum[3]; // perhaps more efficient than a loop, though not a good way to do it normally!
    actual[1] = octalNum[2];
    actual[2] = octalNum[1];
    actual[3] = octalNum[0];
    free(octalNum);
    NSLog(@"result = %d", result);
    
    return actual;
}
- (void) uname
{
    NSString * device;
    if (IS_IPAD)
        device = [NSString stringWithFormat:@"iPad"];
    else
        device = [NSString stringWithFormat:@"iPhone"];
    [self outputText:[NSString stringWithFormat:@"%@ iOS %@\n", device, [[UIDevice currentDevice] systemVersion]]];
}
- (void) printWorkingDir
{
    [self outputText:currentDirectory];
    [self outputText:@"\n"];
}
- (void) vimSimulator: (NSString *) fileName
{   
    NSString * fullPath = [NSString stringWithFormat:@"%@%@", currentDirectory, fileName];
    
    theIOSession = [[ioSession alloc] initWithName:fileName andFPath:currentDirectory];
    theIOSession.consoleOut = textview.text;
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:NO])
    {
        NSString * content = [theIOSession readFile];
        if (theIOSession.error == nil)
        {
            textview.text = content;
            textview.editable = YES;
            contentsFromOpen = content;
        }
        else
        {
            [self outputText:[NSString stringWithFormat:@"The operation could not be completed. %@\n", content]];
            theIOSession = nil;
        }
    }
    else
    {
        NSLog(@"User wishes to write file: %@", fileName);
        // only save when user chooses command to save
        textview.text = @"";
        textview.editable = YES;
    }
    // when done, user sends command :q and then textview.text = prevConsoleOutput;
}
- (void) remove: (NSString *) fileName
{
    inRmSession = NO;
    BOOL warning = NO;
    if ([fileName rangeOfString:@"-i "].location != NSNotFound)
    {
        warning = YES;
        fileName = [fileName substringFromIndex:[@"-i " length]];
    }
    NSString * fullName = [NSString stringWithFormat:@"%@%@", currentDirectory, fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullName])
    {
        NSError * error;
        if (warning == YES)
        {
            inRmSession = YES;
            fileToRM = fileName;
            [self outputText:[NSString stringWithFormat:@"remove %@? ", fileName]];
            // if next input is 'y', remove file; otherwise, do nothing
        }
        else
        {
            [[NSFileManager defaultManager] removeItemAtPath:fullName error:&error];
            if (error != nil)
            {
                if ([error code] == 513)
                    [self outputText:@"The operation could not be completed. Permission denied\n"];
                else
                    [self outputText:@"The operation could not be completed"];
            }
        }
    }
    else
    {
        [self outputText:[NSString stringWithFormat:@"rm: %@: No such file or directory\n", fileName]];
    }
}
- (void) mkdir: (NSString *) dir
{
    NSString * fullDir = nil;
    if ([dir hasPrefix:@"/"])
    {
        fullDir = dir;
    }
    else
    {
        if ([currentDirectory hasSuffix:@"/"])
        {
            fullDir = [currentDirectory stringByAppendingString:dir];
        }
        else
        {
            fullDir = [currentDirectory stringByAppendingString:@"/"];
            fullDir = [fullDir stringByAppendingString:dir];
        }
    }
    NSLog(@"Creating directory '%@'", fullDir);
    
    // make directory at path 'fullDir'
    NSFileManager * fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:fullDir])
    {
        [self outputText:[NSString stringWithFormat:@"mkdir: %@: File exists", fullDir]];
    }
    else
    {
        NSError * error;
        [fm createDirectoryAtPath:fullDir withIntermediateDirectories:NO attributes:nil error:&error];
        
        if (error != nil)
        {
            NSString * parent = [dir stringByDeletingLastPathComponent];
            // Compare error codes against raw integers to determine error
            if ([error code] == 513)
                [self outputText:[NSString stringWithFormat:@"mkdir: %@: Error: permission denied\n", dir]];
            else if ([error code] == 512)
                [self outputText:[NSString stringWithFormat:@"-bash: mkdir: %@: Not a directory\n", parent]];
            else if ([error code] == 4)
                [self outputText:[NSString stringWithFormat:@"-bash: mkdir: %@: No such file or directory\n", parent]];
            else
                [self outputText:[NSString stringWithFormat:@"-bash: mkdir: %@\n", error]];
        }
        else
        {
            NSLog(@"Success!");
        }
    }
}
- (void) changeDir: (NSString *) dir
{
    if ([dir hasSuffix:@"/"] == NO && [dir hasPrefix:@"-"] == NO && [dir hasPrefix:@".."] == NO)
    {
        dir = [NSString stringWithFormat:@"%@/", dir];
    }
    
    if ([dir hasPrefix:@"/"]) // go to exact address
    {
        // if change is successful, set currentDirectory = dir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:dir])
        {
            currentDirectory = dir;
            prevDirectory = currentDirectory;
        }
        else
        {
            [self outputText:[NSString stringWithFormat:@"-bash: cd: %@: No such file or directory\n", dir]];
        }
    }
    else if ([dir hasPrefix:@"-"]) // go to previous directory
    {
        NSString * temp = prevDirectory;
        prevDirectory = currentDirectory;
        currentDirectory = temp;
        [self printWorkingDir];
    }
    else if ([dir hasPrefix:@".."])
    {
        if ([currentDirectory length] > 1) // otherwise, we're in the root, which has no parent!
        {
            NSString * temp = currentDirectory;
            temp = [temp substringToIndex:([temp length] - 1)];
            while ([temp hasSuffix:@"/"] == NO)
            {
                temp = [temp substringToIndex:([temp length] - 1)];
            }
            prevDirectory = currentDirectory;
            currentDirectory = temp;
            if ([dir length] > [@"../" length])
            {
                currentDirectory = [currentDirectory stringByAppendingString:[dir substringFromIndex:[@"../" length]]];
            }
        }
        [self printWorkingDir];
    }
    else // append dir to current directory
    {
        // if change is successful, set currentDirectory = dir
        NSString * newDir = [NSString stringWithFormat:@"%@%@", currentDirectory, dir];
        BOOL isDir = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:newDir isDirectory:&isDir])
        {
            prevDirectory = currentDirectory;
            currentDirectory = newDir;
        }
        else
            [self outputText:[NSString stringWithFormat:@"-bash: cd: %@: No such file or directory\n", dir]];
    }
}
- (void) listFiles: (NSString *) flags
{
    NSString * dir = @"";
    if (flags == nil)
        flags = @"";
    BOOL moreInfo = NO;
    BOOL longList = NO;
    if ([flags length] > 0)
    {
        moreInfo = [flags rangeOfString:@"-F"].location != NSNotFound;
        longList = [flags rangeOfString:@"-l"].location != NSNotFound;
        if ([flags rangeOfString:@"-Fl"].location != NSNotFound || [flags rangeOfString:@"-lF"].location != NSNotFound)
        {
            moreInfo = YES;
            longList = YES;
        }
        if ([flags rangeOfString:@" "].location != NSNotFound)
        {
            dir = [flags substringFromIndex:[flags rangeOfString:@" "].location + 1];
        }
        else if ([flags rangeOfString:@"-"].location == NSNotFound)
        {
            dir = flags;
        }
    }
    NSArray * directoryList = nil;
    NSString * fullDir = @"/";
    if ([dir isEqualToString:@""])
    {
        directoryList = [self listFileAtPath:currentDirectory];
    }
    else
    {
        if ([dir hasPrefix:@"/"])
        {
            // Chosen directory is an absolute path.
            fullDir = dir;
        }
        else
        {
            if ([dir hasSuffix:@"/"])
            {
                // Add '/' to end of current directory, then add
                // selected directory (dir).
                NSString * cd = [currentDirectory stringByAppendingString:@"/"];
                fullDir = [cd stringByAppendingString:dir];
            }
            else
            {
                // Otherwise, the selected directory (dir) can just
                // be appended without needing a forward slash.
                fullDir = [currentDirectory stringByAppendingString:dir];
            }
        }
        // To simplify the code for listing file information
        fullDir = [fullDir stringByAppendingString:@"/"];
        // If the directory does not exist, the function listFileAtPath
        // handles this exception.
        directoryList = [self listFileAtPath:fullDir];
    }
    for (int i = 0; i < [directoryList count]; i++)
    {
        NSString * currentFile = [directoryList objectAtIndex:i];
        if (longList == YES)
        {
            if (![currentFile hasPrefix:@"/"])
            {
                NSLog(@"Parent path = %@", fullDir);
                NSString * fullPathFile = [fullDir stringByAppendingString:currentFile];
                [self outputText:[self getFileInformation:fullPathFile]];
            }
            else
            {
                [self outputText:[self getFileInformation:currentFile]];
            }
        }
        [self outputText:[directoryList objectAtIndex:i]];
        if (moreInfo == YES)
        {
            NSString * lowCurrFile = [currentFile lowercaseString];
            if ([lowCurrFile hasSuffix:@".txt"] || [lowCurrFile hasSuffix:@".plist"] || [lowCurrFile hasSuffix:@".rtf"] || [lowCurrFile hasSuffix:@".htm"] || [lowCurrFile hasSuffix:@".html"] || [lowCurrFile hasSuffix:@".xml"] || [lowCurrFile hasSuffix:@".c"] || [lowCurrFile hasSuffix:@".cc"] || [lowCurrFile hasSuffix:@".cs"] || [lowCurrFile hasSuffix:@".h"] || [lowCurrFile hasSuffix:@".conf"] || [lowCurrFile hasSuffix:@".dat"])
            {
                [self outputText:@"#"];
            }
            else if ([lowCurrFile hasSuffix:@".app"] || [lowCurrFile hasSuffix:@".exe"])
                [self outputText:@"@"];
                else if ([lowCurrFile hasSuffix:@".png"] || [lowCurrFile hasSuffix:@".jpg"] || [currentFile hasSuffix:@".bmp"])
                    [self outputText:@"∆"];
            else if ([self isDirectory:currentFile])
                [self outputText:@"/"];
            else // add more extensions
                [self outputText:@"*"];
        }
        [self outputText:@"\n"];
    }
}
- (BOOL) isDirectory: (NSString *) thePath
{
    BOOL returnValue = NO;
    NSError * error;
    NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:thePath error:&error];
    if (error != nil)
    {
        NSLog(@"Error occurred with isDirectory: %@\n%@", thePath, [error description]);
    }
    if ([[attributes objectForKey:@"NSFileType"] isEqualToString:@"NSFileTypeDirectory"])
    {
        returnValue = YES;
    }
    else
    {
        returnValue = NO;
    }
    return returnValue;
}
-(NSArray *)listFileAtPath:(NSString *)path
{
    NSError * error;
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    
    NSLog(@"Error: %@", error);
    if (error != nil)
    {
        directoryContent = nil;
        if ([error code] == 257)
            [self outputText:[NSString stringWithFormat:@"cd: '%@': Error: permission denied\n", path]];
        else if ([error code] == 256)
            [self outputText:[NSString stringWithFormat:@"-bash: cd: %@: Not a directory\n", path]];
        else if ([error code] == 260)
            [self outputText:[NSString stringWithFormat:@"-bash: cd: %@: No such file or directory\n", path]];
        else
            [self outputText:[NSString stringWithFormat:@"-bash: cd: %@\n", error]];
    }
    
    return directoryContent;
}

@end
