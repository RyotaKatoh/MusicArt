#include "testApp.h"
#include "MPPicker.h"

MPPicker *picker;

//--------------------------------------------------------------
void testApp::setup(){
	ofSetFrameRate(30);
    ofEnableAlphaBlending(); //アルファ値の使用を可能にする
    ofSetCircleResolution(32);
    ofRegisterTouchEvents(this);
    ofxAccelerometer.setup();
    ofxiPhoneAlerts.addListener(this);
    ofBackground(255, 255, 255);
    
    picker = [[MPPicker alloc]initWithNibName:@"MPPicker" bundle:nil];
    
    addSubView = false;
    
    ofxOpenALSoundPlayer::ofxALSoundSetListenerLocation(ofGetWidth()/2,0,ofGetHeight()/2);
	ofxOpenALSoundPlayer::ofxALSoundSetReferenceDistance(100);
	ofxOpenALSoundPlayer::ofxALSoundSetMaxDistance(500);
	ofxOpenALSoundPlayer::ofxALSoundSetListenerGain(1.0);
    
}

//--------------------------------------------------------------
void testApp::update(){
    if(!addSubView){
        [ofxiPhoneGetUIWindow() addSubview:picker.view];
        addSubView = true;
        
    }
    
    
}

//--------------------------------------------------------------
void testApp::draw(){
    ofSetColor(0, 0, 255);
    //ofCircle(ofGetWidth()/2, ofGetHeight()/2, 10);
    ofEllipse(ofGetWidth()/2, ofGetHeight()/2, 10, 10);
    
    ofSetColor(200, 50, 0);
    ofEllipse(picker->location.x, picker->location.y, 20, 20);
}

//--------------------------------------------------------------
void testApp::exit(){
    
}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs & touch){
    
    
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void testApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void testApp::lostFocus(){
    
}

//--------------------------------------------------------------
void testApp::gotFocus(){
    
}

//--------------------------------------------------------------
void testApp::gotMemoryWarning(){
    
}

//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation){
    
}
