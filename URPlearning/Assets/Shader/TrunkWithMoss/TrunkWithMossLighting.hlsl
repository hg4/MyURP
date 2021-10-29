#ifndef TRUNK_WITH_MOSS_LIGHTING_INCLUDED
#define TRUNK_WITH_MOSS_LIGHTING_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct SurfaceData
{
	float3 baseColor;
	float3 litColor;
	float3 shadowColor;
	float3 specColor;
	float3 normal;
	float3 color;
	float3 viewDir;
	float3 position;
	float isMoss;
	float smoothness;
	float alpha;
	float4 shadowCoord;
	float3 bakedGI;
	float layer;
};




half3 LightingBackSSS(SurfaceData surface, Light light)
{
	float3 backLitDir = normalize(surface.normal * GetBackSSDistortion() + light.direction);
	half sss = saturate(dot(surface.viewDir, -backLitDir));
	sss = saturate(pow(sss, GetRimLightPower()));
	half NdotV = saturate(dot(surface.normal, surface.viewDir));
	half normalAttenuation = pow(1 - NdotV, GetRimLightPower());
	return sss * GetSSSIntensity() * GetSSSColor() * normalAttenuation;
}

half4 GetLighting(SurfaceData surface)
{
	Light mainLight = GetMainLight(surface.shadowCoord);
	MixRealtimeAndBakedGI(mainLight, surface.normal, surface.bakedGI, half4(0, 0, 0, 0));

	half3 ambient = surface.bakedGI * GetIntensityGI();
	half halfLambert = 0.5 * dot(surface.normal, mainLight.direction) + 0.5;
	half wrapLambert = smoothstep(0, GetShadowSmooth(), halfLambert - GetShadowThreshold());
	half3 diffuse = mainLight.color * lerp(surface.shadowColor, surface.litColor, 
		wrapLambert * (mainLight.distanceAttenuation * mainLight.shadowAttenuation));
	//trick spec, not change with viewDir
	half3 specular = LightingSpecular(mainLight.color, mainLight.direction, surface.normal,
		mainLight.direction, half4(surface.specColor, 1.0), surface.smoothness) 
		* (mainLight.distanceAttenuation * mainLight.shadowAttenuation);
	half3 sss = surface.layer > 0 ? LightingBackSSS(surface, mainLight) : 0;
#ifdef _ADDITIONAL_LIGHTS
	int additionalLightsCount = GetAdditionalLightsCount();
	for (int i = 0; i < additionalLightsCount; ++i)
	{
		int index = GetPerObjectLightIndex(i);
		Light light = GetAdditionalPerObjectLight(index, surface.position);
		half halfLambert = 0.5 * dot(surface.normal, light.direction) + 0.5;
		half wrapLambert = smoothstep(0, GetShadowSmooth(), halfLambert - GetShadowThreshold());
		half3 diffuse = light.color * lerp(surface.shadowColor, surface.litColor,
			wrapLambert * (light.distanceAttenuation * light.shadowAttenuation));
		specular += LightingSpecular(light.color, surface.viewDir, surface.normal,
			light.direction, half4(surface.specColor, 1.0), surface.smoothness);
	}
#endif
	return half4((ambient + diffuse)*surface.baseColor + specular * surface.layer 
		* (1-surface.color.r) + sss, surface.alpha);
}
#endif