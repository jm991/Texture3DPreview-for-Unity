// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:UwBoAGEAZABlAHIAQgBpAHQAcwA=,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:33267,y:32667,varname:node_3138,prsc:2|emission-4807-OUT;n:type:ShaderForge.SFN_Code,id:4807,x:32272,y:32515,varname:node_4807,prsc:2,code:cgBlAHQAdQByAG4AIABHAHIAYQBkAGkAZQBuAHQATgBvAGkAcwBlADMARABfAEEATABVACgAUABvAHMAaQB0AGkAbwBuACwAIAB0AHIAdQBlACwAIAA1ADEAMgApADsA,output:2,fname:Noise,width:430,height:132,input:2,input_1_label:Position|A-1059-OUT;n:type:ShaderForge.SFN_ValueProperty,id:7015,x:32049,y:33028,ptovrint:False,ptlb:R,ptin:_R,cmnt:Radius of sphere,varname:node_7015,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.25;n:type:ShaderForge.SFN_ValueProperty,id:33,x:32560,y:32726,ptovrint:False,ptlb:N,ptin:_N,cmnt:Noise amount,varname:node_33,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Multiply,id:3907,x:32800,y:32575,varname:node_3907,prsc:2|A-4807-OUT,B-33-OUT;n:type:ShaderForge.SFN_Add,id:3854,x:33024,y:32765,varname:node_3854,prsc:2|A-3907-OUT,B-2151-OUT;n:type:ShaderForge.SFN_OneMinus,id:2151,x:32560,y:32863,varname:node_2151,prsc:2|IN-2981-OUT;n:type:ShaderForge.SFN_Vector4Property,id:5442,x:32049,y:32787,ptovrint:False,ptlb:P,ptin:_P,cmnt:Position,varname:node_5442,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.5,v2:0.5,v3:0.5,v4:0;n:type:ShaderForge.SFN_Divide,id:2981,x:32352,y:32863,varname:node_2981,prsc:2|A-5442-XYZ,B-7015-OUT;n:type:ShaderForge.SFN_TexCoord,id:2124,x:31839,y:32515,varname:node_2124,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Append,id:1059,x:32052,y:32515,varname:node_1059,prsc:2|A-2124-UVOUT,B-4170-OUT;n:type:ShaderForge.SFN_Vector1,id:4170,x:31858,y:32716,varname:node_4170,prsc:2,v1:0;proporder:33-5442-7015;pass:END;sub:END;*/

Shader "Shader Forge/3DNoiseTest" {
    Properties {
        _N ("N", Float ) = 1
        _P ("P", Vector) = (0.5,0.5,0.5,0)
        _R ("R", Float ) = 0.25
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #include "ShaderBits.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            float3 Noise( float3 Position ){
            return GradientNoise3D_ALU(Position, true, 512);
            }
            
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
////// Lighting:
////// Emissive:
                float3 node_4807 = Noise( float3(i.uv0,0.0) );
                float3 emissive = node_4807;
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
