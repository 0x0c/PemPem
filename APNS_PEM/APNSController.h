//
//  WindowController.h
//  APNS_PEM
//
//  Created by Akira Matsuda on 2014/05/09.
//  Copyright (c) 2014年 Akira Matsuda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APNSController : NSObject
{
	IBOutlet NSWindow *window_;
	IBOutlet NSButton *createButton_;
	IBOutlet NSTextField *cerTextField_;
	IBOutlet NSTextField *p12TextField_;
	IBOutlet NSTextField *suffixTextField_;
	IBOutlet NSPopUpButton *popUpButton_;
	IBOutlet NSTextField *destinationPathTextField_;
	IBOutlet NSSecureTextField *importPasswordTextField_;
	IBOutlet NSSecureTextField *pemPassPhraseTextField_;
}

- (IBAction)selectCer:(id)sender;
- (IBAction)selectP12:(id)sender;
- (IBAction)selectDestinationPath:(id)sender;
- (IBAction)createPEM:(id)sender;
- (IBAction)showHelp:(id)sender;

@end
