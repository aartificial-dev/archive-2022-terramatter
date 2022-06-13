module terramatter.core.components.skybox;

import terramatter.core.resources.shader;
import terramatter.core.resources.texture;

import terramatter.render.glwrapper;
import bindbc.opengl;

class Skybox {

    private VBO _vbo;
    private VAO _vao;

    private Shader _shader;

    private Texture2D _texture;

    public Shader shader() { return _shader; }

    this() {
        _vao = new VAO();
        _vbo = new VBO(vertices.ptr, csizeof!float(vertices));
        _vao.bindBuffer(_vbo);
        _vao.linkAttribute(_vbo, 0, 3, GL_FLOAT, 3, vptr(0));

        _shader = new Shader("res/shaders/skybox.vs", "res/shaders/skybox.fs");
        _texture = new Texture2D(Texture2D.TextureType.cubeMap);
        _texture.loadCubemap("res/textures/skybox/ocean/", 
                            ["right.png", "left.png", "top.png", "bottom.png", "front.png", "back.png"]);
    }

    public void render() {
        _vao.bind();
        _texture.bind();

        glDrawArrays(GL_TRIANGLES, 0, 36);

        _vao.unbind();
        _texture.unbind();
    }

    private float[] vertices = [
    // positions          
    -1.0f,  1.0f, -1.0f,
    -1.0f, -1.0f, -1.0f,
     1.0f, -1.0f, -1.0f,
     1.0f, -1.0f, -1.0f,
     1.0f,  1.0f, -1.0f,
    -1.0f,  1.0f, -1.0f,

    -1.0f, -1.0f,  1.0f,
    -1.0f, -1.0f, -1.0f,
    -1.0f,  1.0f, -1.0f,
    -1.0f,  1.0f, -1.0f,
    -1.0f,  1.0f,  1.0f,
    -1.0f, -1.0f,  1.0f,

     1.0f, -1.0f, -1.0f,
     1.0f, -1.0f,  1.0f,
     1.0f,  1.0f,  1.0f,
     1.0f,  1.0f,  1.0f,
     1.0f,  1.0f, -1.0f,
     1.0f, -1.0f, -1.0f,

    -1.0f, -1.0f,  1.0f,
    -1.0f,  1.0f,  1.0f,
     1.0f,  1.0f,  1.0f,
     1.0f,  1.0f,  1.0f,
     1.0f, -1.0f,  1.0f,
    -1.0f, -1.0f,  1.0f,

    -1.0f,  1.0f, -1.0f,
     1.0f,  1.0f, -1.0f,
     1.0f,  1.0f,  1.0f,
     1.0f,  1.0f,  1.0f,
    -1.0f,  1.0f,  1.0f,
    -1.0f,  1.0f, -1.0f,

    -1.0f, -1.0f, -1.0f,
    -1.0f, -1.0f,  1.0f,
     1.0f, -1.0f, -1.0f,
     1.0f, -1.0f, -1.0f,
    -1.0f, -1.0f,  1.0f,
     1.0f, -1.0f,  1.0f
    ];

}