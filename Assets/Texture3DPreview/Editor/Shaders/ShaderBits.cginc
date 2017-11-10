// Order matters in .cginc - functions must be in the order of depencency -> dependent

float4 RayMarchCubeSetup(float MaxSteps, float3 localPos, float3 LocalBoundsMaximum)
{
    // Unreal setup - move to properties
    float PlaneAlignment = 1;

    //bring vectors into local space to support object transforms
    float3 localcampos = (UNITY_MATRIX_IT_MV[3].xyz);
    float3 localcamvec = normalize(localcampos - localPos);

    //make camera position 0-1
    localcampos = (localcampos / (LocalBoundsMaximum.x * 2)) + 0.5;

    float3 invraydir = 1 / localcamvec;

    float3 firstintersections = (0 - localcampos) * invraydir;
    firstintersections = (0 - firstintersections);
    float3 secondintersections = (1 - localcampos) * invraydir;
    secondintersections = (0 - secondintersections);
    float3 closest = min(firstintersections, secondintersections);
    float3 furthest = max(firstintersections, secondintersections);

    float t0 = max(closest.x, max(closest.y, closest.z));
    float t1 = min(furthest.x, min(furthest.y, furthest.z));

    float planeoffset = 1.0 - frac((t0 - length(localcampos - 0.5)) * MaxSteps);

    t0 += (planeoffset / MaxSteps) * PlaneAlignment;
    t0 = max(0, t0);

    float boxthickness = max(0, t1 - t0);
    float3 entrypos = localcampos - (max(0, t0) * localcamvec);

    return float4(entrypos, boxthickness);
}


float Distort(Texture3D noiseVolume, SamplerState samplerNoiseVolume, float3 pos)
{
    float3 inputPosition = pos * 0.1f;

    return noiseVolume.SampleLevel(samplerNoiseVolume, inputPosition, 0);
}


// -----------------------------------------------------------------------------------------
// Source: Unreal Engine 4.15; C:\Program Files\Epic Games\UE_4.15\Engine\Shaders\Common.usf
// -----------------------------------------------------------------------------------------

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


// -----------------------------------------------------------------------------------------
// Source: Unreal Engine 4.15; C:\Program Files\Epic Games\UE_4.15\Engine\Shaders\Random.usf
// -----------------------------------------------------------------------------------------

// References for noise:
//
// Fast Gradient Noise
//   http://prettyprocs.wordpress.com/2012/10/20/fast-perlin-noise


// 3D random number generator inspired by PCGs (permuted congruential generator)
// Using a **simple** Feistel cipher in place of the usual xor shift permutation step
// @param v = 3D integer coordinate
// @return three elements w/ 16 random bits each (0-0xffff).
// ~8 ALU operations for result.x    (7 mad, 1 >>)
// ~10 ALU operations for result.xy  (8 mad, 2 >>)
// ~12 ALU operations for result.xyz (9 mad, 3 >>)
// From 
uint3 Rand3DPCG16(int3 p)
{
    // taking a signed int then reinterpreting as unsigned gives good behavior for negatives
    uint3 v = uint3(p);

    // Linear congruential step. These LCG constants are from Numerical Recipies
    // For additional #'s, PCG would do multiple LCG steps and scramble each on output
    // So v here is the RNG state
    v = v * 1664525u + 1013904223u;

    // PCG uses xorshift for the final shuffle, but it is expensive (and cheap
    // versions of xorshift have visible artifacts). Instead, use simple MAD Feistel steps
    //
    // Feistel ciphers divide the state into separate parts (usually by bits)
    // then apply a series of permutation steps one part at a time. The permutations
    // use a reversible operation (usually ^) to part being updated with the result of
    // a permutation function on the other parts and the key.
    //
    // In this case, I'm using v.x, v.y and v.z as the parts, using + instead of ^ for
    // the combination function, and just multiplying the other two parts (no key) for 
    // the permutation function.
    //
    // That gives a simple mad per round.
    v.x += v.y*v.z;
    v.y += v.z*v.x;
    v.z += v.x*v.y;
    v.x += v.y*v.z;
    v.y += v.z*v.x;
    v.z += v.x*v.y;

    // only top 16 bits are well shuffled
    return v >> 16u;
}

// Wraps noise for tiling texture creation
// @param v = unwrapped texture parameter
// @param bTiling = true to tile, false to not tile
// @param RepeatSize = number of units before repeating
// @return either original or wrapped coord
float3 NoiseTileWrap(float3 v, bool bTiling, float RepeatSize)
{
    return bTiling ? (frac(v / RepeatSize) * RepeatSize) : v;
}

