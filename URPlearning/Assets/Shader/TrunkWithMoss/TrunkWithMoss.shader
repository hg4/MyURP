Shader "URP/Custom/TrunkWithMoss"
{
    Properties
    {
        [Header(Trunk)]
        _BaseMap("trunk Texture", 2D) = "white" {}
        _BaseColor("Base trunk Color",Color) = (1,1,1,1)
        //_SpecColor("Specular trunk Color",Color) = (1,1,1,1)
        //[_NoScaleOffset]_SpecularMap("Specular Texture",2D) = "white" {}

        [Header(Moss)]
        _MossBaseColor("Moss Base Lit Color",Color) = (0,0.5,0,1)
        _MossHighColor("Moss high Lit Color",Color) = (0,0.5,0,1)
        _Shininess("Moss Specular Smoothness",Range(0,1)) = 0.5
        _MossMap("Moss Noise Map", 2D) = "white" {}
        //_MossRoughness("Moss Roughness",Range(0,1)) = 0.5
        [Toggle(_NORMALMAP)]_EnableNormalMap("use normal",float) = 0.0
        [NoScaleOffset]_NormalMap("Normal Texture",2D) = "bump" {}
        _NormalScale("Normal Scale",Range(0,5)) = 1.0
        _Occlusion("Moss Occlusion",Range(0,1)) = 0.5
        [IntRange] _ShellAmount("Moss Layer", Range(1, 100)) = 16
        _ShellStep("Moss Length", Range(0.0, 0.01)) = 0.001
        _AlphaCutout("Moss Density", Range(0.0, 1.0)) = 0.1
        _SSSColor("Moss SubSurface Scatter Color",Color) = (1,1,1,1)
        _SSSIntensity("Moss SSS Intensity",Range(0,1)) = 0.2
        _BackSSDistortion("Moss SSS Distortion",Range(0,1)) = 0.1
        [IntRange]_RimLightPower("Moss SSS Range",Range(2,10)) = 5
        [Header(Common)]
        [Toggle(_ALPHATEST_ON)]_AlphaTest("Enable Global Alpha Test",float) = 0
        _Cutoff("alpha clipping",Range(0,1)) = 0.5
        _IntensityGI("GI Intensity",Range(0,1)) = 1
    }
        SubShader
        {
            Tags
            {
                "RenderType" = "Opaque"
                "RenderPipeline" = "UniversalPipeline"
                "Queue" = "Geometry"
            }

            

            HLSLINCLUDE
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
            #include "../Common/Common.hlsl"
            #include "TrunkWithMossInput.hlsl"
            ENDHLSL

            pass
            {
                Name "TrunkWithMossLit"
                Tags
                {
                    "LightMode" = "UniversalForward"
                }

                HLSLPROGRAM

                    //shader feature
                    #pragma shader_feature _NORMALMAP
                    #pragma shader_feature _ALPHATEST_ON
                    #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
                    #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
                    #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
                    #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
                    #pragma multi_compile _ _SHADOWS_SOFT
                    #pragma vertex TrunkWithMossShaderPassVertex
                    #pragma geometry TrunkWithMossShaderPassGeometry
                    #pragma fragment TrunkWithMossShaderPassFragment
                    #include "TrunkWithMossShaderPass.hlsl"
                    ENDHLSL
                }

                //pass
                //{
                //    Name "MossLit"
                //    Tags
                //    {
                //        "LightMode" = "LightweightForward"

                //    }

                //    HLSLPROGRAM

                //        //shader feature
                //        #pragma shader_feature _OUTLINE_ZOFFSET

                //        #pragma vertex OutlinePassVertex
                //        #pragma fragment OutlinePassFragment
                //        #include "../Common/OutlinePass.hlsl"
                //        ENDHLSL
                //}
            Pass
            {
                Name "ShadowCaster"
                Tags{"LightMode" = "ShadowCaster"}

                ZWrite On
                ZTest LEqual
               

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
