

#include "testApp.h"

//--------------------------------------------------------------
void testApp::setup() {
	ofBackground(0, 0, 0);
	
	cocoaWindow->setUpdateRate(1);
	updateNum = 0;
}

//--------------------------------------------------------------
void testApp::update(){
	updateNum += 1;
}

//--------------------------------------------------------------
void testApp::draw(){
	
	glColor3f(ofRandomuf(), ofRandomuf(), ofRandomuf());
	ofCircle(ofRandom(0, ofGetWidth()), ofRandom(0, ofGetHeight()), ofRandom(10, 100));
	
	ofSetHexColor(0xffffffff);

	ofDrawBitmapString(" frameRate: " + ofToString(ofGetFrameRate(), 2) + " | updateRate: " + ofToString(cocoaWindow->getUpdateRate()) + " | updateNum: " + ofToString(updateNum), 20, 20);
	
	ofDrawBitmapString(" f toggle fullscreen ",  20, 40);
	ofDrawBitmapString(" u toggle update rate ",  20, 60);
	ofDrawBitmapString(" when updateRate is 0 then Core Video calls update at rendering frame rate, ",  20, 80);
	ofDrawBitmapString(" otherwise we're setting the update rate to 1 ",  20, 100);
	
}

//--------------------------------------------------------------
void testApp::keyPressed(int key){
	switch(key) {
		case 'f':
			ofToggleFullscreen();
			break;
			
		case 'u':
			if (cocoaWindow->getUpdateRate() != 0 ) {
				cocoaWindow->setUpdateRate(0);
			}else {
				cocoaWindow->setUpdateRate(1);
			}
	}	
}

//--------------------------------------------------------------
void testApp::keyReleased(int key){ 
	
}

//--------------------------------------------------------------
void testApp::mouseMoved(int x, int y ){

}

//--------------------------------------------------------------
void testApp::mouseDragged(int x, int y, int button){

}

//--------------------------------------------------------------
void testApp::mousePressed(int x, int y, int button){

}

//--------------------------------------------------------------
void testApp::mouseReleased(int x, int y, int button){

}

//--------------------------------------------------------------
void testApp::windowResized(int w, int h){

}

//--------------------------------------------------------------
void testApp::gotMessage(ofMessage msg){

}