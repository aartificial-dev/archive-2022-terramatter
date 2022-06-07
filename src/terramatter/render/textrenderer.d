module terramatter.render.textrenderer;

import std.conv;

import bindbc.opengl;

import terramatter.core.math.color;
import terramatter.core.math.vector;
import terramatter.core.math.matrix;
import terramatter.core.resources.shader;
import terramatter.core.resources.font;
import terramatter.core.resources.texture;

import terramatter.render.glwrapper;
import terramatter.render.textrenderer;
import terramatter.render.window;

class TextRenderer {
    private Matrix4f _proj;
    private VAO _vao;
    private VBO _vbo;
    private Shader _fsh;
    private Color _cwhite;

    this() {        
        _fsh = new Shader("res/shaders/text_render_2d.vs", "res/shaders/text_render_2d.fs");

        _vao = new VAO(1);
        _vbo = new VBO(1);

        _vbo.linkData(float.sizeof * 6 * 4, null, GL_DYNAMIC_DRAW);
        _vao.linkAttribute(_vbo, 0, 4, GL_FLOAT, 4 * float.sizeof, vptr(0));

        _vao.bindBuffer(_vbo);

        _proj = new Matrix4f();
        _proj.initOrthographic(0.0f, Window.getWidth, 0.0f, Window.getHeight, 1.0, -1.0);

        _cwhite = new Color(1.0f, 1.0f, 1.0f, 1.0f);
    }

    public void renderTextExt(string text, float x, float y, float xscale, float yscale, Font font, Color col) {
        // flipping Y axis to match opengl
        y = Window.getHeight - y;
        
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

        _fsh.set();

        glActiveTexture(GL_TEXTURE0);

        _fsh.setMat4("m_projection", _proj);
        _fsh.setCol("v_color", col);

        _vao.bind();

        float maxY = 0;

        for (int i = 0; i < text.length; i ++) {
            FontCharacter ch = font.getCharacters[text[i]];
            float h = ch.size.y * yscale;
            if (h > maxY) maxY = h;
        }

        y -= maxY;

        for (int i = 0; i < text.length; i ++) {
            FontCharacter ch = font.getCharacters[text[i]];

            float xpos = x + ch.bearing.x * xscale;
            float ypos = y - (ch.size.y - ch.bearing.y) * yscale;

            float w = ch.size.x * xscale;
            float h = ch.size.y * yscale;

            float[] vertices = [
            //  vpos                  texcoords
                xpos,     ypos + h,   0.0f, 0.0f ,            
                xpos,     ypos,       0.0f, 1.0f ,
                xpos + w, ypos,       1.0f, 1.0f ,

                xpos,     ypos + h,   0.0f, 0.0f ,
                xpos + w, ypos,       1.0f, 1.0f ,
                xpos + w, ypos + h,   1.0f, 0.0f 
            ];

            // TODO outline
            _fsh.setVec2("v_texsize", w, h);

            // bind texture seems sending it as uniform?
            // glBindTexture(GL_TEXTURE_2D, ch.textureID);
            ch.texture.bind();
            _vbo.linkSubData(0, csizeof!float(vertices), vertices.ptr);

            glDrawArrays(GL_TRIANGLES, 0, 6);
            x += (ch.advance >> 6) * xscale;
        }

        _vbo.unbind();
        Texture2D.unbindAll();

        _fsh.reset();
    }

    public void renderText(string text, float x, float y, Font font) {
        renderTextExt(text, x, y, 1, 1, font, _cwhite);
    }

    // TODO
    /* Draw text
    *   ext  x y string sep w
    *   color  x y string col
    *   transformed  x y string xscale yscale angle
    *   ext_color  x y string sep w col
    *   ext_transformed  x y string sep w xscale yscale angle
    *   transformed_color  x y string xscale ycale angle col
    *   ext_transformed_color  x y string sep w xscale yscale angle col
    * 
    *   sep (The maximum width in pixels of the string before a line break.)
    *   w (The maximum width in pixels of the string before a line break.)
    */
}