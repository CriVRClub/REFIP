// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "REFIP/Ice"
{

	Properties
	{
		_MainTex("Main Texture (RGB)", 2D) = "white" {}
		_NoiseTex("Noise text", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)

			//		_Period("Period", Range(0,50)) = 1
		_Magnitude("Magnitude", Range(0,1)) = 0.05
		_Scale("Scale", Range(0,10)) = 1
		_Whiteness("Whiteness", Range(0,2)) = 0.4
		_Power("Fresnel Power", Range(0,20)) = 1
		_Bias("Bias", Range(0,1)) = 0.2
		_FresnelColor("Fresnel Color", Color) = (1,1,1,1)
		_FresnelScale("Fresne Scale", Range(0,10)) = 1
	}

		SubShader
		{
			Tags
		{
			"Queue" = "Transparent"
		}

		GrabPass{}

		Pass
		{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"

		sampler2D _GrabTexture;
		sampler2D _MainTex;
		sampler2D _NoiseTex;
		fixed4 _Color;
		//	float _Period;
		float _Magnitude;
		float _Scale;
		float _Whiteness;
		float _Power;
		float _Bias;
		fixed4 _FresnelColor;
		float _FresnelScale;

		struct vertInput
		{
			float4 vertex : POSITION;
			float2 texCoord : TEXCOORD0;
			float2 normalTexcoord : NORMAL;
		};

		struct vertOutput
		{
			float4 vertex : POSITION;
			fixed4 color : COLOR;
			float2 normalTexcoord : NORMAL;
			float2 texCoord : TEXCOORD0;
			float3 worldPos : TEXCOORD1;
			float4 uvgrab : TEXCOORD2;
			float R : TEXCOORD3;
		};

		vertOutput vert(vertInput i)
		{
			vertOutput o;
			o.vertex = UnityObjectToClipPos(i.vertex);
			o.uvgrab = ComputeGrabScreenPos(o.vertex);
			o.worldPos = mul(unity_ObjectToWorld, i.vertex).xyz;
			o.normalTexcoord = normalize(mul(
				unity_ObjectToWorld,
				i.normalTexcoord
			));
			float3 I = normalize(o.worldPos - _WorldSpaceCameraPos.xyz);
			o.texCoord = i.texCoord;
			o.R = _Bias + _FresnelScale * pow(saturate(1.0 + dot(I, o.normalTexcoord)), _Power);
			//o.R = _FresnelScale * pow(1.0 + dot(I, o.normalTexcoord), _Power);
			//o.R = dot(I, o.normalTexcoord);
			//o.R = I;
			//o.R = o.normalTexcoord;
			//o.R = _Bias;
			return o;
		}

		half4 frag(vertOutput o) : COLOR
		{
	//		float sinT = sin(_Time.w / _Period);
			float2 distortion = float2(
			//		tex2D(_NoiseTex, o.worldPos.xy / _Scale + float2(sinT,0)).r - 0.5,
			//		tex2D(_NoiseTex, o.worldPos.xy / _Scale + float2(0,sinT)).r - 0.5
			tex2D(_NoiseTex, o.worldPos.xy / _Scale).r - 0.5 ,
				tex2D(_NoiseTex, o.worldPos.xy / _Scale).r - 0.5
					);
				o.uvgrab.xy += distortion * _Magnitude;

				fixed4 col = tex2D(_MainTex, o.texCoord);
				col *= tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(o.uvgrab));
				fixed4 colFinal =  col * _Color;//we add whiteness to the result to make it  more snowy
				colFinal += fixed4(_Whiteness, _Whiteness, _Whiteness, 0);
				return lerp(colFinal, _FresnelColor, o.R);
				//return colFinal;
				}
				ENDCG
			}
		}
}
