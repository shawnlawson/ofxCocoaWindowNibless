/*
 *  GLView.h
 *  ofxCocoaWindowNibless
 *
 *  Created by Shawn Lawson
 *  http://www.shawnlawson.com
 *
 */

#pragma once
#include "ofMain.h"

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CVDisplayLink.h>

@interface GLView : NSOpenGLView {
	NSRect				savedWindowFrame;
	int					windowMode;
	
	CVDisplayLinkRef	displayLink;

	float				timeNow, timeThen, fps;
	double				lastFrameTime;
	int					nFrameCount;
	float				frameRate;
	bool				bEnableSetupScreen, bUpdateRateSet;
	
	int				updateRate;
	NSTimer *			updateTimer;
}

@property (assign) bool bEnableSetupScreen;
@property (assign) bool bUpdateRateSet;
@property (readonly) int updateRate;
@property (readonly) float frameRate;
@property (readonly) int nFrameCount;
@property (assign) int windowMode;
@property (readonly) double lastFrameTime;

-(id)initWithFrame:(NSRect)frameRect;
-(id)initWithFrame:(NSRect)frameRect shareContext:(NSOpenGLContext*)context screenMode:(int)m;

-(void)setUpdateRate:(int)targetRate;
-(void)updateOpenFrameworks;
-(void)draw;

-(void)goFullscreen:(NSScreen*)screen;
-(void)goWindow;


@end
