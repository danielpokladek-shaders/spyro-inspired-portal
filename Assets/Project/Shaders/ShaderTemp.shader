Shader "DP/PortalInner"
{
    Properties
    {
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}

        _DistortMap("Distortion Texture", 2D) = "white" {}
        _DistortStrength("Distortion Strength", float) = 2
        _DistortAnimationVector("Animation Direction", vector, 2) = (0, 1, 0, 0)
        _DistortAnimationSpeed("Animation Speed", float) = 2
    }

    SubShader
    {
        Tags {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                
                float2 uv : TEXCOORD0;
                float2 uvDistort : TEXCOORD2;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                
                float2 uv : TEXCOORD0;
                float2 uvDistort : TEXCOORD2;

                float4 screenPos : TEXCOORD1;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            TEXTURE2D(_DistortMap);
            SAMPLER(sampler_DistortMap);

            float _DistortStrength;
            float _DistortAnimationSpeed;
            float4 _DistortAnimationVector;
            
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                float4 _DistortMap_ST;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
            
                OUT.positionHCS = TransformObjectToHClip(
                    IN.positionOS.xyz
                );
                
                OUT.uv = TRANSFORM_TEX(
                    IN.uv,
                    _BaseMap
                );

                float2 uvDistort = TRANSFORM_TEX(
                    IN.uvDistort,
                    _DistortMap
                );

                float2 distortOffset = _DistortAnimationVector.xy;
                distortOffset *= _Time.x * _DistortAnimationSpeed;

                OUT.uvDistort = uvDistort - distortOffset;

                OUT.screenPos = ComputeScreenPos(OUT.positionHCS);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float distortTexture = SAMPLE_TEXTURE2D(
                    _DistortMap,
                    sampler_DistortMap,
                    IN.uvDistort
                );
                distortTexture *= _DistortStrength;

                float2 screenSpaceUV = IN.screenPos.xy / IN.screenPos.w;

                float2 backgroundUV = screenSpaceUV;
                backgroundUV += distortTexture;

                half4 color = SAMPLE_TEXTURE2D(
                    _BaseMap,
                    sampler_BaseMap,
                    backgroundUV
                );

                return color;
                // return float4(distortTexture, distortTexture, distortTexture, 1.0);
            }
            ENDHLSL
        }
    }
}