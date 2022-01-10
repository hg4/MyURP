#ifndef TOON_LIT_INPUT_INCLUDED
#define TOON_LIT_INPUT_INCLUDED

TEXTURE2D(_CameraDepthTexture);
SAMPLER(sampler_CameraDepthTexture);
TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);
TEXTURE2D(_RampMap);
SAMPLER(sampler_RampMap);
CBUFFER_START(UnityPerMaterial)
float4 _BaseMap_ST;
float4 _BaseColor;
float4 _MidColor;
float4 _ShadowColor;
float4 _OutlineColor;
float _OutlineWidth;
float _Cutoff;
float _OcclusionIndirectStrength;
float4 _IndirectLightMinColor;
float _IndirectLightFactor;
float _ReceiveShadowPosOffset;
float _IntensityGI;
float _ShadowSmooth;
float _ShadowThreshold;
float _RimFeather;
float4 _RimColor;
float _RimLength;
float _RimWidth;
CBUFFER_END

float GetOutlineWidth()
{
    return _OutlineWidth;
}

float4 GetOutlineColor()
{
    return _OutlineColor;

}

float4 GetBaseColor()
{
    return _BaseColor;
}
float4 GetShadowColor()
{
    return _ShadowColor;
}
float4 GetMidColor()
{
    return _MidColor;
}
float GetShadowSmooth()
{
    return _ShadowSmooth;
}
float GetShadowThreshold()
{
    return _ShadowThreshold;
}

float GetIntensityGI()
{
    return _IntensityGI;
}
float4 GetBaseMap(float2 uv)
{
    return SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
}
float3 GetRampMap(float2 uv)
{
    return SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, uv).rgb;
}
float GetDepthTexture(float2 screenUV)
{
    return SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, screenUV).r;
}
float GetRimWidth()
{
    return _RimWidth;
}
float GetRimLength()
{
    return _RimLength;
}
float GetRimFeather()
{
    return _RimFeather;
}
float4 GetRimColor()
{
    return _RimColor;
}
#endif