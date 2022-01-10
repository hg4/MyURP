#ifndef TOON_LIT_SHADER_PASS_INCLUDED
#define TOON_LIT_SHADER_PASS_INCLUDED
#include "ToonLighting.hlsl"

struct Attributes
{
    float3 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 color : COLOR;
    float2 uv : TEXCOORD0;
    float2 lightmapUV : TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Varyings
{
    float4 positionCS : SV_POSITION;
    float3 positionWS : VAR_POSITION;
    float3 normalWS : VAR_NORMAL;
    float4 color : VAR_COLOR;
    float2 uv : TEXCOORD0;
    DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 3);
	UNITY_VERTEX_INPUT_INSTANCE_ID
};



Varyings ToonLitShaderPassVertex(Attributes input)
{
    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    output.positionCS = vertexInput.positionCS;
    output.positionWS = vertexInput.positionWS;
    output.normalWS = TransformObjectToWorldDir(input.normalOS);
    output.color = input.color;
    output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
    OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

    return output;
}

float4 ToonLitShaderPassFragment(Varyings input) : SV_Target
{
    ToonSurfaceData surface;
    surface.positionWS = input.positionWS;
    surface.positionVS = TransformWorldToView(input.positionWS);
    surface.positionCS = TransformWorldToHClip(input.positionCS);
    surface.positionSS = input.positionCS.xy;
    surface.screenUV = surface.positionSS / _ScreenParams.xy;
    surface.normalWS = input.normalWS;
    float4 albedo= GetBaseMap(input.uv);
    surface.vertexColor = input.color;
    surface.baseColor = albedo.rgb;
    surface.alpha = albedo.a;
    surface.occlusion = 1.0;
    surface.shadowCoord = TransformWorldToShadowCoord(input.positionWS);
    surface.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, input.normalWS);
    return GetToonLighting(surface);
}
#endif