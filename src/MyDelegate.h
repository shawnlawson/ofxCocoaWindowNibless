/*
 *  MyDelegate.h
 *  ofxCocoaWindowNibless
 *
 *  Created by Shawn Lawson
 *  http://www.shawnlawson.com
 *
 */

#pragma once

#import "GLView.h"

@interface MyDelegate : NSObject {

    NSWindow *glWindow;
	GLView	*glView;

}

- (id)initWithWidth:(int)w height:(int)h requestedScreenMode:(int)m;

@property (retain) NSWindow	*glWindow;
@property (retain) GLView	*glView;


@end
