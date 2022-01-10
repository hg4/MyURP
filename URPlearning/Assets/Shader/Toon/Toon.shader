Shader "URP/Custom/Toon"
{
    Properties
    {
        [Header(Common)]
        [Toggle(_ALPHATEST_ON)] _AlphaClipping("Alpha Clipping",float) = 0
        _Cutoff ("Alpha Threshold",Range(0,1)) = 0.5
        [Header(Base Light)]
        _BaseMap ("Texture", 2D) = "white" {}
        [Toggle(_RAMP_MAP)]_UseRampTex("Use Ramp Texture",float) = 0
        _RampMap ("Ramp Texture",2D) = "white" {}
        _BaseColor ("Main Color",Color) = (1,1,1,1)
        _ShadowColor ("Shadow Color",Color) = (0,0,0,1)
        [Toggle(_THREE_STEP)] _ThreeStep("Use Three Color",float) = 0
        _MidColor("Mid Gradient Color",Color) = (0,0,0,1)
        _ShadowThreshold ("Shadow Threshold",Range(0,1)) = 0.5
        _ShadowSmooth ("Shadow Smooth Range",Range(0,1)) = 0.05
        [Toggle(_RECEIVE_SHADOWS)] _ReceiveShadow("Receive Shadows",float) = 0
        [Header(Rim Light)]
        _RimColor("Rim Color",Color) = (1,1,1,1)
        _RimWidth("Rim Width",Range(0,1)) = 0.1
        _RimLength("Rim Length",Range(0,5)) = 1.0
        _RimFeather("Rim Feather",Range(0,1)) = 0.5
        _RimIntensity("Rim Intensity",Range(0,1)) = 1.0
        [Header(Outline)]
        _OutlineColor ("Outline Color",Color) = (0,0,0,1)
        _OutlineWidth ("Outline Width",Range(0,1)) = 0.1
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
     
        ENDHLSL

        pass
        {
            Name "ToonForwardLit"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            Cull back
            HLSLPROGRAM
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _THREE_STEP
            #pragma shader_feature _RECEIVE_SHADOWS
            #pragma shader_feature _RAMP_MAP
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma vertex ToonLitShaderPassVertex
            #pragma fragment ToonLitShaderPassFragment
            #include "ToonLitInput.hlsl"
            #include "ToonLitShaderPass.hlsl"
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
            #include "ToonLitInput.hlsl"
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

            #include "ToonLitInput.hlsl"
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
            #include "ToonLitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }
    }
}
