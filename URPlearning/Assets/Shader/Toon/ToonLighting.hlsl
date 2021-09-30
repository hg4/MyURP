#ifndef TOON_LIGHTING_INCLUDED
#define TOON_LIGHTING_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

float3 ShadeGI(ToonSurfaceData surface)
{
    // hide 3D feeling by ignoring all detail SH
    // SH 1 (only use this)
    // SH 234 (ignored)
    // SH 56789 (ignored)
    // we just want to tint some average envi color only
    float3 averageSH = SampleSH(0);

    // occlusion
    // separated control for indirect occlusion
    float indirectOcclusion = lerp(1, surface.occlusion, _OcclusionIndirectStrength);
    float3 indirectLight = averageSH * (_IndirectLightFactor * indirectOcclusion);
    return max(indirectLight, _IndirectLightMinColor.rgb); // can prevent completely black if lightprobe was not baked
}
float3 ShadeHighLight(ToonSurfaceData surface,Light light)
{
    return 0;
}
float3 ShadeRimLight(ToonSurfaceData surface,Light light)
{
    return 0;
}
float2 ShadeRampFactor(ToonSurfaceData surface,Light light)
{
    float2 factor = float2(0, 0);
    float halfLambert = (0.5 * dot(surface.normalWS, light.direction) + 0.5);
    float NdotL = dot(surface.normalWS, light.direction);
    float NdotV = dot(surface.normalWS, surface.viewDirectionWS);
    float ramp = 0;
    #ifndef _THREE_STEP
    ramp = smoothstep(0, GetShadowSmooth(), halfLambert - GetShadowThreshold());
    factor.x = ramp;
    return factor;
    #else
    float smooth = GetShadowSmooth();
    float v = halfLambert - GetShadowThreshold();

    float rampA = smoothstep(0,  smooth/ 2, v);
    float rampB = smoothstep( smooth / 2,smooth, v);
    float ramp = rampA - rampB;
    factor.x = ramp;
    factor.y = v < smooth/2 ? 1 : 0;
    return factor;
    #endif
    
}
float3 GetRampShadeColor(ToonSurfaceData surface, float2 factor)
{
    float3 color = float3(0, 0, 0);
#ifndef _RAMP_SHADOWS
    float3 baseColor = surface.color * GetBaseColor();
    float3 shadowColor = surface.color * GetShadowColor();
    #ifndef _THREE_STEP
    color = lerp(shadowColor, baseColor, factor.x);
    #else
    float3 midColor = surface.color * GetMidColor();
    color = factor.y == 1 ? lerp(shadowColor,midColor,factor.x) :
        lerp(baseColor,midColor,factor.y);
    #endif
#else
    color = GetRampMap(factor).rgb;
    #endif
    return color;
}
float3 GetFinalToonResult(ToonSurfaceData surface, float2 rampResult,float3 rimLightResult,float3 highLightResult,
    float3 indirectResult, Light light)
{
    float3 color = float3(0, 0, 0);
    float3 diffuseColor = GetRampShadeColor(surface, rampResult) * light.color;
    color = sqrt(SoftLight(diffuseColor, indirectResult)) + highLightResult;
    //color = lerp(color, rimLightResult, GetRimStrength());
    return color;
}
float4 GetToonLighting(ToonSurfaceData surface)
{
    float3 finalColor = 0.0;
    float3 indirectResult = ShadeGI(surface);
    Light light = GetMainLight();
    #ifdef _SELF_SHADOWS
    float3 shadowTestPosWS = lightingData.positionWS + mainLight.direction * _ReceiveShadowPosOffset;
    float4 shadowCoord = TransformWorldToShadowCoord(shadowTestPosWS);
    mainLight.shadowAttenuation = MainLightRealtimeShadow(shadowCoord);
    #endif
    float2 rampResult = ShadeRampFactor(surface,light);
    float3 rimLightResult = ShadeRimLight(surface, light);
    float3 highLightResult = ShadeHighLight(surface, light);
    finalColor = GetFinalToonResult(surface, rampResult, rimLightResult, highLightResult, indirectResult,light);
    return float4(finalColor, surface.alpha);
}


#endif