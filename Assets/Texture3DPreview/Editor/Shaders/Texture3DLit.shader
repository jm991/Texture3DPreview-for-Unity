Shader "Custom/Texture3DLit"
{
    Properties
    {
        _MainTex("Texture", 3D) = "" {}
        _MaxSteps("Max Steps", Int) = 64
        _Density("Density", Float) = 1    // int 64 in Unreal
        _ShadowSteps("Shadow Steps", Int) = 32
        _ShadowDensity("Shadow Density", Int) = 64
        _LightVector("Light Vector", Vector) = (1.0, 0.15, 1.0, 1.0) // TODO: swap for ShaderForge implementation
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
        }

        CGINCLUDE
        #include "UnityCG.cginc"

        int _MaxSteps;
        sampler3D _MainTex;
        float _Density;
        int _ShadowDensity;
        int _ShadowSteps;
        float4 _LightVector;

        struct v2f
        {
            float4 pos : SV_POSITION;
            float3 localPos : TEXCOORD0;
            float4 screenPos : TEXCOORD1;
            float3 worldPos : TEXCOORD2;
        };

        v2f vert(appdata_base v)
        {
            v2f OUT;
            OUT.pos = UnityObjectToClipPos(v.vertex);
            OUT.localPos = v.vertex.xyz;
            OUT.screenPos = ComputeScreenPos(OUT.pos);
            COMPUTE_EYEDEPTH(OUT.screenPos.z);
            OUT.worldPos = mul(unity_ObjectToWorld, v.vertex);
            return OUT;
        }

        // usual ray/cube intersection algorithm
        struct Ray
        {
            float3 origin;
            float3 direction;
        };
        bool IntersectBox(Ray ray, out float entryPoint, out float exitPoint)
        {
            float3 invR = 1.0 / ray.direction;
            float3 tbot = invR * (float3(-0.5, -0.5, -0.5) - ray.origin);
            float3 ttop = invR * (float3(0.5, 0.5, 0.5) - ray.origin);
            float3 tmin = min(ttop, tbot);
            float3 tmax = max(ttop, tbot);
            float2 t = max(tmin.xx, tmin.yz);
            entryPoint = max(t.x, t.y);
            t = min(tmax.xx, tmax.yz);
            exitPoint = min(t.x, t.y);
            return entryPoint <= exitPoint;
        }

        float4 frag(v2f IN) : COLOR
        {
            // float3 LightVector = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - IN.worldPos.xyz, _WorldSpaceLightPos0.w)); // from ShaderForge - could be sent in by script too
                        
            float3 localCameraPosition = UNITY_MATRIX_IT_MV[3].xyz;
            //float curdensity = 0;
            //float transmittance = 1;

            //float shadowstepsize = 1 / _ShadowSteps;
            //_LightVector *= shadowstepsize;
            //_ShadowDensity *= shadowstepsize;
    
            Ray localCamera;
            localCamera.origin = localCameraPosition;
            localCamera.direction = normalize(IN.localPos - localCameraPosition);

            float entryPoint, exitPoint;
            IntersectBox(localCamera, entryPoint, exitPoint);
        
            if (entryPoint < 0.0) entryPoint = 0.0;

            float3 rayStart = localCamera.origin + localCamera.direction * entryPoint;
            float3 rayStop = localCamera.origin + localCamera.direction * exitPoint;

            float3 start = rayStop;
            float dist = distance(rayStop, rayStart);
            float stepSize = dist / float(_MaxSteps);
            float3 stepSizeVector = normalize(rayStop - rayStart) * stepSize;
            
            // _Density *= stepSize;
            // float3 lightenergy = 0;
                
            float4 color = float4(0,0,0,0);
            for (int i = _MaxSteps; i >= 0; --i)
            {
                float3 pos = start.xyz;
                pos.xyz = pos.xyz + 0.5f;
                float4 mask = tex3D(_MainTex, pos);
                    
                color.xyz += mask.rgb * mask.a;
                
                start -= stepSizeVector;
            }
            color *= _Density / (uint)_MaxSteps;

            return color;
        }
        ENDCG

        Pass
        {
            Cull front
            Blend One One
            ZWrite false

            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            ENDCG

        }
    }
}