using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Texture3DViewer : MonoBehaviour
{
    public Texture3D texture3D;
    public Material PreviewTexture3dMaterial;
    public int samplingIterations = 64;
    public float density = 1f;

    // Use this for initialization
    void Start()
    {
		
	}
	
	// Update is called once per frame
	void Update()
    {
        if (PreviewTexture3dMaterial != null && texture3D != null)
        {
            PreviewTexture3dMaterial.SetInt("_SamplingQuality", samplingIterations);
            PreviewTexture3dMaterial.SetTexture("_MainTex", texture3D);
            PreviewTexture3dMaterial.SetFloat("_Density", density);
        }
    }
}
