/*
 *  MyDelegate.mm
 *  ofxCocoaWindowNibless
 *
 *  Created by Shawn Lawson
 *  http://www.shawnlawson.com
 *
 */

#import "MyDelegate.h"

@implementation MyDelegate

@synthesize glWindow;
@synthesize glView;

//------------------------------------------------------------
- (id)init {
	return [self initWithWidth: 640 height: 480 requestedScreenMode:OF_WINDOW];
}

//------------------------------------------------------------
- (id) initWithWidth:(int)w height:(int)h requestedScreenMode:(int)m{

	if ( self = [super init] ) {
		NSRect contentSize = NSMakeRect(0.0f, 0.0f, w, h);

		// This is where the nibless window happens
		glWindow = [[NSWindow alloc] initWithContentRect:contentSize 
											   styleMask:NSTitledWindowMask
														|NSClosableWindowMask
														|NSMiniaturizableWindowMask
														// not supported yet
														//|NSResizableWindowMask 
												 backing:NSBackingStoreBuffered 
												   defer:NO];
		
		[glWindow setLevel:NSNormalWindowLevel];
		
		glView = [[GLView alloc] initWithFrame:contentSize shareContext:nil screenMode:m];
		[glWindow setContentView:glView];	
	}
	return self;
}

//------------------------------------------------------------
- (void)applicationWillFinishLaunching:(NSNotification *)notification {
	
	// This is where the nibless menu happens
	// Obviously, just the basics
	id menubar = [[NSMenu new] autorelease];
	id appMenuItem = [[NSMenuItem new] autorelease];
	[menubar addItem:appMenuItem];
	[NSApp setMainMenu:menubar];
	id appMenu = [[NSMenu new] autorelease];
	id appName = [[NSProcessInfo processInfo] processName];
	id quitTitle = [@"Quit " stringByAppendingString:appName];
	id quitMenuItem = [[[NSMenuItem alloc] initWithTitle:quitTitle 
												  action:@selector(terminate:)
										   keyEquivalent:@"q"] autorelease];
	[appMenu addItem:quitMenuItem];
	[appMenuItem setSubmenu:appMenu];
}

//------------------------------------------------------------
- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	
	ofNotifySetup();
	
	glClearColor(ofBgColorPtr()[0], ofBgColorPtr()[1], ofBgColorPtr()[2], ofBgColorPtr()[3]);
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	[glWindow cascadeTopLeftFromPoint:NSMakePoint(20,20)];
	[glWindow setTitle:[[NSProcessInfo processInfo] processName]];
	[glWindow makeKeyAndOrderFront:nil];
	[glWindow setAcceptsMouseMovedEvents:YES];
	[glWindow display];
	
	// TODO: More fullscreen here?
}

//------------------------------------------------------------
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	return YES;
}

//------------------------------------------------------------
- (BOOL)applicationShouldTerminate:(NSNotification*)n {
	ofNotifyExit();
	//return NSTerminateNow;
}

//------------------------------------------------------------
- (void)dealloc {
    [glView release];
    [glWindow release];
	[super dealloc];	
}

@end
