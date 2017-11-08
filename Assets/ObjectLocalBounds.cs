using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class ObjectLocalBounds : MonoBehaviour {
    public Bounds bounds;
    public Vector3 localBoundsMinimum;
    public Vector3 localBoundsSize;
    public MeshFilter meshFilter;
    public Renderer rend;
    public Light sun;

    // Use this for initialization
    void Start()
    {
        meshFilter = this.GetComponent<MeshFilter>();
        rend = this.GetComponent<Renderer>();
        sun = FindObjectsOfType<Light>().ToList().FirstOrDefault<Light>(x => x.type == LightType.Directional);
    }
	
	// Update is called once per frame
	void Update()
    {
        bounds = meshFilter.mesh.bounds;
        localBoundsMinimum = bounds.min;
        localBoundsSize = bounds.size;
        rend.material.SetVector("_LocalBoundsMinimum", localBoundsMinimum);
        rend.material.SetVector("_LocalBoundsSize", localBoundsSize);
        rend.material.SetVector("_LightVector", sun.transform.rotation.eulerAngles);
    }
}
