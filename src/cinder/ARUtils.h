//
//  ARToolkitComponents.h
//
//  Created by Joseph Chow on 8/16/17.
//

#ifndef ARToolkitComponents_h
#define ARToolkitComponents_h

#define STRINGIFY(A) #A

#ifndef CINDER_GL_ES_3
#include "ofMain.h"
#endif

namespace ARCommon {
    
    // joined camera matrices as one object.
    typedef struct {
#ifndef CINDER_GL_ES_3
        ofMatrix4x4 cameraTransform;
        ofMatrix4x4 cameraProjection;
        ofMatrix4x4 cameraView;
#else
        ci::mat4 cameraTransform;
        ci::mat4 cameraProjection;
        ci::mat4 cameraView;
#endif
    }ARCameraMatrices;
    
    // borrowed from https://github.com/wdlindmeier/Cinder-Metal/blob/master/include/MetalHelpers.hpp
    // helpful converting to and from SIMD
    template <typename T, typename U >
    const U static inline convert( const T & t )
    {
        U tmp;
        memcpy(&tmp, &t, sizeof(U));
        U ret = tmp;
        return ret;
    }
   
    
    
#ifndef CINDER_GL_ES_3
    
    // convert to oF mat4
    const ofMatrix4x4 static inline toMat4( const matrix_float4x4& mat ) {
        return convert<matrix_float4x4, ofMatrix4x4>(mat);
    }
    
    // convert to simd based mat4
    const matrix_float4x4 toSIMDMat4(ofMatrix4x4 &mat){
        return convert<ofMatrix4x4,matrix_float4x4>(mat);
    }
    
    static ofMatrix4x4 modelMatFromTransform( matrix_float4x4 transform )
    {
        matrix_float4x4 coordinateSpaceTransform = matrix_identity_float4x4;
        // Flip Z axis to convert geometry from right handed to left handed
        coordinateSpaceTransform.columns[2].z = -1.0;
        matrix_float4x4 modelMat = matrix_multiply(transform, coordinateSpaceTransform);
        return toMat4( modelMat );
    }
#endif
}



#endif /* ARToolkitComponents_h */
