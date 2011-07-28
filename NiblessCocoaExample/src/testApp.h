

#ifndef _TEST_APP
#define _TEST_APP

#include "ofMain.h"
#include "ofxCocoaWindowNibless.h"

class testApp : public ofBaseApp{
	
public:
	
	// Overriding the constructor, so that we can pass the window handle 
	// and get access to our custom functions.
	testApp(ofxCocoaWindowNibless * window){
		cocoaWindow = window;
		mouseX = mouseY = 0;
	}
	void setup();
	void update();
	void draw();
	
	void keyPressed(int key);
	void keyReleased(int key);
	void mouseMoved(int x, int y );
	void mouseDragged(int x, int y, int button);
	void mousePressed(int x, int y, int button);
	void mouseReleased(int x, int y, int button);
	void windowResized(int w, int h);
	
	void gotMessage(ofMessage msg);
	
	ofxCocoaWindowNibless * cocoaWindow;
	
	int				updateNum;
};

#endif
