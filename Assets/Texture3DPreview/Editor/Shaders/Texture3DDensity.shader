Shader "Custom/Texture3DDensity"
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
                float MaxSteps = 32;
                int XYFrames = 12;


                /* STEP 1: Debug BoundingBoxBased_0-1_UVW -> CurPos*/
                float3 CurPos = IN.color;
                //return fixed4(CurPos, 1);

                /* STEP 2: Debug localcamvec -> */
                float3 localCameraPosition = UNITY_MATRIX_IT_MV[3].xyz;
                float3 localcamvec = normalize(localCameraPosition - IN.localPos);
                //return fixed4(localcamvec, 1);

                /* STEP 3: Try looping with psuedo texture*/
                float numFrames = XYFrames * XYFrames;
                float accumdist = 0;
                float StepSize = 1 / MaxSteps;

                for (int i = 0; i < MaxSteps; i++)
                {
                    float4 cursample = tex3D(_MainTex, saturate(CurPos)).a;                    // float cursample = PseudoVolumeTexture(_PsuedoTex, saturate(CurPos), XYFrames, numFrames).r;
                    accumdist += cursample * StepSize;
                    CurPos += -localcamvec * StepSize;
                }

                return float4(1, 1, 1, accumdist);
            }
            ENDCG
        }
    }
}