//
//  WindowController.m
//  APNS_PEM
//
//  Created by Akira Matsuda on 2014/05/09.
//  Copyright (c) 2014年 Akira Matsuda. All rights reserved.
//

#import "APNSController.h"
#import "APNSPopoverViewController.h"

@implementation APNSController

- (void)awakeFromNib
{
	[popUpButton_ addItemsWithTitles:@[@"Development", @"Production"]];
	[window_ setDefaultButtonCell:[createButton_ cell]];
}

- (IBAction)selectCer:(id)sender
{
	NSOpenPanel *openPanel	= [NSOpenPanel openPanel];
    NSArray *allowedFileTypes = [NSArray arrayWithObjects:@"cer", nil];
    [openPanel setAllowedFileTypes:allowedFileTypes];
	[openPanel beginSheetModalForWindow:window_ completionHandler:^(NSInteger result) {
		if (result == NSOKButton) {
			NSURL *filePath = [openPanel URL];
			[cerTextField_ setStringValue:filePath.path];
		}
	}];
}

- (IBAction)selectP12:(id)sender
{
	NSOpenPanel *openPanel	= [NSOpenPanel openPanel];
    NSArray *allowedFileTypes = [NSArray arrayWithObjects:@"p12", nil];
    [openPanel setAllowedFileTypes:allowedFileTypes];
	[openPanel beginSheetModalForWindow:window_ completionHandler:^(NSInteger result) {
		if (result == NSOKButton) {
			NSURL *filePath = [openPanel URL];
			[p12TextField_ setStringValue:filePath.path];
		}
	}];
}

- (IBAction)selectDestinationPath:(id)sender
{
	NSOpenPanel *openPanel	= [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel beginSheetModalForWindow:window_ completionHandler:^(NSInteger result) {
		if (result == NSOKButton) {
			NSURL *directoryPath = [openPanel URL];
			[destinationPathTextField_ setStringValue:directoryPath.path];
		}
	}];
}

- (IBAction)createPEM:(id)sender
{
	int opensslAvailable = system(@"which openssl".UTF8String);
	if (opensslAvailable != 0) {
		NSBeginAlertSheet(@"Error", @"OK", nil, nil, window_, nil, nil, nil, nil, @"Command not found so please install it.(openssl)");
		return;
	}

	NSFileManager *manager = [[NSFileManager alloc] init];
	NSString *suffix = [suffixTextField_ stringValue];
	NSString *alertText = nil;
	if ([cerTextField_ stringValue].length == 0) {
		alertText = @"Please input the path of cer file.";
	}
	else if ([manager fileExistsAtPath:[cerTextField_ stringValue]] == NO) {
		alertText = @"cer file does not exist.";
	}
	else if ([p12TextField_ stringValue].length == 0) {
		alertText = @"Please input the path to p12 file.";
	}
	else if ([manager fileExistsAtPath:[p12TextField_ stringValue]] == NO) {
		alertText = @"p12 file does not exist.";
	}
	else if (suffix.length == 0 || suffix == nil) {
		alertText = @"Please input your application name.";
	}
	else if ([destinationPathTextField_ stringValue].length == 0) {
		alertText = @"Please input the destination directory.";
	}
	else if ([manager fileExistsAtPath:[destinationPathTextField_ stringValue]] == NO) {
		alertText = @"Destination directory does not exist.";
	}
	else if ([pemPassPhraseTextField_ stringValue].length == 0) {
		alertText = @"Please input your pem pass phrase.";
	}
	
	if (alertText) {
		NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:alertText, nil];
		[alert setAlertStyle:NSCriticalAlertStyle];
		[alert beginSheetModalForWindow:window_ modalDelegate:nil didEndSelector:nil contextInfo:nil];
	}
	else {
		NSInteger index = [popUpButton_ indexOfSelectedItem];
		NSArray *commands = @[
							  [NSString stringWithFormat:@"openssl x509 -in %@ -inform der -out aps_cert.pem", [cerTextField_ stringValue]],
							  [NSString stringWithFormat:@"openssl pkcs12 -nocerts -out aps_key.pem -passout pass:%@ -in %@ -passin pass:%@", [pemPassPhraseTextField_ stringValue], [p12TextField_ stringValue], [importPasswordTextField_ stringValue]],
							  [NSString stringWithFormat:@"cat aps_cert.pem aps_key.pem > %@/aps_ck_%@_%@.pem", [destinationPathTextField_ stringValue], suffix, @[@"dev", @"prod"][index]],
							  @"rm aps_cert.pem && rm aps_key.pem"
							  ];
		__block BOOL success;
		[commands enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			NSString *cmd = obj;
			int res = system(cmd.UTF8String);
			if (res != 0) {
				NSBeginAlertSheet(@"Error", @"OK", nil, nil, window_, nil, nil, nil, nil, @"Could not create pem file.(%ld%d)", idx, res);
				system("rm aps_key.pem");
				*stop = YES;
				success = NO;
			}
			else {
				success = YES;
			}
		}];
		if (success) {
			NSAlert *alert = [NSAlert alertWithMessageText:@"Success" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"The pem file is generated successfully."];
			[alert setAlertStyle:NSInformationalAlertStyle];
			[alert beginSheetModalForWindow:window_ modalDelegate:nil didEndSelector:nil contextInfo:nil];
			[[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:[destinationPathTextField_ stringValue]]]];
		}
	}
}

BOOL showingPopover;
static NSMutableArray *popoverArray;
- (IBAction)showHelp:(id)sender
{
	if (popoverArray == nil) {
		popoverArray = [NSMutableArray new];
		NSPopover *popover = [[NSPopover alloc] init];
		popover.contentViewController = [[APNSPopoverViewController alloc] initWithText:@"Password for exported p12 file from Keychain Access."];
		[popoverArray addObject:popover];
		NSPopover *popover2 = [[NSPopover alloc] init];
		popover2.contentViewController = [[APNSPopoverViewController alloc] initWithText:@"Password for pem file which will be generated."];
		[popoverArray addObject:popover2];
	}
	
	if (showingPopover) {
		[popoverArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			NSPopover *popover = obj;
			[popover close];
		}];
	}
	else {
		NSArray *textFieldArray = @[importPasswordTextField_, pemPassPhraseTextField_];
		[popoverArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			NSPopover *popover = obj;
			[popover showRelativeToRect:[textFieldArray[idx] bounds] ofView:textFieldArray[idx] preferredEdge:NSMinXEdge];
		}];
	}
	
	showingPopover = !showingPopover;
}

@end