// compute Perlin and related noise corner seed values
// @param v = 3D noise argument, use float3(x,y,0) for 2D or float3(x,0,0) for 1D
// @param bTiling = true to return seed values for a repeating noise pattern
// @param RepeatSize = integer units before tiling in each dimension
// @param seed000-seed111 = hash function seeds for the eight corners
// @return fractional part of v
float3 NoiseSeeds(float3 v, bool bTiling, float RepeatSize,
    out float seed000, out float seed001, out float seed010, out float seed011,
    out float seed100, out float seed101, out float seed110, out float seed111)
{
    float3 fv = frac(v);
    float3 iv = floor(v);

    const float3 primes = float3(19, 47, 101);

    if (bTiling)
    {	// can't algebraically combine with primes
        seed000 = dot(primes, NoiseTileWrap(iv, true, RepeatSize));
        seed100 = dot(primes, NoiseTileWrap(iv + float3(1, 0, 0), true, RepeatSize));
        seed010 = dot(primes, NoiseTileWrap(iv + float3(0, 1, 0), true, RepeatSize));
        seed110 = dot(primes, NoiseTileWrap(iv + float3(1, 1, 0), true, RepeatSize));
        seed001 = dot(primes, NoiseTileWrap(iv + float3(0, 0, 1), true, RepeatSize));
        seed101 = dot(primes, NoiseTileWrap(iv + float3(1, 0, 1), true, RepeatSize));
        seed011 = dot(primes, NoiseTileWrap(iv + float3(0, 1, 1), true, RepeatSize));
        seed111 = dot(primes, NoiseTileWrap(iv + float3(1, 1, 1), true, RepeatSize));
    }
    else
    {	// get to combine offsets with multiplication by primes in this case
        seed000 = dot(iv, primes);
        seed100 = seed000 + primes.x;
        seed010 = seed000 + primes.y;
        seed110 = seed100 + primes.y;
        seed001 = seed000 + primes.z;
        seed101 = seed100 + primes.z;
        seed011 = seed010 + primes.z;
        seed111 = seed110 + primes.z;
    }

    return fv;
}

#define MGradientMask int3(0x8000, 0x4000, 0x2000)
#define MGradientScale float3(1. / 0x4000, 1. / 0x2000, 1. / 0x1000)
// Modified noise gradient term
// @param seed - random seed for integer lattice position
// @param offset - [-1,1] offset of evaluation point from lattice point
// @return gradient direction (xyz) and contribution (w) from this lattice point
float4 MGradient(int seed, float3 offset)
{
    uint rand = Rand3DPCG16(int3(seed, 0, 0)).x;
    float3 direction = float3(rand.xxx & MGradientMask) * MGradientScale - 1;
    return float4(direction, dot(direction, offset));
}

// Evaluate polynomial to get smooth transitions for Perlin noise
// only needed by Perlin functions in this file
// scalar(per component): 2 add, 5 mul
float4 PerlinRamp(float4 t)
{
    return t * t * t * (t * (t * 6 - 15) + 10);
}

// Perlin-style "Modified Noise"
// http://www.umbc.edu/~olano/papers/index.html#mNoise
// @param v = 3D noise argument, use float3(x,y,0) for 2D or float3(x,0,0) for 1D
// @param bTiling = repeat noise pattern
// @param RepeatSize = integer units before tiling in each dimension
// @return random number in the range -1 .. 1
float GradientNoise3D_ALU(float3 v, bool bTiling, float RepeatSize)
{
    float seed000, seed001, seed010, seed011, seed100, seed101, seed110, seed111;
    float3 fv = NoiseSeeds(v, bTiling, RepeatSize, seed000, seed001, seed010, seed011, seed100, seed101, seed110, seed111);

    float rand000 = MGradient(int(seed000), fv - float3(0, 0, 0)).w;
    float rand100 = MGradient(int(seed100), fv - float3(1, 0, 0)).w;
    float rand010 = MGradient(int(seed010), fv - float3(0, 1, 0)).w;
    float rand110 = MGradient(int(seed110), fv - float3(1, 1, 0)).w;
    float rand001 = MGradient(int(seed001), fv - float3(0, 0, 1)).w;
    float rand101 = MGradient(int(seed101), fv - float3(1, 0, 1)).w;
    float rand011 = MGradient(int(seed011), fv - float3(0, 1, 1)).w;
    float rand111 = MGradient(int(seed111), fv - float3(1, 1, 1)).w;

    float3 Weights = PerlinRamp(float4(fv, 0)).xyz;

    float i = lerp(lerp(rand000, rand100, Weights.x), lerp(rand010, rand110, Weights.x), Weights.y);
    float j = lerp(lerp(rand001, rand101, Weights.x), lerp(rand011, rand111, Weights.x), Weights.y);
    return lerp(i, j, Weights.z).x;
}

/*
// @return random number in the range -1 .. 1
// scalar: 6 frac, 31 mul/mad, 15 add, 
float FastGradientPerlinNoise3D_TEX(float3 xyz)
{
    // needs to be the same value when creating the PerlinNoise3D texture
    float Extent = 16;

    // last texel replicated and needed for filtering
    // scalar: 3 frac, 6 mul
    xyz = frac(xyz / (Extent - 1)) * (Extent - 1);

    // scalar: 3 frac
    float3 uvw = frac(xyz);
    // = floor(xyz);
    // scalar: 3 add
    float3 p0 = xyz - uvw;
    //	float3 f = pow(uvw, 2) * 3.0f - pow(uvw, 3) * 2.0f;	// original perlin hermite (ok when used without bump mapping)
    // scalar: 2*3 add 5*3 mul
    float3 f = PerlinRamp(float4(uvw, 0)).xyz;	// new, better with continues second derivative for bump mapping
                                                // scalar: 3 add
    float3 p = p0 + f;
    // scalar: 3 mad
    float4 NoiseSample = Texture3DSampleLevel(View.PerlinNoise3DTexture, View.PerlinNoise3DTextureSampler, p / Extent + 0.5f / Extent, 0);		// +0.5f to get rid of bilinear offset

                                                                                                                                                // reconstruct from 8bit (using mad with 2 constants and dot4 was same instruction count)
                                                                                                                                                // scalar: 4 mad, 3 mul, 3 add 
    float3 n = NoiseSample.xyz * 255.0f / 127.0f - 1.0f;
    float d = NoiseSample.w * 255.f - 127;
    return dot(xyz, n) - d;
}
*/
