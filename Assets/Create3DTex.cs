using UnityEngine;

public class Create3DTex : MonoBehaviour
{
    public Texture3D tex;
    public int size = 16;
    int x1 = 0;
    int y1 = 0;
    int z1 = 0;

    public bool fromTextures = true;
    [SerializeField]
    private SignedDistanceFunctions.SDFunctions function = SignedDistanceFunctions.SDFunctions.None;
    public Texture2D[] slices;
    public bool singleChannel = false;
    public bool subUV = false;
    public Texture2D subUVTexture;


    void Start()
    {
        tex = new Texture3D(size, size, size, TextureFormat.ARGB32, false);
        tex.anisoLevel = 16;
        Color[] cols = new Color[size * size * size];
        int idx = 0;

        if (function != SignedDistanceFunctions.SDFunctions.None)
        {
            for (int z = 0; z < size; ++z)
            {
                for (int y = 0; y < size; ++y)
                {
                    for (int x = 0; x < size; ++x, ++idx)
                    {
                        float sphere = SignedDistanceFunctions.sdSphere(new Vector3(x, y, z), 0.5f);
                        Debug.Log(sphere);
                        cols[idx] = new Color(sphere, sphere, sphere, sphere);
                    }
                }
            }
        }
        else if (!fromTextures)
        {
            float mul = 1.0f / (size - 1);
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
            if (subUV)
            {
                Texture2D tex = subUVTexture;
                Debug.Log("Texture size: " + tex.width + ", " + tex.height);

                // TODO: force check to make sure tex.width / size is a whole number
                // TODO: force check to make sure tex.width == tex.height
                int sliceSize = tex.width / size;

                for (int z = 0; z < sliceSize; ++z)
                {
                    for (int y = 0; y < sliceSize; ++y)
                    {
                        for (int x = 0; x < sliceSize; ++x, ++idx)
                        {
                            Vector2 pixelUV = new Vector2(x, y);

                            // Apply texture sheet animation offset
                            // Code taken and modifed from https://github.com/jm991/ParticleCollisionTest/blob/master/Assets/ParticleCollisionHelper.cs
                            SubUVTextureInfo subUV = new SubUVTextureInfo(size, z);
                            pixelUV.x = (subUV.currentColumn / subUV.columns) + (pixelUV.x / subUV.columns);
                            pixelUV.y = (subUV.currentRow / subUV.rows) + ((1 - pixelUV.y) / subUV.rows);
                            pixelUV.y = 1 - pixelUV.y;

                            pixelUV.x *= tex.width;
                            pixelUV.y *= tex.height;

                            Color hitColor = tex.GetPixel((int)pixelUV.x, (int)pixelUV.y);
                            cols[idx] = hitColor;
                        }
                    }
                }
            }
            else
            {
                // assumes square texture slices
                if (fromTextures)
                {
                    size = slices[0].width;
                }

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
        }


        tex.SetPixels(cols);
        tex.Apply();
        UnityEditor.AssetDatabase.CreateAsset(tex, "Assets/Test3DTexture.asset");
        // renderer.material.SetTexture("_Volume", tex);
    }

    private struct SubUVTextureInfo
    {
        public float columns;
        public float rows;
        public float currentColumn;
        public float currentRow;
        public float currentFrame;
        public float totalFrames;

        public SubUVTextureInfo(int size, int curFrame)
        {
            columns = size;
            rows = size;
            totalFrames = columns * rows;

            currentFrame = curFrame;
            currentColumn = currentFrame % columns;
            currentRow = Mathf.Floor(currentFrame / columns);
        }
    }

    // http://iquilezles.org/www/articles/distfunctions/distfunctions.htm
    protected static class SignedDistanceFunctions
    {
        public enum SDFunctions
        {
            None,
            Sphere
        }

        public static float length(Vector3 v)
        {
            return Mathf.Sqrt(Vector3.Dot(v, v));
        }

        public static float sdSphere(Vector3 p, float s)
        {
            return length(p) - s;
        }
    }
}
