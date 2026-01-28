Shader "DP/PortalMiddle"
{
    Properties
    {
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}

        _DistortMap("Distortion Texture", 2D) = "white" {}
        _DistortSpeed("Distortion Scroll Speed", float) = 2
        _DistortStrength("Distortion Strength", float) = 2
        
        [HDR] _OutlineColor("Outline Color (RGB)", Color) = (0, 1, 0, 1)
        _OutlineStrength("Outline Strength", float) = 8
        _OutlineThresholdMax("Outline Threshold Max", float) = 1

        _FadeDistance("Fade Distance", float) = 20
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                
                float2 uv : TEXCOORD0;
                float2 uvDistort : TEXCOORD1;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionVS : TEXCOORD3;

                float2 uv : TEXCOORD0;
                
                float4 uvDistort : TEXCOORD1;
                float4 screenPos : TEXCOORD2;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            TEXTURE2D(_DistortMap);
            SAMPLER(sampler_DistortMap);

            float _DistortSpeed;
            float _DistortStrength;

            float _OutlineStrength;
            
            CBUFFER_START(UnityPerMaterial)
                float4 _OutlineColor;
                float4 _BaseMap_ST;
                float4 _DistortMap_ST;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                
                float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);

                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.positionVS = TransformWorldToView(positionWS);

                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                OUT.uvDistort = float4(0,0,0,0);
                OUT.uvDistort.xy = TRANSFORM_TEX(IN.uvDistort, _DistortMap);
                OUT.uvDistort.zw = OUT.uvDistort.xy;

                OUT.uvDistort.y -= _DistortSpeed * _Time.x;
                OUT.uvDistort.z += _DistortSpeed * _Time.x;

                OUT.screenPos = ComputeScreenPos(OUT.positionHCS);

                return OUT;
            }

            float LinearDepthToNonLinear(float linear01Depth, float4 zBufferParam){
                // Inverse of Linear01Depth
                return (1.0 - (linear01Depth * zBufferParam.y)) / (linear01Depth * zBufferParam.x);
            }

            float EyeDepthToNonLinear(float eyeDepth, float4 zBufferParam){
                // Inverse of LinearEyeDepth
                return (1.0 - (eyeDepth * zBufferParam.w)) / (eyeDepth * zBufferParam.z);
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float2 distortTexture = SAMPLE_TEXTURE2D(_DistortMap, sampler_DistortMap, IN.uvDistort.xy);
                distortTexture  *= _DistortStrength / 100;
                
                float2 distortTexture2 = SAMPLE_TEXTURE2D(_DistortMap, sampler_DistortMap, IN.uvDistort.zw);
                distortTexture2 *= _DistortStrength / 100;

                float combinedDistortion = distortTexture + distortTexture2;

                float2 screenSpaceUV = IN.screenPos.xy / IN.screenPos.w;

                float fragmentEyeDepth = -IN.positionVS.z;
                float rawDepth = SampleSceneDepth(screenSpaceUV);
                float sceneEyeDepth = LinearEyeDepth(rawDepth, _ZBufferParams);
                float depthDifference = 1 - saturate((sceneEyeDepth - fragmentEyeDepth) * _OutlineStrength);

                float3 coloredDepth = depthDifference * _OutlineColor;

                float2 portalBackgroundUV = screenSpaceUV + combinedDistortion;
                half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, portalBackgroundUV);

                return float4(lerp(color.xyz, coloredDepth, depthDifference), 1.0);
            }
            ENDHLSL
        }
    }
}
