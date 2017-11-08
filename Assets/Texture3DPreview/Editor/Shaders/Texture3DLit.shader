Shader "Custom/Texture3DLit"
{
    Properties
    {
        _MainTex("Texture", 3D) = "" {}
        _PsuedoTex("2D Texture", 2D) = "" {}

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
                float Steps = 32;    // int in Unreal
                float StepSize = 1 / Steps;
                int Density = 64;
                int ShadowSteps = 32;
                int ShadowDensity = 64;
                float4 LightVector = float4(1.0, 0.15, 1.0, 1.0);
                
                // Unreal setup - from other nodes
                int MaxSteps = Steps;
                float3 localCameraPosition = UNITY_MATRIX_IT_MV[3].xyz;
                float3 CurPos = IN.color;

                // Start of Density RayMarch node
                float numFrames = XYFrames * XYFrames;
                float curdensity = 0;
                float transmittance = 1;
                float3 localcamvec = normalize(localCameraPosition - IN.localPos);

                float shadowstepsize = 1 / ShadowSteps;
                LightVector *= shadowstepsize;
                ShadowDensity *= shadowstepsize;

                /* STEP 3: Try looping with psuedo texture*/
                float accumdist = 0;

                for (int i = 0; i < MaxSteps; i++)
                {
                    float4 cursample = tex3D(_MainTex, saturate(CurPos)).a;                    accumdist += cursample * StepSize;
                    CurPos += -localcamvec * StepSize;
                }

                return float4(1, 1, 1, accumdist);
            }
            ENDCG
        }
    }
}