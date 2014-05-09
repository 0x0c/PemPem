//
//  WindowController.m
//  APNS_PEM
//
//  Created by Akira Matsuda on 2014/05/09.
//  Copyright (c) 2014年 Akira Matsuda. All rights reserved.
//

#import "APNSController.h"

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
	NSFileManager *manager = [[NSFileManager alloc] init];
	NSString *suffix = [suffixTextField_ stringValue];
	NSString *alertText = nil;
	if ([cerTextField_ stringValue].length == 0) {
		alertText = @"Please input the path of cer file.";
	}
	else if ([manager fileExistsAtPath:[cerTextField_ stringValue]] == NO) {
		alertText = @"cer file not exists.";
	}
	else if ([p12TextField_ stringValue].length == 0) {
		alertText = @"Please input the path of p12 file.";
	}
	else if ([manager fileExistsAtPath:[p12TextField_ stringValue]] == NO) {
		alertText = @"p12 file not exists.";
	}
	else if (suffix.length == 0 || suffix == nil) {
		alertText = @"Please input your application name.";
	}
	else if ([destinationPathTextField_ stringValue].length == 0) {
		alertText = @"Please input the destination directory.";
	}
	else if ([manager fileExistsAtPath:[destinationPathTextField_ stringValue]] == NO) {
		alertText = @"Destination directory not exists.";
	}
	else if ([importPasswordTextField_ stringValue].length == 0) {
		alertText = @"Please input your p12 import password.";
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
		BOOL *success;
		[commands enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			NSString *cmd = obj;
			int res = system(cmd.UTF8String);
			if (res != 0) {
				NSBeginAlertSheet(@"Error", @"OK", nil, nil, window_, nil, nil, nil, nil, @"Could not create pem file.(%ld%d)", idx, res);
				system("rm aps_key.pem");
				*stop = YES;
				*success = NO;
			}
			else {
				*success = YES;
			}
		}];
		if (*success) {
			NSAlert *alert = [NSAlert alertWithMessageText:@"Success" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"pem file is generated."];
			[alert setAlertStyle:NSInformationalAlertStyle];
			[alert beginSheetModalForWindow:window_ modalDelegate:nil didEndSelector:nil contextInfo:nil];
			[[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:[destinationPathTextField_ stringValue]]]];
		}
	}
}

@end
