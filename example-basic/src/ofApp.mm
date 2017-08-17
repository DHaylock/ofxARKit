#include "ofApp.h"



void logSIMD(const simd::float4x4 &matrix)
{
    std::stringstream output;
    int columnCount = sizeof(matrix.columns) / sizeof(matrix.columns[0]);
    for (int column = 0; column < columnCount; column++) {
        int rowCount = sizeof(matrix.columns[column]) / sizeof(matrix.columns[column][0]);
        for (int row = 0; row < rowCount; row++) {
            output << std::setfill(' ') << std::setw(9) << matrix.columns[column][row];
            output << ' ';
        }
        output << std::endl;
    }
    output << std::endl;
    //NSLog(@"%s", output.str().c_str());
}

ofMatrix4x4 matFromSimd(const simd::float4x4 &matrix){
    ofMatrix4x4 mat;
    mat.set(matrix.columns[0].x,matrix.columns[0].y,matrix.columns[0].z,matrix.columns[0].w,
            matrix.columns[1].x,matrix.columns[1].y,matrix.columns[1].z,matrix.columns[1].w,
            matrix.columns[2].x,matrix.columns[2].y,matrix.columns[2].z,matrix.columns[2].w,
            matrix.columns[3].x,matrix.columns[3].y,matrix.columns[3].z,matrix.columns[3].w);
    return mat;
}

//--------------------------------------------------------------
ofApp :: ofApp (ARSession * session){
    this->session = session;
    cout << "creating ofApp" << endl;
}

ofApp::ofApp(){}

//--------------------------------------------------------------
ofApp :: ~ofApp () {
    cout << "destroying ofApp" << endl;
}

//--------------------------------------------------------------
void ofApp::setup() {
    ofBackground(127);
    
    img.load("OpenFrameworks.png");
    
    int fontSize = 8;
    if (ofxiOSGetOFWindow()->isRetinaSupportedOnDevice())
        fontSize *= 2;
    
    font.load("fonts/mono0755.ttf", fontSize);
    
    
    
    processor = ARProcessor::create(session);
    
    processor->setup();
    

    
}


vector < matrix_float4x4 > mats;

//--------------------------------------------------------------
void ofApp::update(){
    
    processor->update();
    
    mats.clear();
    
    if (session.currentFrame){
        NSInteger anchorInstanceCount = session.currentFrame.anchors.count;
        
        for (NSInteger index = 0; index < anchorInstanceCount; index++) {
            ARAnchor *anchor = session.currentFrame.anchors[index];
            
            // Flip Z axis to convert geometry from right handed to left handed
            matrix_float4x4 coordinateSpaceTransform = matrix_identity_float4x4;
            coordinateSpaceTransform.columns[2].z = -1.0;
            
            matrix_float4x4 newMat = matrix_multiply(anchor.transform, coordinateSpaceTransform);
            mats.push_back(newMat);
            logSIMD(newMat);
            //anchorUniforms->modelMatrix = matrix_multiply(anchor.transform, coordinateSpaceTransform);
        }
    }
    
}


ofCamera camera;
//--------------------------------------------------------------
void ofApp::draw() {
    ofEnableAlphaBlending();
    
    processor->draw();
    
    
    
    // ========== DEBUG STUFF ============= //
    int w = MIN(ofGetWidth(), ofGetHeight()) * 0.6;
    int h = w;
    int x = (ofGetWidth() - w)  * 0.5;
    int y = (ofGetHeight() - h) * 0.5;
    int p = 0;
    
    x = ofGetWidth()  * 0.2;
    y = ofGetHeight() * 0.11;
    p = ofGetHeight() * 0.035;
    
    ofSetColor(ofColor::black);
    font.drawString("frame num      = " + ofToString( ofGetFrameNum() ),    x, y+=p);
    font.drawString("frame rate     = " + ofToString( ofGetFrameRate() ),   x, y+=p);
    font.drawString("screen width   = " + ofToString( ofGetWidth() ),       x, y+=p);
    font.drawString("screen height  = " + ofToString( ofGetHeight() ),      x, y+=p);
    
    
    
    //return;
    
    ofDisableLighting();
    if (session.currentFrame){
        if (session.currentFrame.camera){
            ARCamera * arCamera = session.currentFrame.camera;
            
            CGSize _viewportSize;
            _viewportSize.width = ofGetWidth();
            _viewportSize.height = ofGetHeight();
            
            
            
            
            /*
             simd::float4x4 viewMatrix = [session.currentFrame.camera viewMatrixForOrientation:UIInterfaceOrientationPortrait];
             
             
             matrix_float4x4 projectionMatrix = [session.currentFrame.camera projectionMatrixWithViewportSize:_viewportSize orientation:UIInterfaceOrientationPortrait zNear:0.01 zFar:1000.0];
             */
            
            
            
            //simd::float4x4 projectionMatrix = [session.currentFrame.camera projectionMatrixForOrientation:UIInterfaceOrientationPortrait viewportSize:_viewportSize zNear:0.001 zFar:1000];
            
            camera.begin();
            processor->setARCameraMatrices();
            
            for (int i = 0; i < mats.size(); i++){
                ofPushMatrix();
                //mats[i].operator=(const simd_float4x4 &)
                ofMatrix4x4 mat;
                mat.set(mats[i].columns[0].x, mats[i].columns[0].y,mats[i].columns[0].z,mats[i].columns[0].w,
                        mats[i].columns[1].x, mats[i].columns[1].y,mats[i].columns[1].z,mats[i].columns[1].w,
                        mats[i].columns[2].x, mats[i].columns[2].y,mats[i].columns[2].z,mats[i].columns[2].w,
                        mats[i].columns[3].x, mats[i].columns[3].y,mats[i].columns[3].z,mats[i].columns[3].w);
                ofMultMatrix(mat);
                //cout << mat << endl;
                ofSetColor(255);
                ofRotate(90,0,0,1);
                ofScale(0.0001, 0.0001);
                img.draw(0,0);
                
                ///ofBoxPrimitive p(0.01,0.01, 0.01);
                //p.getMesh().draw();
                //mat.set(mats[i])
                ofPopMatrix();
            }
            
            camera.end();
        }
        
    }
    
    
    //cout << session.currentFrame.anchors.count << endl;
    //    if (session.currentFrame.camera){
    //        logSIMD(session.currentFrame.camera.transform);
    //        //NSLog(@"%@", session.currentFrame.camera);
    //    }
    
}

//--------------------------------------------------------------
void ofApp::exit() {
    //
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs &touch){
    
    if (session.currentFrame.camera){
        /*
         NSLog(@"%@", session.currentFrame.camera);
         
         matrix_float4x4 translation = matrix_identity_float4x4;
         translation.columns[3].z = -0.2;
         
         matrix_float4x4 transform = matrix_multiply(session.currentFrame.camera.transform, translation);
         
         NSLog(@"hi");
         //   Add a new anchor to the session
         ARAnchor *anchor = [[ARAnchor alloc] initWithTransform:transform];
         [session addAnchor:anchor];
         */
        
    }
    
    
    processor->addAnchor();
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs &touch){
    
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs &touch){
    
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs &touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){
    
}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){
    
}


//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs& args){
    
}


