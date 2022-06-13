module terramatter.core.resources.mesh;

import std.conv;
import std.traits;

import bindbc.opengl;

import dlib.math.vector;

import terramatter.render.glwrapper;
import terramatter.core.resources.texture;
import terramatter.core.resources.shader;
// import dlib.math.vector3;


class Mesh {
    private VertexArray _va;
    private Texture2D _tex;
    private Shader _sh;
    private uint vertsize = 0;

    this() {
        _va = null;
        _tex = null;
        _sh = null;
    }

    // public static Mesh loadFromBlockBench() {
    //     return new Mesh();
    // }

    // public static Mesh loadFromObj() {
    //     return new Mesh();
    // }

    public Mesh generateQuad() {
        
        float[] vert = [
        //  pos                  colour             uv           normal
             1.0f,  1.0f, 0.0f,  1.0f, 1.0f, 1.0f,  1.0f, 1.0f,  0.0f, 0.0f, -1.0f,
             1.0f, -1.0f, 0.0f,  1.0f, 1.0f, 1.0f,  1.0f, 0.0f,  0.0f, 0.0f, -1.0f,
            -1.0f, -1.0f, 0.0f,  1.0f, 1.0f, 1.0f,  0.0f, 0.0f,  0.0f, 0.0f, -1.0f,
            -1.0f,  1.0f, 0.0f,  1.0f, 1.0f, 1.0f,  0.0f, 1.0f,  0.0f, 0.0f, -1.0f
            ];

        //             r  g  p  g  b  p
        uint[] indx = [0, 1, 3, 1, 2, 3];

        setVertices(vert, indx);
        setShader(Shader.defaultShader);
        setTexture(Texture2D.defaultTexture);
        return this;
    }

    public Mesh generatePlane(Vector2f size, Vector2f texScale, Shader sh, Texture2D tex) {
        float[] vert = [
        //  pos                      colour             uv                       normal
            +size.x, 0.0f, +size.y,  1.0f, 1.0f, 1.0f,  texScale.x, 0.0f,        0.0f, 1.0f, 0.0f,
            -size.x, 0.0f, +size.y,  1.0f, 1.0f, 1.0f,  0.0f,       0.0f,        0.0f, 1.0f, 0.0f,
            -size.x, 0.0f, -size.y,  1.0f, 1.0f, 1.0f,  0.0f,       texScale.y,  0.0f, 1.0f, 0.0f,
            +size.x, 0.0f, -size.y,  1.0f, 1.0f, 1.0f,  texScale.x, texScale.y,  0.0f, 1.0f, 0.0f
        ];
        //             r  g  p  g  b  p
        // uint[] indx = [0, 1, 2, 2, 3, 0];
        uint[] indx = [0, 1, 3, 1, 2, 3];

        setVertices(vert, indx);
        setShader(sh);
        setTexture(tex);
        return this;
    }

    /** 
     * 
     * Params:
     *   arr = vertex array in form: \
     *   `[ TR, BR, BL, TL, ... ]`
     *   norm = Normal vector
     *   stx = EBO start index
     *   reg = struct containing uv
     *   varr = pointer to array of vertices
     *   iarr = pointer to array of indices
     */
    public static void generateFace(float[12] arr, Vector3f norm, uint stx, TextureRegion reg, ref float[] varr, ref uint[] iarr) {
        float u = reg.u;
        float v = reg.v;
        float w = reg.u + reg.uvw;
        float h = reg.v + reg.uvh;
        int i = 0;
        stx *= 4;
        float[] vert = [
        //  pos                            colour             uv    tex
            arr[i++], arr[i++], arr[i++],  1.0f, 1.0f, 1.0f,  u, h, norm.x, norm.y, norm.z,
            arr[i++], arr[i++], arr[i++],  1.0f, 1.0f, 1.0f,  u, v, norm.x, norm.y, norm.z,
            arr[i++], arr[i++], arr[i++],  1.0f, 1.0f, 1.0f,  w, v, norm.x, norm.y, norm.z,
            arr[i++], arr[i++], arr[i++],  1.0f, 1.0f, 1.0f,  w, h, norm.x, norm.y, norm.z
            ];

        //             r  g  p  g  b  p
        // uint[] indx = [stx + 0, stx + 1, stx + 3, stx + 1, stx + 2, stx + 3];
        uint[] indx = [stx + 0, stx + 2, stx + 1, stx + 2, stx + 0, stx + 3];
        
        varr ~= vert;
        iarr ~= indx;
    } 

    /** 
     * 
     * Params:
     *   reg = Array of texture regions
     *   p = Front left bottom corner of block
     *   varr = pointer to array of vertices
     *   iarr = pointer to array of indices
     *   stx = Block index (number of block in varr before)
     * `[north, south, east, west, up, down]`
     */
    public static void generateBlock(TextureRegion[] reg, Vector3f p, ref float[] varr, ref uint[] iarr, uint stx = 0) {
        stx *= 6;
        uint i = 0;
        genFaceNorth(reg[i++], p, varr, iarr, stx++);
        genFaceSouth(reg[i++], p, varr, iarr, stx++);
        genFaceEast(reg[i++], p, varr, iarr, stx++);
        genFaceWest(reg[i++], p, varr, iarr, stx++);
        genFaceUp(reg[i++], p, varr, iarr, stx++);
        genFaceDown(reg[i++], p, varr, iarr, stx++);
    }

