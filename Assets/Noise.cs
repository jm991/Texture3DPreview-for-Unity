using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Noise : MonoBehaviour
{
    /// <summary>
    /// Convenience enum, indices match the kernel numbers in the generateNoise compute shader.
    /// </summary>
    public enum NoiseType
    {
        Perlin = 0,
        Turbulence = 1
    }

    /// <summary> An inspector reference to the compute shader which generates all the noise we are going to be using. </summary>
    public ComputeShader noiseGenerator;

    /// <summary> Which type of noise should be use to generate the 'puffs'. <see cref="NoiseType"/> </summary>
    public NoiseType noiseType;

    /// <summary> Should the noise be animated with time.  This is the same as pausing the animation.</summary>
    public bool animateNoise;

    /// <summary> Min freq value, used for calculating the octaves in the turbulence noise kernel. </summary>
    [Range(0.01f, 1.0f)]
    public float minFrequency = 0.01f;

    /// <summary> Max freq value, used for calculating the octaves in the turbulence noise kernel. </summary>
    [Range(0.01f, 5.0f)]
    public float maxFrequency = 2.0f;

    /// <summary> Width value, used for calculating the octaves in the turbulence noise kernel. </summary>
    [Range(0.01f, 1.0f)]
    public float width = 0.01f;

    /// <summary> This is basically the amplitude of the noise. </summary>
    [Range(0f, 5f)]
    public float distortionAmount = 4;

    /// <summary> This is the frequency of the noise. </summary>
    [Range(0f, 5f)]
    public float noiseScale = 1;

    /// <summary> Noise animation speed, axis independant. </summary>
    public Vector3 noiseAnimationSpeed;

    /// <summary> Flag that lets us know if the users graphics card supports DX11. </summary>
    internal bool supportDX11;

    /// <summary> This is the current time value (modified by the speed <seealso cref="noiseAnimationSpeed"/>) for the animation of the noise. </summary>
    private Vector3 noiseAnimationScroller;

    [SerializeField]
    /// <summary> Noise calculated in compute shader <seealso cref="noiseGenerator"/> is held in this volume texture. </summary>
    private RenderTexture noiseVolumeTexture;

    [SerializeField]
    /// <summary> Test material for applying 3D compute shader texture to. </summary>
    private Material material;

    [SerializeField]
    /// <summary> Name of the Shader's 3D texture property you want to put the noise texture into. </summary>
    private string texturePropertyName = "_MainTex";

    /// <summary>
    /// Unity callback,
    /// 
    /// Checks to see if DX11 is supported, and destroys this object if it's not.
    /// </summary>
    private void Awake()
    {
        /*
        supportDX11 = material.shader.isSupported;

        if (!supportDX11)
        {
            Debug.LogError("DirectX 11 is not supported on this graphics card, it is necessary to run this demo.");
            Destroy(this);
        }
        */
    }

    /// <summary>
    /// Unity callback,
    /// 
    /// Used to initialize the scene; noise volume, gradient map and the object buffer.
    /// </summary>
    private void Start()
    {
        if (material == null)
        {
            material = this.GetComponent<Renderer>().material;
        }

        InitializeNoiseVolume();
    }

    // Update is called once per frame
    void Update()
    {
        UpdateComputeShader();
    }

    /// <summary>
    /// Creates a 128x128x128 size UAV volume texture.  And passes it to the pixel shader.
    /// </summary>
    private void InitializeNoiseVolume()
    {
        noiseVolumeTexture = new RenderTexture(128, 128, 0, RenderTextureFormat.RFloat)
        {
            isVolume = true,
            volumeDepth = 128,
            enableRandomWrite = true,
            wrapMode = TextureWrapMode.Repeat,
            name = "Noise Texture"
        };

        noiseVolumeTexture.Create();
        
        material.SetTexture(texturePropertyName, noiseVolumeTexture);
    }

    /// <summary>
    /// Updates the parameters in the compute shader, scrolls the noise and dispatches the specified noise kernel.
    /// 
    /// PERFORMANCE NOTE : No point in running this constantly if the animateNoise flag isnt checked...  So don't.
    /// </summary>
    private void UpdateComputeShader()
    {
        if (!animateNoise) return;

        noiseGenerator.SetFloat("_Amplitude", distortionAmount);
        noiseGenerator.SetFloat("_Frequency", noiseScale);

        noiseAnimationScroller += noiseAnimationSpeed * Time.deltaTime;
        noiseGenerator.SetVector("_Animation", noiseAnimationScroller);

        // The plan was to have more noise types here.
        switch (noiseType)
        {
            case NoiseType.Turbulence:
                noiseGenerator.SetFloat("_MinFrequency", Mathf.Max(0.01f, minFrequency));
                noiseGenerator.SetFloat("_MaxFrequency", Mathf.Max(0.01f, maxFrequency));
                noiseGenerator.SetFloat("_QWidth", Mathf.Max(0.01f, width));
                break;
        }

        noiseGenerator.SetTexture((int)noiseType, "_Output", noiseVolumeTexture);
        noiseGenerator.Dispatch((int)noiseType, 16, 16, 16);
    }
}
