// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/Texture3DLit"
{
    Properties
    {
        _MainTex("Texture", 3D) = "" {}
        _PsuedoTex("2D Texture", 2D) = "" {}
        _LightVector("Light Vector", Vector) = (1.0, 0.15, 1.0, 1.0)

        _LocalBoundsSize("LocalBoundsSize", Vector) = (1,1,1,0)
        _LocalBoundsMinimum("LocalBoundsMinimum", Vector) = (-0.5,-0.5,-0.5,0)
    }
    SubShader
    {
        Pass
        {
            Tags
            {
                "Queue" = "Transparent"
                "RenderType" = "ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite false

            CGPROGRAM
            #pragma target 5.0

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "ShaderBits.cginc"

            sampler3D _MainTex;
            sampler2D _PsuedoTex;
            uniform float4 _LightVector;

            uniform float4 _LocalBoundsSize;
            uniform float4 _LocalBoundsMinimum;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 localPos : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                fixed4 color : COLOR;
            };

            v2f vert(appdata_base v)
            {
                v2f OUT;
                OUT.pos = UnityObjectToClipPos(v.vertex);
                OUT.localPos = v.vertex.xyz;
                OUT.screenPos = ComputeScreenPos(OUT.pos);
                COMPUTE_EYEDEPTH(OUT.screenPos.z);
                OUT.worldPos = mul(unity_ObjectToWorld, v.vertex);
                OUT.color = (v.vertex - _LocalBoundsMinimum) / _LocalBoundsSize;
                return OUT;
            }

            float4 frag(v2f IN) : COLOR
            {
                // Unreal setup - move to properties
                int XYFrames = 12;  // unused since we have 3D textures in Unity
                float Steps = 64;    // int in Unreal
                float StepSize = 1 / Steps;
                float Density = 64;
                float ShadowSteps = 32;
                float ShadowDensity = 64;
                float4 LightVector = mul(unity_WorldToObject, normalize(_LightVector));                
                
                // Unreal setup - from other nodes
                int MaxSteps = Steps;
                float3 localCameraPosition = UNITY_MATRIX_IT_MV[3].xyz;
                float3 CurPos = IN.color;

                // Start of Density RayMarch node
                float numFrames = XYFrames * XYFrames;
                float curdensity = 0;
                float transmittance = 1;
                float3 localcamvec = normalize(localCameraPosition - IN.localPos) * StepSize;

                float shadowstepsize = 1 / ShadowSteps;
                LightVector *= shadowstepsize;
                ShadowDensity *= shadowstepsize;

                Density *= StepSize;
                float3 lightenergy = 0;

                for (int i = 0; i < MaxSteps; i++)
                {
                    float cursample = tex3D(_MainTex, saturate(CurPos)).a;                    
                    // Sample Light Absorption and Scattering
                    if (cursample > 0.001f)
                    {
                        float3 lpos = CurPos;
                        float shadowdist = 0;

                        for (int s = 0; s < ShadowSteps; s++)
                        {
                            lpos += LightVector;
                            float lsample = tex3D(_MainTex, saturate(lpos)).a;
                            shadowdist += lsample;
                        }

                        curdensity = saturate(cursample * Density);
                        float shadowterm = exp(-shadowdist * ShadowDensity);
                        float3 absorbedlight = shadowterm * curdensity;
                        lightenergy += absorbedlight * transmittance;
                        transmittance *= 1 - curdensity;
                    }
                    CurPos -= localcamvec;
                }

                return float4(lightenergy, 1 - transmittance);
            }
            ENDCG
        }
    }
}