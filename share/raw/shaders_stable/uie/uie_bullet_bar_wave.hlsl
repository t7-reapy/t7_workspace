#include "lib/globals.hlsl"
#include "lib/transform.hlsl"
#include "postfx/postfx_common.h"

Texture2D<float4> colorMap : register(t0);
SamplerState colorSampler : register(s0);

struct VertexInput
{
	float3 position		: POSITION;
	float4 color		: COLOR;
	float2 texCoords	: TEXCOORD;
};

struct PixelInput
{
	float4 position		: SV_POSITION;
	float4 color		: COLOR;
	float2 texCoords	: TEXCOORD;
};

PixelInput vs_main( const VertexInput vertex )    
{                                                
    PixelInput pixel;

    pixel.position = Transform_OffsetToClip(vertex.position);
    pixel.texCoords = vertex.texCoords;
    pixel.color = vertex.color;

    return pixel;
}

float4 ps_main(in PixelInput pixel) : SV_TARGET
{
	float2 uv = pixel.texCoords;

	// passed from lua
	int clipAmmo = (int)scriptVector0.x;
	int clipMaxAmmo = (int)scriptVector0.y;
	int clipRowLength = (int)scriptVector0.z;
	float darkness = scriptVector0.w;
	
	int rows = (ceil(clipMaxAmmo / (float)clipRowLength)); // how many rows we have should be constant while using the same weapon
	
	float2 adjustedTexCoords = float2(uv.x*clipRowLength, uv.y*rows); // scale the uv on the quad by the length of the row on the x axis and the number of rows on the y axis
	float4 color = colorMap.Sample(colorSampler, adjustedTexCoords) * pixel.color;
   
   	// get information for where we are within the image
   	int row = (int)(uv.y*rows); // row where pixel occurs

	// row 0 is the top-most row, this will be the row that we need to hide part of for bullet counts > clipMaxAmmo
   	if(row == 0) {
   		int partialRowLength = clipRowLength - clipMaxAmmo % clipRowLength;
   		if(partialRowLength != clipRowLength && uv.x <  partialRowLength / (float)clipRowLength) { 
   		   	// return color*float4(darkness, darkness, darkness,1);
   			return float4(0,0,0,0);
   		}
   	}
   	
   	// dont bog down shader with extra processing when ammo is full
   	if(clipAmmo == clipMaxAmmo) {
   		return color;
   	}
   	
   	int remainingBullets = clipAmmo % clipRowLength;
   	int activeRow = rows - (clipAmmo / (float)clipRowLength); // this is the row that is currently being emptied by the player
   	if(row == activeRow) {
	   	float activeRowWidth = (remainingBullets / (float)clipRowLength); // % full that the active ammo row is
   		int lastActiveRow = rows - (clamp((clipAmmo + 1), 0, clipMaxAmmo) / (float)clipRowLength); // this is the next row down from the active row
		// if lastActiveRow doesn't match active row then it means we have a full row
		if(lastActiveRow != activeRow && remainingBullets == 0) {
			return color;
		}
		
		if(row % 2 == 0) {
		   	if(uv.x <= 1-activeRowWidth) {
		   		return color*darkness;
		   	}
		}
		else {
			if(uv.x >= activeRowWidth) {
		   		return color*darkness;
		   	}
		}
   	}
   	else if(row < activeRow) {
   		return color*darkness;
   	}
   
    return color;
}