    public static void genFaceNorth(TextureRegion reg, Vector3f p, ref float[] varr, ref uint[] iarr, uint stx = 0) {
        // north -z
        generateFace([
            p.x + 1.0f, p.y + 1.0f, p.z + 0.0f,
            p.x + 1.0f, p.y + 0.0f, p.z + 0.0f,
            p.x + 0.0f, p.y + 0.0f, p.z + 0.0f,
            p.x + 0.0f, p.y + 1.0f, p.z + 0.0f
        ], Vector3f(0.0f, 0.0f, -1.0f), stx, reg, varr, iarr);
    }

    public static void genFaceSouth(TextureRegion reg, Vector3f p, ref float[] varr, ref uint[] iarr, uint stx = 0) {
        // south +z
        generateFace([
            p.x + 0.0f, p.y + 1.0f, p.z + 1.0f,
            p.x + 0.0f, p.y + 0.0f, p.z + 1.0f,
            p.x + 1.0f, p.y + 0.0f, p.z + 1.0f,
            p.x + 1.0f, p.y + 1.0f, p.z + 1.0f
        ], Vector3f(0.0f, 0.0f, +1.0f), stx, reg, varr, iarr);
    }

    public static void genFaceEast(TextureRegion reg, Vector3f p, ref float[] varr, ref uint[] iarr, uint stx = 0) {
        // east +x
        generateFace([
            p.x + 1.0f, p.y + 1.0f, p.z + 1.0f,
            p.x + 1.0f, p.y + 0.0f, p.z + 1.0f,
            p.x + 1.0f, p.y + 0.0f, p.z + 0.0f,
            p.x + 1.0f, p.y + 1.0f, p.z + 0.0f
        ], Vector3f(+1.0f, 0.0f, 0.0f), stx, reg, varr, iarr);
    }

    public static void genFaceWest(TextureRegion reg, Vector3f p, ref float[] varr, ref uint[] iarr, uint stx = 0) {
        // west -x
        generateFace([
            p.x + 0.0f, p.y + 1.0f, p.z + 0.0f,
            p.x + 0.0f, p.y + 0.0f, p.z + 0.0f,
            p.x + 0.0f, p.y + 0.0f, p.z + 1.0f,
            p.x + 0.0f, p.y + 1.0f, p.z + 1.0f
        ], Vector3f(-1.0f, 0.0f, 0.0f), stx, reg, varr, iarr);
    }

    public static void genFaceUp(TextureRegion reg, Vector3f p, ref float[] varr, ref uint[] iarr, uint stx = 0) {
        // up +y
        generateFace([
            p.x + 1.0f, p.y + 1.0f, p.z + 1.0f,
            p.x + 1.0f, p.y + 1.0f, p.z + 0.0f,
            p.x + 0.0f, p.y + 1.0f, p.z + 0.0f,
            p.x + 0.0f, p.y + 1.0f, p.z + 1.0f
        ], Vector3f(0.0f, +1.0f, 0.0f), stx, reg, varr, iarr);
    }

    public static void genFaceDown(TextureRegion reg, Vector3f p, ref float[] varr, ref uint[] iarr, uint stx = 0) {
        // down -y
        generateFace([
            p.x + 1.0f, p.y + 0.0f, p.z + 0.0f,
            p.x + 1.0f, p.y + 0.0f, p.z + 1.0f,
            p.x + 0.0f, p.y + 0.0f, p.z + 1.0f,
            p.x + 0.0f, p.y + 0.0f, p.z + 0.0f
        ], Vector3f(0.0f, -1.0f, 0.0f), stx, reg, varr, iarr);
    }

    public Mesh setShader(Shader sh) {
        if (_sh !is null) {
            _sh.dispose();
        }
        _sh = sh;
        
        return this;
    }

    public Mesh setVertices(float[] vertices, uint[] indices) {
        if (_va !is null) {
            _va.dispose();
        }
        _va = new VertexArray(
            vertices.ptr, csizeof!float(vertices), 
            indices.ptr, csizeof!uint(indices)
            );
        vertsize = indices.length.to!uint;
        _va.linkTex2Ddefault();
        return this;
    }

    public Mesh setTexture(Texture2D tex) {
        if (_tex !is null) {
            _tex.dispose();
        }
        _tex = tex;
        
        return this;
    }

    public void render() {
        // if (_tex is null || _va is null || _sh is null) return;

        // _sh.set();

        _va.renderTexture2D(GL_TRIANGLES, vertsize, _tex);

        // _sh.reset();
    }
}