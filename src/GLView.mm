/*
 *  GLView.mm
 *  ofxCocoaWindowNibless
 *
 *  Created by Shawn Lawson
 *  http://www.shawnlawson.com
 *
 */

#import "GLView.h"
#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/glext.h>
#import <OpenGL/glu.h>

@implementation GLView

@synthesize bEnableSetupScreen;
@synthesize bUpdateRateSet;
@synthesize updateRate;
@synthesize frameRate;
@synthesize nFrameCount;
@synthesize windowMode;
@synthesize lastFrameTime;

//------ DISPLAY LINK STUFF ------
//------------------------------------------------------------
-(CVReturn)getFrameForTime:(const CVTimeStamp*)outputTime {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self draw];
	[pool release];
    return kCVReturnSuccess;
}

// This is the renderer output callback function
//------------------------------------------------------------
static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext){
    CVReturn result = [(GLView*)displayLinkContext getFrameForTime:outputTime];
    return result;
}

//------------------------------------------------------------
-(id) initWithFrame:(NSRect)frameRect{
	self = [self initWithFrame:frameRect shareContext:nil screenMode:OF_WINDOW];
	return self;
}
	
//------------------------------------------------------------
-(id) initWithFrame:(NSRect)frameRect shareContext:(NSOpenGLContext*)context screenMode:(int)m{
	
	windowMode = m;
	// TODO: deal with fullscreen here
	
	timeNow = timeThen = 0.0f;
	fps = 	frameRate = 60.0;
	nFrameCount = 0;	
	
	bEnableSetupScreen	= true;
	
	NSOpenGLPixelFormatAttribute attribs[] = {
		NSOpenGLPFAAccelerated,
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFAMultiScreen,
		NSOpenGLPFADepthSize, 24,
		NSOpenGLPFAAlphaSize, 8,
		NSOpenGLPFAColorSize, 32,
		NSOpenGLPFANoRecovery,
		0};		
		
	NSOpenGLPixelFormat *pf = [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];
	
	if (!pf) { 
		NSLog(@"Couldn't make OpenGL pixel format");
	} 
		
	if( !( self = [super initWithFrame:frameRect pixelFormat:[pf autorelease]] ) ){

//	}else{
		NSLog(@"Errors with initialization using pixel format");
	}
	
	return self;
}

//------------------------------------------------------------
- (void) prepareOpenGL {
	[super prepareOpenGL];
	
	[[self openGLContext] makeCurrentContext];
	
	GLint i = 1;
	[[self openGLContext] setValues:&i forParameter:NSOpenGLCPSurfaceOpacity]; 
	
	i = 1;
	[[self openGLContext] setValues:&i forParameter:NSOpenGLCPSwapInterval]; 

//	Not quite right yet
//	GLint dim[2] = {[self frame].size.width, [self frame].size.height};
//	CGLSetParameter((CGLContextObj)[[self openGLContext] CGLContextObj], kCGLCPSurfaceBackingSize, dim);
//	CGLEnable ((CGLContextObj)[[self openGLContext] CGLContextObj], kCGLCESurfaceBackingSize);

	CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
	
	CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, self);
	
	CGLContextObj cglContext = (CGLContextObj)[[self openGLContext] CGLContextObj];
	CGLPixelFormatObj cglPixelFormat = (CGLPixelFormatObj)[[self pixelFormat] CGLPixelFormatObj];
	CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, cglContext, cglPixelFormat);
	
	CVDisplayLinkStart(displayLink);
}

//------------------------------------------------------------
-(void)reshape {
	[super reshape];
	
	CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
	ofSetupScreen();
	CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
}

//------------------------------------------------------------
-(void)setUpdateRate:(int)targetRate {
	
	if([updateTimer isValid]){
		[updateTimer invalidate];
		//updateTimer = nil;
	}
	
	if (targetRate == 0){
		// Let Core Video call ofNotifyUpdate from draw function
		bUpdateRateSet = NO;
		updateRate = targetRate;
	}else {
		// Override Core Video to call ofNotifyUpdate at separate rate
		bUpdateRateSet	= YES;
		float durationOfUpdate 	= 1.0f / (float)targetRate;
		updateRate				= targetRate;
		
		updateTimer = [[NSTimer timerWithTimeInterval:durationOfUpdate
											   target:self
											 selector:@selector(updateOpenFrameworks)
											 userInfo:nil
											  repeats:YES] retain];
		[[NSRunLoop currentRunLoop] addTimer:updateTimer 
									 forMode:NSDefaultRunLoopMode];
		[[NSRunLoop currentRunLoop] addTimer:updateTimer 
									 forMode:NSModalPanelRunLoopMode];
		[[NSRunLoop currentRunLoop] addTimer:updateTimer 
									 forMode:NSEventTrackingRunLoopMode];
	}
}

//------------------------------------------------------------
-(int)updateRate{
	return updateRate;
}
//------------------------------------------------------------
-(void)updateOpenFrameworks {
	ofNotifyUpdate();
}

//------------------------------------------------------------
-(void)draw {
	
	// -------------- fps calculation:
	timeNow = ofGetElapsedTimef();
	double diff = timeNow-timeThen;
	if( diff  > 0.00001 ){
		fps			= 1.0 / diff;
		frameRate	*= 0.9f;
		frameRate	+= 0.1f*fps;
	}
	lastFrameTime	= diff;
	timeThen		= timeNow;
	// --------------
	
	if(!bUpdateRateSet) ofNotifyUpdate();
	
	[[self openGLContext] makeCurrentContext];
	
	CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
	
	
	if(bEnableSetupScreen) ofSetupScreen();
	
	if(ofbClearBg()){
		float * bgPtr = ofBgColorPtr();
		glClearColor(bgPtr[0],bgPtr[1],bgPtr[2], bgPtr[3]);
		glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	}
	
	ofNotifyDraw();
	
	CGLFlushDrawable((CGLContextObj)[[self openGLContext] CGLContextObj]);
	CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
	
	nFrameCount++;
}

