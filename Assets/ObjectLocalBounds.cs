using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectLocalBounds : MonoBehaviour {
    public Bounds bounds;
    public Vector3 localBoundsMinimum;
    public Vector3 localBoundsSize;
    public MeshFilter meshFilter;
    public Renderer renderer;

    // Use this for initialization
    void Start()
    {
        meshFilter = this.GetComponent<MeshFilter>();
        renderer = this.GetComponent<Renderer>();
    }
	
	// Update is called once per frame
	void Update()
    {
        bounds = meshFilter.mesh.bounds;
        localBoundsMinimum = bounds.min;
        localBoundsSize = bounds.size;
        renderer.material.SetVector("_LocalBoundsMinimum", localBoundsMinimum);
        renderer.material.SetVector("_LocalBoundsSize", localBoundsSize);
    }
}
