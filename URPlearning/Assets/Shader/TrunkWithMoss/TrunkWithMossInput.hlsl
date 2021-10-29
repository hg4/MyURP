#ifndef TRUNK_WITH_MOSS_INPUT_INCLUDED
#define TRUNK_WITH_MOSS_INPUT_INCLUDED
TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);
TEXTURE2D(_MossMap);
SAMPLER(sampler_MossMap);
TEXTURE2D(_BaseMossMap);
//TEXTURE2D(_FlowMap);
//SAMPLER(sampler_FlowMap);
//if use batcher, geometry shader will cause problem.
//CBUFFER_START(UnityPerMaterial)
float4 _BaseMap_ST;
float4 _MossMap_ST;
half4 _BaseColor;
half4 _ShadowColor;
//float4 _SpecColor;
half _HeightScale;
half _Shininess;
int _ShellAmount;
half _ShellStep;
half _AlphaCutout;
half _MossRoughness;
half4 _MossBaseColor;
float4 _MossShadowColor;
//half4 _MossHighColor;
half _Occlusion;

half4 _SSSColor;
half _BackSSDistortion;
half _SSSIntensity;
half _RimLightPower;

half _ShadowSmooth;
half _ShadowThreshold;
half _Cutoff;
half _IntensityGI;

//CBUFFER_END

half4 GetBaseColor()
{
    return _BaseColor;
}
half4 GetShadowColor()
{
    return _ShadowColor;
}

half4 GetBaseMap(float2 uv)
{
    return SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
}
//float2 GetFlowMap(float2 uv)
//{
//    return SAMPLE_TEXTURE2D(_FlowMap, sampler_FlowMap, uv).rg * 2 - 1;
//}
//float3 GetNormalMapLOD(float2 uv,float lod)
//{
//    float4 sample = SAMPLE_TEXTURE2D_LOD(_NormalMap, sampler_NormalMap, uv,lod);
//    return UnpackNormalScale(sample, _NormalScale);
//}
half GetMossMap(float2 uv)
{
    return SAMPLE_TEXTURE2D(_MossMap, sampler_MossMap, uv).r;
}
half4 GetMossBaseMap(float2 uv)
{
    return SAMPLE_TEXTURE2D(_BaseMossMap, sampler_BaseMap, uv);
}
half4 GetMossBaseColor()
{
    return _MossBaseColor;
}
//half4 GetMossHighColor()
//{
//    return _MossHighColor;
//}
float4 GetMossShadowColor()
{
    return _MossShadowColor;
}
half GetShellStep()
{
    return _ShellStep;
}
half3 GetSSSColor()
{
    return _SSSColor.rgb;
}
half GetSSSIntensity()
{
    return _SSSIntensity;
}
half GetBackSSDistortion()
{
    return _BackSSDistortion;
}
half GetRimLightPower()
{
    return _RimLightPower;
}
half GetSmoothness()
{
    return (1 - _Shininess)*32;
}
half GetAlphaCutout()
{
    return 1-_AlphaCutout;
}
half GetIntensityGI()
{
    return _IntensityGI;
}
half GetCutoff()
{
    return _Cutoff;
}
half GetOcclusion()
{
    return _Occlusion;
}
int GetShellAmount()
{
    return _ShellAmount;
}
half GetMossRoughness()
{
    return _MossRoughness;
}
half GetShadowSmooth()
{
    return _ShadowSmooth;
}
half GetShadowThreshold()
{
    return _ShadowThreshold;
}

#endif