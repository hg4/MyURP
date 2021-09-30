Shader "URP/Custom/Unlit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor ("Base Color",Color) = (1,1,1,1)
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

        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_ST;
        float4 _BaseColor;
        CBUFFER_END
        ENDHLSL

        pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            HLSLPROGRAM
            #pragma vertex UnlitPassVertex
            #pragma fragment UnlitPassFragment
            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD;
            };
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            Varyings UnlitPassVertex(Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS);
                output.uv = TRANSFORM_TEX(input.uv,_MainTex);
                return output;
            }
            float4 UnlitPassFragment(Varyings input) : SV_Target
            {
                 float4 col = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, input.uv);
                 return col * _BaseColor;
            }
            ENDHLSL
        }

        
    }
    
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
