//
//  ARCam.hpp
//  example-anchormanager
//
//  Created by Joseph Chow on 8/29/17.
//

#ifndef ARCam_hpp
#define ARCam_hpp

#include <stdio.h>
#include <UIKit/UIkit.h>
#include <ARKit/ARKit.h>
#include "ARUtils.h"
#include "ARShaders.h"

#ifndef CINDER_GL_ES_3
    #include "ofxiOS.h"
    #include "ofMain.h"
#endif
namespace ARCore {
    
    typedef std::shared_ptr<class ARCam>ARCamRef;
    
    class ARCam {
        
        
        // ========== COMMON =============== //
        
        // current orientation to use to get proper projection and view matrices
        UIInterfaceOrientation orientation;
        
        
        // a reference to an ARSession object
        ARSession * session;
        
        // the current ambient light intensity
        float ambientIntensity;
        
        // size of the viewport
        CGSize viewportSize;
        
        // to help reduce resource strain, making building the camera frame optional
        bool shouldBuildCameraFrame;
        
        bool debugMode;
        
        float near;
        float far;
        
        // flag to let the shader know if we need to tweak perspective
        bool needsPerspectiveAdjustment;
        
        // The device type
        NSString * deviceType;
        
        CVOpenGLESTextureRef yTexture;
        CVOpenGLESTextureRef CbCrTexture;
        CVOpenGLESTextureCacheRef _videoTextureCache;

        
        // Converts the CVPixelBufferIndex into a OpenGL texture
        CVOpenGLESTextureRef createTextureFromPixelBuffer(CVPixelBufferRef pixelBuffer,int planeIndex,GLenum format=GL_LUMINANCE,int width=0,int height=0);
        
        // Constructs camera frame from pixel data
        void buildCameraFrame(CVPixelBufferRef pixelBuffer);
        
        ARCommon::ARCameraMatrices cameraMatrices;
        
        // ============ OF STUFF ============= //
       
#ifndef CINDER_GL_ES_3
        // fbo to process and render camera manager into
        ofFbo cameraFbo;
        
        // mesh to render camera image
        ofMesh cameraPlane;
        
        // shader to color convert the camera image
        ofShader cameraConvertShader;
        
        // this handles rotating the camera image to the correct orientation.
        ofMatrix4x4 rotation;
#endif
      
    public:
        ARCam(ARSession * session);
        
        static ARCamRef create(ARSession * session){
            return ARCamRef(new ARCam(session));
        }
        
        // used to help correct perspective distortion for some devices.
        float zoomLevel;
        
        void setup();
        void update();
        void draw();
        
        // helper function to run ofLoadMatrix for projection and view matrices, using
        // the current camera matrices from ARKit.
        void setARCameraMatrices();
        
        // sets the camera's near clip distance
        void setCameraNearClip(float near);
        
        // sets camera far clip distance
        void setCameraFarClip(float far);
        
        // sets the device orientation at which to construct camera matrices
        void setDeviceOrientation(UIInterfaceOrientation orientation);
        
        // adjusts the perspective correction zoom(Note: primarily for larger devices)
        void adjustPerspectiveCorrection(float zoomLevel);
        
        //! Returns Projection and View matrices for the specified orientation.
        ARCommon::ARCameraMatrices getMatricesForOrientation(UIInterfaceOrientation orientation=UIInterfaceOrientationPortrait, float near=0.01,float far=1000.0);
        
#ifndef CINDER_GL_ES_3
        // returns the current projection matrix from the camera
        ofMatrix4x4 getProjectionMatrix(){
            return cameraMatrices.cameraProjection;
        }
        
        // returns the current view matrix from the camera
        ofMatrix4x4 getViewMatrix(){
            return cameraMatrices.cameraView;
        }
        
        // returns the current transform with the camera's position in AR space
        //TODO that is what the camera transform is I belive, need to double check
        ofMatrix4x4 getTransformMatrix(){
            return cameraMatrices.cameraTransform;
        }
        
        // returns a reference to the current set of camera matrices as seen by ARKit
        ARCommon::ARCameraMatrices getCameraMatrices(){
            return cameraMatrices;
        }
        
        ofTexture getCameraTexture(){
            return cameraFbo.getTexture();
        }
#endif
    };
}

#endif /* ARCamera_hpp */