//------------------------------------------------------------
-(void)dealloc {
	CVDisplayLinkStop(displayLink);
    CVDisplayLinkRelease(displayLink);
	[super dealloc];
}

//------------------------------------------------------------
-(void)goFullscreen:(NSScreen*)screen {
	windowMode = OF_FULLSCREEN;
	
	if([self respondsToSelector:@selector(isInFullScreenMode)]) {
		[self enterFullScreenMode:screen
					  withOptions:[NSDictionary dictionaryWithObjectsAndKeys: 
								   [NSNumber numberWithBool: NO], NSFullScreenModeAllScreens, 
								   nil]
		 ];
		[self reshape];
	}
}

//------------------------------------------------------------
-(void)goWindow{

	windowMode = OF_WINDOW;
	
	if([self respondsToSelector:@selector(isInFullScreenMode)] && [self isInFullScreenMode]){
		[self exitFullScreenModeWithOptions:nil];
		[self reshape];
		[self.window makeFirstResponder:self];

		
	} else {
		if(savedWindowFrame.size.width == 0 || savedWindowFrame.size.height == 0) {
			savedWindowFrame.size = NSMakeSize(640, 480);
		}
		
		[[self window] setFrame:savedWindowFrame display:YES animate:NO];
		[[self window] setLevel:NSNormalWindowLevel];
	}

}

//------------------------------------------------------------
-(BOOL)acceptsFirstResponder {
	return YES;
}

//------------------------------------------------------------
-(BOOL)becomeFirstResponder {
	return  YES;
}

//------------------------------------------------------------
-(BOOL)resignFirstResponder {
	return YES;
}

#pragma mark Events
//------------------------------------------------------------
-(void)keyDown:(NSEvent *)theEvent {
// TODO: make this more exhaustive if needed
	NSString *characters = [theEvent characters];
	if ([characters length]) {
		unichar key = [characters characterAtIndex:0];
		switch(key) {
			case OF_KEY_ESC:
				OF_EXIT_APP(0);
				break;
				
			case 63232:
				key = OF_KEY_UP;
				break;
			
			case 63235:
				key = OF_KEY_RIGHT;
				break;
			
			case 63233:
				key = OF_KEY_DOWN;
				break;

			case 63234:
				key = OF_KEY_LEFT;
				break;
		}
		ofNotifyKeyPressed(key);
	}
}

//------------------------------------------------------------
-(void)keyUp:(NSEvent *)theEvent {
	// TODO: make this more exhaustive if needed
	NSString *characters = [theEvent characters];
	if ([characters length]) {
		unichar key = [characters characterAtIndex:0];
		ofNotifyKeyReleased(key);
	}
}

//------------------------------------------------------------
-(ofPoint) ofPointFromEvent:(NSEvent*)theEvent {
	NSPoint p = [theEvent locationInWindow];
	return ofPoint(p.x, self.frame.size.height - p.y, 0);
}

//------------------------------------------------------------
-(void)mouseDown:(NSEvent *)theEvent {
	ofPoint p = [self ofPointFromEvent:theEvent];
	ofNotifyMousePressed(p.x, p.y, 0);
}

//------------------------------------------------------------
-(void)rightMouseDown:(NSEvent *)theEvent {
	ofPoint p = [self ofPointFromEvent:theEvent];
	ofNotifyMousePressed(p.x, p.y, 2);
}

//------------------------------------------------------------
-(void)otherMouseDown:(NSEvent *)theEvent {
	ofPoint p = [self ofPointFromEvent:theEvent];
	ofNotifyMousePressed(p.x, p.y, 1);
}

//------------------------------------------------------------
-(void)mouseMoved:(NSEvent *)theEvent{
	ofPoint p = [self ofPointFromEvent:theEvent];
	ofNotifyMouseMoved(p.x, p.y);
}

//------------------------------------------------------------
-(void)mouseUp:(NSEvent *)theEvent {
	ofPoint p = [self ofPointFromEvent:theEvent];
	ofNotifyMouseReleased(p.x, p.y, 0);
}

//------------------------------------------------------------
-(void)rightMouseUp:(NSEvent *)theEvent {
	ofPoint p = [self ofPointFromEvent:theEvent];
	ofNotifyMouseReleased(p.x, p.y, 2);
}

//------------------------------------------------------------
-(void)otherMouseUp:(NSEvent *)theEvent {
	ofPoint p = [self ofPointFromEvent:theEvent];
	ofNotifyMouseReleased(p.x, p.y, 1);
}

//------------------------------------------------------------
-(void)mouseDragged:(NSEvent *)theEvent {
	ofPoint p = [self ofPointFromEvent:theEvent];
	ofNotifyMouseDragged(p.x, p.y, 0);
}

//------------------------------------------------------------
-(void)rightMouseDragged:(NSEvent *)theEvent {
	ofPoint p = [self ofPointFromEvent:theEvent];
	ofNotifyMouseDragged(p.x, p.y, 2);
}

//------------------------------------------------------------
-(void)otherMouseDragged:(NSEvent *)theEvent {
	ofPoint p = [self ofPointFromEvent:theEvent];
	ofNotifyMouseDragged(p.x, p.y, 1);
}

//------------------------------------------------------------
-(void)scrollWheel:(NSEvent *)theEvent {
	// TODO: work on this, need to connect into OF scoll if possible
	//	float wheelDelta = [theEvent deltaX] +[theEvent deltaY] + [theEvent deltaZ];
}

@end
