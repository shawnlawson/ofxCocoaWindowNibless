/*
 *  ofxCocoaWindowNibless.h
 *  
 *  Created by Shawn Lawson
 *  http://www.shawnlawson.com
 *
 *  Intended to a be Nibless approach to using Cocoa windows in Open Frameworks 007
 *	Likely to be not very backward compatible under OSX 10.6
 *
 */

#pragma once
#include "ofMain.h"
#include "ofAppBaseWindow.h"

#include "MyDelegate.h"

class ofBaseApp;

class ofxCocoaWindowNibless : public ofAppBaseWindow {

public:
	ofxCocoaWindowNibless();
	~ofxCocoaWindowNibless(){}

	void setupOpenGL(int w, int h, int screenMode);
	void initializeWindow();
	void runAppViaInfiniteLoop(ofBaseApp * appPtr);

	void hideCursor();
	void showCursor();

	void setFullscreen(bool fullScreen);
	void toggleFullscreen();

	void setWindowTitle(string title);
	void setWindowPosition(int x, int y);
	void setWindowShape(int w, int h);

	ofPoint		getWindowPosition();
	ofPoint		getWindowSize();
	ofPoint		getScreenSize();

	void			setOrientation(ofOrientation orientation);
	ofOrientation	getOrientation();
		
	int			getWidth();
	int			getHeight();	

	int			getWindowMode();

	int			getFrameNum();
	float		getFrameRate();
	double		getLastFrameTime();
	void		setFrameRate(float targetRate);

	void		enableSetupScreen();
	void		disableSetupScreen();
	
	void		setUpdateRate(float targetRate);
	float		getUpdateRate();
	
protected:
	ofOrientation	orientation;
	ofBaseApp *	ofAppPtr;
	
	MyDelegate *myDelegate;
	NSAutoreleasePool *pool; //not sure if needed
	
};