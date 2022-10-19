module terramatter.render.glwrapper;

import bindbc.opengl;

import std.conv;
import std.stdio;

import terramatter.core.resources.texture;

import terramatter.core.io.error;

// TODO wrap it even more

template csizeof(T) {
    uint csizeof(int var) {
        return (var * int.sizeof).to!uint;
    }
    uint csizeof(T[] var) {
        return (var.length * T.sizeof).to!uint;
    }
    uint csizeof(T[][] var) {
        return (var[0].length * var.length * T.sizeof).to!uint;
    }
    uint csizeof(T[][][] var) {
        return (var[0][0].length * var[0].length * var.length * T.sizeof).to!uint;
    }
}

void* vptr(uint i) {
    return cast(void*) i;
}

void checkglErrors() {
    GLenum err;
    while ( (err = glGetError()) != GL_NO_ERROR ) {
        switch (err) {
            case GL_INVALID_ENUM: 
                ErrLog.queueError("OPENGL::ERROR 1280 Invalid enum"); break;
            case GL_INVALID_VALUE: 
                ErrLog.queueError("OPENGL::ERROR 1281 Invalid value"); break;
            case GL_INVALID_OPERATION: 
                ErrLog.queueError("OPENGL::ERROR 1282 Invalid operation"); break;
            case GL_STACK_OVERFLOW: 
                ErrLog.queueError("OPENGL::ERROR 1283 Stack overflow"); break;
            case GL_STACK_UNDERFLOW: 
                ErrLog.queueError("OPENGL::ERROR 1284 Stack underflow"); break;
            case GL_OUT_OF_MEMORY: 
                ErrLog.queueError("OPENGL::ERROR 1285 Out of memeory"); break;
            case GL_INVALID_FRAMEBUFFER_OPERATION: 
                ErrLog.queueError("OPENGL::ERROR 1286 Invalid framebuffer operation"); break;
            default: 
                ErrLog.queueError("OPENGL::ERROR Unknown error code"); break;
        }
    }
}

final class VBO {
    private uint _id;
    private uint _len;

    this(float* vertices, uint size, uint len = 1) {
        glGenBuffers(len, &_id);
        bind();
        glBufferData(GL_ARRAY_BUFFER, size, vertices, GL_STATIC_DRAW);
        unbind();
        _len = len;
    }

    this(uint len = 1) {
        glGenBuffers(len, &_id);
        _len = len;
    }

    public uint id() {
        return _id;
    }

    public void linkData(uint size, float* data, GLenum mode = GL_STATIC_DRAW) {
        bind();
        glBufferData(GL_ARRAY_BUFFER, size, data, mode);
        unbind();
    }

    public void linkSubData(uint offset, uint size, float* data) {
        bind();
        glBufferSubData(GL_ARRAY_BUFFER, offset, size, data);
        unbind();
    }

    public void bind() {
        glBindBuffer(GL_ARRAY_BUFFER, _id);
    }

    public void unbind() {
        glBindBuffer(GL_ARRAY_BUFFER, 0);
    }

    public void dispose() {
        glDeleteBuffers(_len, &_id);
    }
}

final class VAO {
    private uint _id;
    private uint _len;

    this(uint len = 1) {
        glGenVertexArrays(len, &_id);
        _len = len;
    }

    public uint id() {
        return _id;
    }

    /** 
     * 
     * Params:
     *   vbo = VBO to link attribute of
     *   layout = Position of attribute in array. `layout (location = %layout%)` in shader
     *   numComponents = Number of elements of array to use for attribute (e.g. 3 for vec3)
     *   dataType = Type of data in array
     *   stride = How much elements will be in the end (e.g. pos + col + uv = 3 + 3 + 2)
     *   offset = How much array elements preceeds this attribute. Recommended to use `csizeof!T(len).vptr`
     */
    public void linkAttribute(VBO vbo, uint layout, int numComponents, 
                              GLenum dataType, int stride, const void* offset) {
        bind();
        vbo.bind();
        glVertexAttribPointer(layout, numComponents, dataType, GL_FALSE, stride, offset);
        glEnableVertexAttribArray(layout); 
        unbind();
        vbo.unbind();
    }

    private const int attrSize = 3 + 3 + 2 + 3;
    // For 2D textures it's always should be:
    // XYZ RGB UV
    public void linkTex2Dpos(VBO vbo) {
        linkAttribute(vbo, 0, 3, GL_FLOAT, csizeof!float(attrSize), csizeof!float(0).vptr);
    }

