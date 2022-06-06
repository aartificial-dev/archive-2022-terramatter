module terramatter.core.resources.mesh;

import std.conv;
import std.traits;

import bindbc.opengl;


import terramatter.render.glwrapper;
import terramatter.core.resources.texture;
import terramatter.core.resources.shader;
// import terramatter.core.math.vector3;


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
        //  pos                   colour
             1.0f,  1.0f, 0.0f,   1.0f, 1.0f, 1.0f,  1.0f, 1.0f, // red    t r
             1.0f, -1.0f, 0.0f,   1.0f, 1.0f, 1.0f,  1.0f, 0.0f, // green  b r
            -1.0f, -1.0f, 0.0f,   1.0f, 1.0f, 1.0f,  0.0f, 0.0f, // blue   b l
            -1.0f,  1.0f, 0.0f,   1.0f, 1.0f, 1.0f,  0.0f, 1.0f  // purple t l
            ];

        //             r  g  p  g  b  p
        uint[] indx = [0, 1, 3, 1, 2, 3];

        setVertices(vert, indx);
        setShader(Shader.defaultShader);
        setTexture(Texture2D.defaultTexture);
        return this;
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

        _sh.set();

        _va.renderTexture2D(GL_TRIANGLES, vertsize, _tex);

        _sh.reset();
    }
}