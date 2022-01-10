#ifndef LIT_PHONG_SHADER_PASS_INCLUDED
#define LIT_PHONG_SHADER_PASS_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct Attributes
{
    float3 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float2 uv : TEXCOORD;
};
struct Varyings
{
    float4 positionCS : SV_Position;
    float3 positionWS : VAR_POSITION;
    float2 uv : TEXCOORD0;
    float3 normalWS : VAR_NORMAL;
    #ifdef _NORMALMAP
    float4 tangentWS : VAR_TANGENT;
    #endif
};

struct SurfaceData
{
    float3 baseColor;
    float3 specColor;
    float3 normal;
    float3 viewDir;
    float3 position;
    float smoothness;
    float4 shadowCoord;
    float alpha;
};
float4 GetLighting(SurfaceData surface)
{
    Light light = GetMainLight(surface.shadowCoord); 
    half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
    half3 diffuse = LightingLambert(attenuatedLightColor, light.direction, surface.normal);
    half3 specular = LightingSpecular(attenuatedLightColor, light.direction, surface.normal, surface.viewDir, float4(surface.specColor, 1.0), surface.smoothness);
                //º∆À„∏Ωº”π‚’’
    uint pixelLightCount = GetAdditionalLightsCount();
    for (uint lightIndex = 0; lightIndex < pixelLightCount; ++lightIndex)
    {
        Light light = GetAdditionalLight(lightIndex, surface.position);
        diffuse += LightingLambert(light.color, light.direction, surface.normal);
        specular += LightingSpecular(light.color, light.direction, normalize(surface.normal), normalize(surface.viewDir), float4(surface.specColor, 1.0), surface.smoothness);
    }
    return float4(surface.baseColor * diffuse + specular,surface.alpha);
}



Varyings LitPhongShaderPassVertex(Attributes input)
{
    Varyings output;
    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    output.positionCS = vertexInput.positionCS;
    output.positionWS = vertexInput.positionWS;
    output.uv = TRANSFORM_TEX(input.uv,_BaseMap);
    output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
    #ifdef _NORMALMAP
    output.tangentWS = float4(TransformObjectToWorldDir(input.tangentOS.xyz),
        input.tangentOS.w);
    #endif
    return output;
}

float4 LitPhongShaderPassFragment(Varyings input) : SV_Target
{
    SurfaceData surface;
    float4 col = GetBaseMap(input.uv) * _BaseColor;
    surface.shadowCoord = TransformWorldToShadowCoord(input.positionWS);
    surface.baseColor = col.rgb;
    surface.specColor = GetSpecularMap(input.uv).rgb * _SpecColor.rgb;
    surface.alpha = col.a;
    surface.normal = input.normalWS;
    surface.position = input.positionWS;
    surface.viewDir = normalize(GetCameraPositionWS() - input.positionWS);
    surface.smoothness = (1 - _Shininess) * 128;
    #ifdef _NORMALMAP
    float3 normalTS = GetNormalMap(input.uv);
    surface.normal = NormalTangentToWorld(normalTS,input.normalWS,input.tangentWS); 
    #endif
    float4 color = GetLighting(surface);
    return color;
}
#endif