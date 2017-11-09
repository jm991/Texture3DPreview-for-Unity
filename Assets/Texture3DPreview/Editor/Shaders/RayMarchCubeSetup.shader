Shader "Custom/RaymarchCubeSetup"
{
    Properties
    {
        _LocalBoundsSize("LocalBoundsSize", Vector) = (1,1,1,0)
        _LocalBoundsMinimum("LocalBoundsMinimum", Vector) = (-0.5,-0.5,-0.5,0)
        _LocalBoundsMaximum("LocalBoundsMax", Vector) = (0.5,0.5,0.5,0)
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

            uniform float4 _LocalBoundsSize;
            uniform float4 _LocalBoundsMinimum;
            uniform float4 _LocalBoundsMaximum;

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
                float MaxSteps = 4;
                float PlaneAlignment = 1;
                
                //bring vectors into local space to support object transforms
                float3 localcampos = normalize(UNITY_MATRIX_IT_MV[3].xyz);
                //return float4(localcampos, 1);
                float3 localcamvec = normalize(localcampos - IN.localPos);
                //return float4(localcamvec, 1);

                //make camera position 0-1
                localcampos = (localcampos / (_LocalBoundsMaximum.x * 2)) + 0.5;
                //return float4(localcampos, 1);

                float3 invraydir = 1 / localcamvec;
                //return float4(invraydir, 1);

                float3 firstintersections = (0 - localcampos) * invraydir;
                firstintersections = (0 - firstintersections);  // difference between Unity and Unreal?
                //return float4(firstintersections, 1);
                float3 secondintersections = (1 - localcampos) * invraydir;
                secondintersections = (0 - secondintersections);
                //return float4(secondintersections, 1);

                /*
                float3 temp = firstintersections;
                firstintersections = secondintersections;
                secondintersections = temp;
                */

                float3 closest = min(firstintersections, secondintersections);
                //return float4(closest, 1);
                float3 furthest = max(firstintersections, secondintersections);
                //return float4(furthest, 1);

                float t0 = max(closest.x, max(closest.y, closest.z));
                //return float4(t0,t0,t0,1);
                float t1 = min(furthest.x, min(furthest.y, furthest.z));
                //return float4(t1,t1,t1,1);

                float planeoffset = 1.0 - frac((t0 - length(localcampos - 0.5)) * MaxSteps);
                //return float4(planeoffset, planeoffset, planeoffset, 1);

                t0 += (planeoffset / MaxSteps) * PlaneAlignment;
                //return float4(t0,t0,t0,1);
                t0 = max(0, t0);
                //return float4(t0,t0,t0,1);

                float boxthickness = max(0, t1 - t0);
                //return float4(boxthickness, boxthickness, boxthickness, 1);
                //return float4((localcampos - localcamvec), 1.0f);   // this looks like Unreal's (localcampos + localcamvec)
                // float3 entrypos = localcampos + (max(0, t0) * localcamvec); // this is the broken value
                float3 entrypos = localcampos - (max(0, t0) * localcamvec); // switched + to - to fix it
                //return float4(entrypos, 1.0f);

                return float4(entrypos, boxthickness);
            }
            ENDCG
        }
    }
}