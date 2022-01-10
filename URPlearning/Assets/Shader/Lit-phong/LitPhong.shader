Shader "URP/Custom/LitPhong"
{
    Properties
    {
        _BaseMap ("diffuse Texture", 2D) = "white" {}
        _BaseColor ("Base Color",Color) = (1,1,1,1)
        _SpecColor ("Specular Color",Color) = (1,1,1,1)
        [_NoScaleOffset]_SpecularMap ("Specular Texture",2D) = "white" {}
        _Shininess("Smoothness",Range(0,1)) = 0.0
        [Toggle(_NORMALMAP)]_EnableNormalMap("use normal",float) = 0.0
        [_NoScaleOffset]_NormalMap("Normal Texture",2D) = "bump" {}
        _NormalScale("Normal Scale",Range(0,5)) = 1.0
        [Header(Outline)]
        _OutlineColor("Outline Color",Color) = (0,0,0,1)
        _OutlineWidth("Outline Width",Range(0,1)) = 0.2
        _Cutoff("alpha clipping",Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Geometry" 
        }
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
        #include "../Common/Common.hlsl"
        #include "LitPhongInput.hlsl"
        ENDHLSL

        pass
        {
            Name "PhongForwardLit"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            Cull back
            HLSLPROGRAM

            //shader feature
            #pragma shader_feature _NORMALMAP

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE

            #pragma vertex LitPhongShaderPassVertex
            #pragma fragment LitPhongShaderPassFragment
            #include "LitPhongShaderPass.hlsl"
            ENDHLSL
        }

        pass
        {
            Name "Outline"
            Tags
            {
                "LightMode" = "Outline"
        
            }
            Cull front
            Offset 1,1
            HLSLPROGRAM

            //shader feature
            #pragma shader_feature _OUTLINE_ZOFFSET

            #pragma vertex OutlinePassVertex
			#pragma fragment OutlinePassFragment
		    #include "../Common/OutlinePass.hlsl"
            ENDHLSL
        }
         Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            Cull[_Cull]

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _GLOSSINESS_FROM_BASE_ALPHA

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

           
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _GLOSSINESS_FROM_BASE_ALPHA

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }

    }
    
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
