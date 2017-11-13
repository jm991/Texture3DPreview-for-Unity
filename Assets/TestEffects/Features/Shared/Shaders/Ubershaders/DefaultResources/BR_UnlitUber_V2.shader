Shader "Bend Reality/VFX Uber Shader"
{
	Properties
	{
		// GUI
		_Foldout_Layers("_Foldout_Layers", Float) = 1   
		_Foldout_UV("_Foldout_UV", Float) = 1    
		_Foldout_Vert("_Foldout_Vert", Float) = 1 
		_Foldout_VertGen("_Foldout_VertGen", Float) = 1  
		_Foldout_FragGen("_Foldout_FragGen", Float) = 1
		_Foldout_Generators("_Foldout_Generators", Float) = 1

		_Active_L0("_Active_L0", Float) = 1
		_Active_L1("_Active_L1", Float) = 1
		_Active_L2("_Active_L2", Float) = 1 
		_Active_L3("_Active_L3", Float) = 1 

		_VC_RG_AS_UV("_VC_RG_AS_UV", Float) = 0
		_VC_BA_AS_UV("_VC_BA_AS_UV", Float) = 0

		// Shader
		[KeywordEnum(Opaque,Transparent,Add,Subtract,Multiply)] _shaderBlendMode("_shaderBlendMode", Float) = 0
		[HideInInspector] _SrcBlend("__src", Float) = 1.0
		[HideInInspector] _DstBlend("__dst", Float) = 0.0
		[HideInInspector] _ZWrite("__zw", Float) = 1.0
		[HideInInspector] _blendOp("__bo", Float) = 0
		[Toggle] _ZWritePrePass("_ZWritePrePass", Float) = 0


		[Header(Main Generator Selector)] 
		_BR_PF_SELECTOR_GenMap ("_BR_PF_SELECTOR_GenMap", Vector) = (0,0,0,0)   
	    _BR_PF_SELECTOR_GenFrag("_BR_PF_SELECTOR_GenFrag", Vector) = (0,0,0,0)
		
		//[Header(_Selectors __________________________)]
		[KeywordEnum(R,G,B,A)] _BR_PF_SELECTOR_c_Gen("_BR_PF_SELECTOR_c_Gen", Float) = 0  
		[KeywordEnum(R,G,B,A)] _BR_PF_SELECTOR_c_FragGen ("_BR_PF_SELECTOR_c_FragGen", Float) = 0
		[KeywordEnum(MeshUV0,MeshUV1)] _BR_PF_SELECTOR_c_UV0Src("_BR_PF_SELECTOR_c_UV0Src", Float) = 0 
		[KeywordEnum(MeshUV0,MeshUV1)] _BR_PF_SELECTOR_c_UV1Src("_BR_PF_SELECTOR_c_UV1Src", Float) = 0
		[KeywordEnum(MeshUV0,MeshUV1)] _BR_PF_SELECTOR_c_VCRGSrc ("_BR_PF_SELECTOR_c_VCRGSrc", Float) = 0 
		[KeywordEnum(MeshUV0,MeshUV1)] _BR_PF_SELECTOR_c_VCRBArc ("_BR_PF_SELECTOR_c_VCRBArc", Float) = 0
		[KeywordEnum(Channel0,Channel1,Channel2,Channel3)] _BR_PF_SELECTOR_c_UV0Gen("_BR_PF_SELECTOR_c_UV0Gen", Float) = 0
		[KeywordEnum(Channel0,Channel1,Channel2,Channel3)] _BR_PF_SELECTOR_c_UV0Mask("_BR_PF_SELECTOR_c_UV0Mask", Float) = 0
		[KeywordEnum(Channel0,Channel1,Channel2,Channel3)] _BR_PF_SELECTOR_c_UV1Gen("_BR_PF_SELECTOR_c_UV1Gen", Float) = 0 
		[KeywordEnum(Channel0,Channel1,Channel2,Channel3)] _BR_PF_SELECTOR_c_UV1Mask("_BR_PF_SELECTOR_c_UV1Mask", Float) = 0
		[KeywordEnum(Channel0,Channel1,Channel2,Channel3)] _BR_PF_SELECTOR_c_VertPushMask("_BR_PF_SELECTOR_c_VertPushMask", Float) = 0
		[KeywordEnum(Channel0,Channel1,Channel2,Channel3)] _BR_PF_SELECTOR_c_VertPushGen("_BR_PF_SELECTOR_c_VertPushGen", Float) = 0 
		[KeywordEnum(Channel0,Channel1,Channel2,Channel3)] _BR_PF_SELECTOR_c_NormalPushMask("_BR_PF_SELECTOR_c_NormalPushMask", Float) = 0 
		[KeywordEnum(Channel0,Channel1,Channel2,Channel3)] _BR_PF_SELECTOR_c_NormalPushGen("_BR_PF_SELECTOR_c_NormalPushGen", Float) = 0
		 
		//[Header(_Remap __________________________)]
		_BRPF_REMAP_m_FragGen_ch0("_BRPF_REMAP_m_FragGen_ch0", Vector) = (0,1,1,1)
		_BRPF_REMAP_m_FragGen_ch1("_BRPF_REMAP_m_FragGen_ch1", Vector) = (0,1,1,1)
		_BRPF_REMAP_m_FragGen_ch2("_BRPF_REMAP_m_FragGen_ch2", Vector) = (0,1,1,1)
		_BRPF_REMAP_m_FragGen_ch3("_BRPF_REMAP_m_FragGen_ch3", Vector) = (0,1,1,1)
		  
		_BRPF_REMAP_m_VertGen_ch0("_BRPF_REMAP_m_VertGen_ch0", Vector) = (0,1,1,1)
		_BRPF_REMAP_m_VertGen_ch1("_BRPF_REMAP_m_VertGen_ch1", Vector) = (0,1,1,1)
		_BRPF_REMAP_m_VertGen_ch2("_BRPF_REMAP_m_VertGen_ch2", Vector) = (0,1,1,1)
		_BRPF_REMAP_m_VertGen_ch3("_BRPF_REMAP_m_VertGen_ch3", Vector) = (0,1,1,1)
		  
		 //[Header(_Axis __________________________)]
		 [KeywordEnum(X,Y,Z)] _BRG_AXIS_a_VertGen ("_BRG_AXIS_a_VertGen", Float) = 0

		//[Header(_VectorPush __________________________)]
		_BRPF_VECTORPUSH_d_NormPush("_BRPF_VECTORPUSH_d_NormPush", Float) = 0
		_BRPF_VECTORPUSH_dir_PosOffset("_BRPF_VECTORPUSH_dir_PosOffset", Vector) = (0,0,0,1)  
		_BRPF_VECTORPUSH_dir_UV0Push("_BRPF_VECTORPUSH_dir_UV0Push", Vector) = (0,0,0,0)  
		_BRPF_VECTORPUSH_dir_UV1Push("_BRPF_VECTORPUSH_dir_UV1Push", Vector) = (0,0,0,0)
		_BRPF_VECTORPUSH_d_UV0Offset("_BRPF_VECTORPUSH_d_UV0Offset", Float) = 0
		_BRPF_VECTORPUSH_d_UV1Offset("_BRPF_VECTORPUSH_d_UV1Offset", Float) = 0     
		
		//[Header(_Transforms __________________________)]   
		_BRPF_XFORM_tc_UV0("_BRPF_XFORM_tc_UV0", Vector) = (0,0,0.5,0.5)  
		_BRPF_XFORM_rs_UV0("_BRPF_XFORM_rs_UV0", Vector) = (1,1,0,0)  
		_BRPF_XFORM_tc_UV1("_BRPF_XFORM_tc_UV1", Vector) = (0,0,0.5,0.5)
		_BRPF_XFORM_rs_UV1("_BRPF_XFORM_rs_UV1", Vector) = (1,1,0,0)
		_BRPF_XFORM_ts_Verts("_BRPF_XFORM_ts_Verts", Vector) = (0,0,0,1)
			 
		_BRPF_XFORM_tc_RG ("_BRPF_XFORM_tc_RG", Vector) = (0,0,0.5,0.5)
		_BRPF_XFORM_rs_RG ("_BRPF_XFORM_rs_RG", Vector) = (1,1,0,0) 
		_BRPF_XFORM_tc_BA ("_BRPF_XFORM_tc_BA", Vector) = (0,0,0.5,0.5)   
		_BRPF_XFORM_rs_BA ("_BRPF_XFORM_rs_BA", Vector) = (1,1,0,0) 
		  
		//[Header(_Masks __________________________)]
		_BRPF_MASK_c_NormPush ("_BRPF_MASK_c_NormPush", Float) = 0 
			   
		//[Header(_SNoise __________________________)]
		_BRG_SNOISE_ts_VertGen ("_BRG_SNOISE_ts_VertGen", Vector) = (0,0,0,1)
		_BRG_SNOISE_ts_FragGen ("_BRG_SNOISE_ts_FragGen", Vector) = (0,0,0,1)  
		  
		//[Header(Second Point __________________________)] 
		_BRG_SECONDPOINT_FragGen ("_BRG_SECONDPOINT_FragGen", vector) = (0,0,0,0)

		//[Header(Direction __________________________)]
		_BRG_DIRGRADIENT_dir_VertGen("_BRG_DIRGRADIENT_dir_VertGen", Vector) = (0,1,0,0)
		_BRG_DIRGRADIENTLS_dir_VertGen("_BRG_DIRGRADIENTLS_dir_VertGen", Vector) = (0,1,0,0)
		_BRG_DIRGRADIENT_dir_FragGen("_BRG_DIRGRADIENT_dir_FragGen", Vector) = (0,1,0,0) 
		 
		//[Header(Constants __________________________)]
		_BRPF_CONST_VertGen("_BRPF_CONST_VertGen", Float) = 1   
		_BRPF_CONST_FragGen("_BRPF_CONST_FragGen", Float) = 1  
		 
		//[Header(_Layers __________________________)]
		_Tex_L0("_Tex_L0", 2D) = "white" {}
		_Tex_L1("_Tex_L1", 2D) = "white" {}
		_Tex_L2("_Tex_L2", 2D) = "white" {} 
		_Tex_L3("_Tex_L3", 2D) = "white" {}
		 
		_Color_Base("_Color_Base", Color) = (1,1,1,1) 
		_Color_L0("_Color_L0", Color) = (1,1,1,1) 
		_Color_L1("_Color_L1", Color) = (1,1,1,1) 
		_Color_L2("_Color_L2", Color) = (1,1,1,1)
		_Color_L3("_Color_L3", Color) = (1,1,1,1)
			 
		_ColorMult_Base("_ColorMult_Base", Float) = 1
		_ColorMult_L0("_ColorMult_L0", Float) = 1
		_ColorMult_L1("_ColorMult_L1", Float) = 1
		_ColorMult_L2("_ColorMult_L2", Float) = 1
		_ColorMult_L3("_ColorMult_L3", Float) = 1
			 
		[KeywordEnum(UV0,UV1, VertColorRG, VertColorBA)] _UVSrc_L0("_UVSrc_L0", Float) = 0
		[KeywordEnum(UV0,UV1, VertColorRG, VertColorBA)] _UVSrc_L1("_UVSrc_L1", Float) = 0
		[KeywordEnum(UV0,UV1, VertColorRG, VertColorBA)] _UVSrc_L2("_UVSrc_L2", Float) = 0
		[KeywordEnum(UV0,UV1, VertColorRG, VertColorBA)] _UVSrc_L3("_UVSrc_L3", Float) = 0  

		[KeywordEnum(Normal,Multiply,Screen,Difference,LinearDidge,Darken,Lighten)] _BlendMode_L0("_BlendMode_L0", Float) = 0
		[KeywordEnum(Normal,Multiply,Screen,Difference,LinearDidge,Darken,Lighten)] _BlendMode_L1("_BlendMode_L1", Float) = 0 
		[KeywordEnum(Normal,Multiply,Screen,Difference,LinearDidge,Darken,Lighten)] _BlendMode_L2("_BlendMode_L2", Float) = 0
		[KeywordEnum(Normal,Multiply,Screen,Difference,LinearDidge,Darken,Lighten)] _BlendMode_L3("_BlendMode_L3", Float) = 0
		  
		_BlendModeA_Base("_BlendModeA_Base", Float) = 0
		_BlendModeA_L0("_BlendModeA_L0", Float) = 0
		_BlendModeA_L1("_BlendModeA_L1", Float) = 0
		_BlendModeA_L2("_BlendModeA_L2", Float) = 0
		_BlendModeA_L3("_BlendModeA_L3", Float) = 0 
		 
		_AlphaSrc_L0("_AlphaSrc_L0", Float) = 0
		_AlphaSrc_L1("_AlphaSrc_L1", Float) = 0 
		_AlphaSrc_L2("_AlphaSrc_L2", Float) = 0
		_AlphaSrc_L3("_AlphaSrc_L3", Float) = 0

		 _WriteColorToUV_L0("_WriteColorToUV_L0", Float) = 0
		 _WriteColorToUV_L1("_WriteColorToUV_L1", Float) = 0
		 _WriteColorToUV_L2("_WriteColorToUV_L2", Float) = 0
		 _WriteColorToUV_L3("_WriteColorToUV_L3", Float) = 0
	}  
		SubShader 
		{
			//Tags { "RenderType" = "Opaque" "DisableBatching" = "True"}
			
			//LOD 100

			//ZWrite Off 
			Pass
			{
				ColorMask 0
			}			


			Pass
			{
				Name "BRFXMAIN"
				Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "DisableBatching" = "True" }
				
				BlendOp [_blendOp]
				Blend [_SrcBlend] [_DstBlend]
				ZWrite [_ZWrite]
			
				//ZWrite Off
				Cull Off
				//Blend SrcAlpha OneMinusSrcAlpha
				ColorMask RGB
				Lighting Off
				
				CGPROGRAM
				
				#pragma shader_feature __ ACTIVE_L0
				#pragma shader_feature __ ACTIVE_L1
				#pragma shader_feature __ ACTIVE_L2
				#pragma shader_feature __ ACTIVE_L3

				#pragma shader_feature __ VC_RG_AS_UV
				#pragma shader_feature __ VC_BA_AS_UV

				#pragma vertex vert
				#pragma fragment frag				

			#include "../CGIncludes/UnityBR_V2.cginc"
			ENDCG
		}
	} 

	CustomEditor "BR_UnlitUber_v2GUI"
}
 