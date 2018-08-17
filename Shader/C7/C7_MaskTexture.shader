Shader "Unity Shader Book/C7_MaskTexture" {
	Properties {
		_Color("Color Tint",COLOR) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white"{}
		_BumpMap("Normal Map", 2D) = "bump"{}
		_BumpScale("Bump Scale", Range(0,2)) = 1
		_SpecularMask("Specular Mask", 2D) = "white"{}
		_SpecularScale("SpecularScale", Range(0,2)) = 1
		_Specular("Specular",COLOR) = (1,1,1,1)
		_Gloss("Gloss", Range(8.0,256)) = 32
	}
	SubShader {
		Pass
		{	
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "Lighting.cginc"
		
				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _BumpMap;
				float _BumpScale;
				sampler2D _SpecularMask;
				float _SpecularScale;
				fixed4 _Specular;
				float _Gloss;

				struct a2v{
					float4 vertex:POSITION;
					float3 normal:NORMAL;
					float4 tangent:TANGENT;
					float4 texcoord:TEXCOORD0;
				};

				struct v2f{
					float4 pos:POSITION;
					float2 uv:TEXCOORD0;
					float3 lightDir:TEXCOORD1;
					float3 viewDir:TEXCOORD2;
				};

				v2f vert(a2v v):POSITION
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					float3 binormal = cross(normalize(v.normal),normalize(v.tangent.xyz)) * v.tangent.w;
					float3x3 rotation = float3x3(v.tangent.xyz,binormal,v.normal);
					o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
					o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
					o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
					return o;				
				}

				fixed4 frag(v2f i):SV_TARGET0
				{
					fixed3 tangentLightDir = normalize(i.lightDir);
					fixed3 tangentViewDir = normalize(i.viewDir);
					fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv));
					tangentNormal.xy *= _BumpScale;
					tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xyz)));
					
					fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

					fixed3 diffuse = albedo * _LightColor0.rgb * (dot(tangentLightDir, tangentNormal) * 0.5 + 0.5);

					fixed3 halfDir = normalize(tangentViewDir + tangentLightDir);

					fixed specularMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;
			
					fixed3 specular = _LightColor0.rgb * _Specular.rgb * specularMask * pow(max(dot(halfDir, tangentNormal),0.0),_Gloss);
					
					return fixed4(ambient + diffuse + specular, 1.0);
				}

			ENDCG
		}

		
	}
	FallBack "Diffuse"
}
