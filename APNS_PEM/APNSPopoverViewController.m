//
//  APNSPopoverViewController.m
//  PemPem
//
//  Created by Akira Matsuda on 2014/05/10.
//  Copyright (c) 2014年 Akira Matsuda. All rights reserved.
//

#import "APNSPopoverViewController.h"

@implementation APNSPopoverViewController

- (id)initWithText:(NSString *)text
{
	self = [super init];
	if (self) {
		NSTextField *label = [[NSTextField alloc] init];
		[label setEditable:NO];
		[label setSelectable:NO];
		[label setBezeled:NO];
		[label setStringValue:text];
		[label setBackgroundColor:[NSColor clearColor]];
		[label sizeToFit];
		NSRect rect = [text boundingRectWithSize:NSMakeSize(400, 1000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[label font]}];
//		[label setFrame:rect];
		NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, rect.size.width + 5, MAX(rect.size.height + 5, 30))];
		[label setFrameOrigin:CGPointMake(NSMaxX(view.bounds) / 2 - NSMaxX(label.bounds) / 2, NSMaxY(view.bounds) / 2 - NSMaxY(label.bounds) / 2)];
		[view addSubview:label];
		self.view = view;
	}
	
	return self;
}

@end
