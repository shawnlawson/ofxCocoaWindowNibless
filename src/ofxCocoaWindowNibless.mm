/*
 *  ofxCocoaWindowNibless.mm
 *  
 *  Created by Shawn Lawson
 *  http://www.shawnlawson.com
 *
 */

#include "ofxCocoaWindowNibless.h"

#import <AppKit/AppKit.h>

//------------------------------------------------------------
ofxCocoaWindowNibless::ofxCocoaWindowNibless(){
	orientation	= OF_ORIENTATION_DEFAULT; // for now this goes here.
}

//------------------------------------------------------------
void ofxCocoaWindowNibless::setupOpenGL(int w, int h, int screenMode) {
		
	if (screenMode != OF_GAME_MODE){
	
		pool = [NSAutoreleasePool new];
		[NSApplication sharedApplication];
		// this creates the Window and OpenGLView in the MyDelegate initialization
		myDelegate = [[[MyDelegate alloc] initWithWidth:w height:h requestedScreenMode:screenMode] autorelease];
		[NSApp setDelegate:myDelegate];	

	} else {
		// TODO: everything having to do with OF_GAME_MODE
	}
}

//------------------------------------------------------------
void ofxCocoaWindowNibless::initializeWindow() {
	// no callbacks needed.
}

//------------------------------------------------------------
void ofxCocoaWindowNibless::runAppViaInfiniteLoop(ofBaseApp * appPtr) {
	ofAppPtr = appPtr;
	
	ofGetAppPtr()->mouseX = 0;
	ofGetAppPtr()->mouseY = 0;
	
	[NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
	[NSApp activateIgnoringOtherApps:YES];
	// This launches the NSapp functions in  MyDelegate
  	[NSApp run]; 
	
	[pool drain];	
}

//------------------------------------------------------------
float ofxCocoaWindowNibless::getFrameRate(){
	return [[NSApp delegate] glView].frameRate;
}

//------------------------------------------------------------
float ofxCocoaWindowNibless::getUpdateRate(){
	return [[NSApp delegate] glView].updateRate;
}

//------------------------------------------------------------
double ofxCocoaWindowNibless::getLastFrameTime(){
	return [[NSApp delegate] glView].lastFrameTime;
}

//------------------------------------------------------------
int ofxCocoaWindowNibless::getFrameNum(){
	return [[NSApp delegate] glView].nFrameCount;
}

//------------------------------------------------------------
void ofxCocoaWindowNibless::setWindowTitle(string title){
	// TODO: set window title 
	// see...
	// [glWindow setTitle:[[NSProcessInfo processInfo] processName]];
	// in MyDelegate
	NSString *stringFromUTFString = [[NSString alloc] initWithUTF8String:title.c_str() ];
	[[[NSApp delegate] glWindow] setTitle: stringFromUTFString];
}

//------------------------------------------------------------
ofPoint ofxCocoaWindowNibless::getWindowSize(){
	return ofPoint( getWidth(), getHeight(), 0 );
}

//------------------------------------------------------------
ofPoint ofxCocoaWindowNibless::getWindowPosition(){
	NSRect viewFrame = [[[NSApp delegate] glView] frame];
	NSRect windowFrame = [[[NSApp delegate] glWindow] frame];
	NSRect screenRect = [[[[NSApp delegate] glWindow] screen] frame];
	return ofPoint( windowFrame.origin.x, screenRect.size.height-windowFrame.origin.y-viewFrame.size.height, 0 );
}

//------------------------------------------------------------
ofPoint ofxCocoaWindowNibless::getScreenSize(){
	NSRect screenRect = [[[[NSApp delegate] glWindow] screen] frame];
	return ofPoint(screenRect.size.width, screenRect.size.height, 0);
}

//------------------------------------------------------------
int ofxCocoaWindowNibless::getWidth(){
	if( orientation == OF_ORIENTATION_DEFAULT || orientation == OF_ORIENTATION_180 ){
		return [[[NSApp delegate] glView] frame].size.width;
	}
	return [[[NSApp delegate] glView] frame].size.height;
}

//------------------------------------------------------------
int ofxCocoaWindowNibless::getHeight(){
	if( orientation == OF_ORIENTATION_DEFAULT || orientation == OF_ORIENTATION_180 ){
		return [[[NSApp delegate] glView] frame].size.height;
	}
	return [[[NSApp delegate] glView] frame].size.width;
}

//------------------------------------------------------------
void ofxCocoaWindowNibless::setOrientation(ofOrientation orientationIn){
	orientation = orientationIn;
}

//------------------------------------------------------------
ofOrientation ofxCocoaWindowNibless::getOrientation(){
	return orientation;
}

//------------------------------------------------------------
void ofxCocoaWindowNibless::setWindowPosition(int x, int y) {
	NSRect viewFrame = [[[NSApp delegate] glView] frame];
	NSRect windowFrame = [[[NSApp delegate] glWindow] frame];
	NSRect screenRect = [[[[NSApp delegate] glWindow] screen] frame];
	
	// TODO: this isn't quite right yet. A few pixels off I think. ~2?
	// GLUT draws from top left
	// Apple Cocoa draws from bottom left
	
	NSPoint point = NSMakePoint(x, 
								screenRect.size.height-y);

	[[[NSApp delegate] glWindow] cascadeTopLeftFromPoint:point];
}

//------------------------------------------------------------
void ofxCocoaWindowNibless::setWindowShape(int w, int h) {
	
	// TODO: test this part, not sure if it works
	
	NSRect windowFrame  = [[[NSApp delegate]  glWindow] frame];
	NSRect viewFrame = [[[NSApp delegate] glView]frame];
	
	windowFrame.origin.y -= h -  viewFrame.size.height;
	windowFrame.size = NSMakeSize(w + windowFrame.size.width - viewFrame.size.width, 
								  h + windowFrame.size.height - viewFrame.size.height);
	
	[[[NSApp delegate]  glWindow] setFrame:windowFrame display:YES];
}

//------------------------------------------------------------
void ofxCocoaWindowNibless::hideCursor() {
	[NSCursor hide];
}

//------------------------------------------------------------
void ofxCocoaWindowNibless::showCursor() {
	[NSCursor unhide];
}

//------------------------------------------------------------
void ofxCocoaWindowNibless::setFrameRate(float targetRate) {
	NSLog(@"When using the Core Video Display Link, setting frame rate is not possible. Use setUpdateRate to set the update frequency to something different than the frame rate.");
}

//------------------------------------------------------------
void ofxCocoaWindowNibless::setUpdateRate(float targetRate) {
	[[[NSApp delegate] glView] setUpdateRate:targetRate];
}

//------------------------------------------------------------
int ofxCocoaWindowNibless::getWindowMode(){
	return [[NSApp delegate] glView].windowMode;
}

//------------------------------------------------------------
void ofxCocoaWindowNibless::toggleFullscreen() {
	if( [[NSApp delegate] glView].windowMode == OF_GAME_MODE)return;
	
	if( [[NSApp delegate] glView].windowMode == OF_WINDOW ){
		[[NSApp delegate] glView].windowMode = OF_FULLSCREEN;
		[[[NSApp delegate] glView] goFullscreen:[[[NSApp delegate] glWindow] screen]];
	}else{
		[[NSApp delegate] glView].windowMode = OF_WINDOW;
		[[[NSApp delegate] glView] goWindow];
	}
}

//------------------------------------------------------------
void ofxCocoaWindowNibless::setFullscreen(bool fullscreen){
    if( [[NSApp delegate] glView].windowMode == OF_GAME_MODE)return;
	
    if(fullscreen && [[NSApp delegate] glView].windowMode != OF_FULLSCREEN){
        [[NSApp delegate] glView].windowMode = OF_FULLSCREEN;
		[[[NSApp delegate] glView] goFullscreen:[[[NSApp delegate] glWindow] screen]];
    }else if(!fullscreen && [[NSApp delegate] glView].windowMode != OF_WINDOW) {
        [[NSApp delegate] glView].windowMode = OF_WINDOW;
		[[[NSApp delegate] glView] goWindow];
    }
}

//------------------------------------------------------------
void ofxCocoaWindowNibless::enableSetupScreen(){
	[[NSApp delegate] glView].bEnableSetupScreen = true;
}

//------------------------------------------------------------
void ofxCocoaWindowNibless::disableSetupScreen(){
	[[NSApp delegate] glView].bEnableSetupScreen = false;
}