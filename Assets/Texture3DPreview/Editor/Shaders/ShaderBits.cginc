inline float2 Convert1dto2d(float XSize, float idx)
{
    float2 xyidx = 0;
    xyidx.x = fmod(idx, XSize);
    xyidx.y = floor(idx / XSize);

    return xyidx;
}


//** Tex       **// Input Texture Object storing Volume Data
//** inPos     **// Input float3 for Position, 0-1
//** xsize    **// Input float for num frames in x,y directions
//** numFrames **// Input float for num total frames
float4 PseudoVolumeTexture(sampler2D Tex, float3 inPos, float xsize, float numframes)
{
    float zframe = ceil(inPos.z * numframes);
    float zphase = frac(inPos.z * numframes);

    float2 uv = frac(inPos.xy) / xsize;

    float2 curframe = Convert1dto2d(xsize, zframe) / xsize;
    float2 nextframe = Convert1dto2d(xsize, zframe + 1) / xsize;

    float sampleA = tex2D(Tex, uv + curframe);
    float sampleB = tex2D(Tex, uv + nextframe);

    return lerp(sampleA, sampleB, zphase);
}
