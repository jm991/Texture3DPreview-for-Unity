// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "DX11 Competition/Debug - 3D Texture" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 3D) = "white" {}
	}
	SubShader 
	{
		Pass
		{
			Tags { "RenderType"="Opaque" }
			LOD 200
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler3D _MainTex;

			struct v2f
			{
				float4 pos : POSITION;
				float3 uvw : TEXCOORD0;
			};

			v2f vert(appdata_base v)
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				o.uvw = (v.vertex.xyz + 1.0f) * 0.5f;

				return o;
			}

			half4 frag(v2f i) : COLOR
			{
				return tex3D(_MainTex, i.uvw);
			}

			ENDCG
		}
	} 
	FallBack Off
}
