using UnityEngine;

public class Create3DTex : MonoBehaviour
{
    public Texture3D tex;
    public int size = 16;
    int x1 = 0;
    int y1 = 0;
    int z1 = 0;

    public bool fromTextures = true;
    public Texture2D[] slices;
    public bool singleChannel = false;

    void Start()
    {
        // assumes square texture slices
        if (fromTextures)
        {
            size = slices[0].width;
        }

        tex = new Texture3D(size, size, size, TextureFormat.ARGB32, false);
        tex.anisoLevel = 16;
        Color[] cols = new Color[size * size * size];

        if (!fromTextures)
        {
            float mul = 1.0f / (size - 1);
            int idx = 0;
            Color c = Color.white;
            for (int z = 0; z < size; ++z)
            {
                for (int y = 0; y < size; ++y)
                {
                    for (int x = 0; x < size; ++x, ++idx)
                    {
                        c.r = ((x1) != 0) ? x * mul : 1 - x * mul;
                        c.g = ((y1) != 0) ? y * mul : 1 - y * mul;
                        c.b = ((z1) != 0) ? z * mul : 1 - z * mul;
                        cols[idx] = c;
                    }
                }
            }
        }
        else
        {
            int idx = 0;
            for (int z = 0; z < size; ++z)
            {
                for (int y = 0; y < size; ++y)
                {
                    for (int x = 0; x < size; ++x, ++idx)
                    {
                        if (!singleChannel)
                        {
                            cols[idx] = slices[z].GetPixel(x, y);
                        }
                        else
                        {
                            Color pixel = slices[z].GetPixel(x, y);
                            cols[idx] = new Color(1, 1, 1, pixel.r);
                        }
                    }
                }
            }
        }


        tex.SetPixels(cols);
        tex.Apply();
        UnityEditor.AssetDatabase.CreateAsset(tex, "Assets/Test3DTexture.asset");
        // renderer.material.SetTexture("_Volume", tex);
    }
}