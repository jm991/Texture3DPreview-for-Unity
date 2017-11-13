using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class Stages : MonoBehaviour
{
    public List<GameObject> stages;
    public GameObject cameraRig;
    public GameObject dirLightRig;
    public float rotationAmt = 1f;
    public float lightRotationAmt = 0.5f;

	// Use this for initialization
	void Start()
    {
		
	}
	
	// Update is called once per frame
	void Update()
    {
        Quaternion rotation = Quaternion.Euler(new Vector3(0, Time.time * rotationAmt));
        Quaternion lightRotation = Quaternion.Euler(new Vector3(0, Time.time * lightRotationAmt));
        cameraRig.transform.rotation = rotation;
        dirLightRig.transform.rotation = lightRotation;

        int key = -1;
        if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            key = 0;
        }
        else if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            key = 1;
        }
        else if (Input.GetKeyDown(KeyCode.Alpha3))
        {
            key = 2;
        }
        else if (Input.GetKeyDown(KeyCode.Alpha4))
        {
            key = 3;
        }
        else if (Input.GetKeyDown(KeyCode.Alpha5))
        {
            key = 4;
        }
        else if (Input.GetKeyDown(KeyCode.Alpha6))
        {
            key = 5;
        }

        if (key != -1)
        {
            stages.ForEach(x => x.SetActive(false));
            stages[key].SetActive(true);
            stages[key].GetComponentsInChildren<ParticleSystem>().ToList().ForEach(x => x.Play());
        }
    }
}