    public void linkTex2Dcol(VBO vbo) {
        linkAttribute(vbo, 1, 3, GL_FLOAT, csizeof!float(attrSize), csizeof!float(3).vptr);
    }

    public void linkTex2DtexPos(VBO vbo) {
        linkAttribute(vbo, 2, 2, GL_FLOAT, csizeof!float(attrSize), csizeof!float(6).vptr);
    }

    public void linkTex2Dnorm(VBO vbo) {
        linkAttribute(vbo, 3, 3, GL_FLOAT, csizeof!float(attrSize), csizeof!float(8).vptr);
    }

    // public void linkTex2DtexIdx(VBO vbo) {
    //     linkAttribute(vbo, 3, 1, GL_FLOAT, csizeof!float(9), csizeof!float(7).vptr);
    // }

    public void linkTex2Ddefault(VBO vbo) {
        linkTex2Dpos(vbo);
        linkTex2Dcol(vbo);
        linkTex2DtexPos(vbo);
        linkTex2Dnorm(vbo);
        // linkTex2DtexIdx(vbo);
    }

    public void bind() {
        glBindVertexArray(_id);
    }

    public void unbind() {
        glBindVertexArray(0);
    }

    public void dispose() {
        glDeleteVertexArrays(_len, &_id);
    }

    public void disableAttribute(uint layout) {
        glEnableVertexAttribArray(layout); 
    }

    public void bindBuffer(VBO vbo) {
        bind();
        vbo.bind();
        unbind();
        vbo.unbind();
    }

    public void bindBuffer(EBO ebo) {
        bind();
        ebo.bind();
        unbind();
        ebo.unbind();
    }

    public void bindBuffer(VBO vbo, EBO ebo) {
        bind();
        ebo.bind();
        vbo.bind();

        unbind();
        ebo.unbind();
        vbo.unbind();
    }
}

final class EBO {
    private uint _id;
    private uint _len;

    this(uint* indices, uint size, uint len = 1) {
        glGenBuffers(len, &_id);
        bind();
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, size, indices, GL_STATIC_DRAW);
        unbind();
        _len = len;
    }

    this(uint len = 1) {
        glGenBuffers(len, &_id);
        _len = len;
    }

    public uint id() {
        return _id;
    }

    public void linkData(uint size, float* data, GLenum mode = GL_STATIC_DRAW) {
        bind();
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, size, data, mode);
        unbind();
    }

    public void linkSubData(uint size, uint offset, float* data) {
        bind();
        glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, offset, size, data);
        unbind();
    }

    public void bind() {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _id);
    }

    public void unbind() {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    }

    public void dispose() {
        glDeleteBuffers(_len, &_id);
    }
}

class VertexArray {
    private VBO _vbo;
    private VAO _vao;
    private EBO _ebo;

    this(float* vertices, uint vertSize, uint* indices, uint indSize) {
        _vao = new VAO();
        _vbo = new VBO(vertices, vertSize);
        _ebo = new EBO(indices, indSize);
        _vao.bindBuffer(_vbo, _ebo);
    }

    this(float[] vertices, uint[] indices) {
        _vao = new VAO();
        _vbo = new VBO(vertices.ptr, csizeof!float(vertices));
        _ebo = new EBO(indices.ptr, csizeof!uint(indices));
        _vao.bindBuffer(_vbo, _ebo);
    }

    public void linkAttribute(uint layout, int numComponents, GLenum dataType, int stride, void* offset) {
        _vao.bind();
        _vao.linkAttribute(_vbo, layout, numComponents, dataType, stride, offset);
        _vao.unbind(); 
    }

    public void linkTex2Ddefault() {
        _vao.linkTex2Ddefault(_vbo);
    }

    public void render(GLenum type, int vertAmmount) {
        _vao.bind();

        // last 0 is used if ebo is not in use 
        glDrawElements(type, vertAmmount, GL_UNSIGNED_INT, cast(GLvoid*) 0);
        _vao.unbind();
    }

    public void renderTexture2D(GLenum type, int vertAmmount, Texture2D tex) {
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

        _vao.bind();
        tex.bind();

        // last 0 is used if ebo is not in use 
        glDrawElements(type, vertAmmount, GL_UNSIGNED_INT, cast(GLvoid*) 0);

        _vao.unbind();
        tex.unbind();
    }

    public void dispose() {
        _vbo.dispose();
        _vao.dispose();
        _ebo.dispose();
    }

    public VBO vbo() { return _vbo; }
    public VAO vao() { return _vao; }
    public EBO ebo() { return _ebo; }
}

struct VAElements {
    float[] vertices;
    uint[] indices;
}