module terramatter.render.renderengine;

import std.conv;
import std.string: toStringz;
import std.stdio: write, writef, writefln, writeln;
import std.math;

import bindbc.opengl;
import bindbc.sdl;

import terramatter.core.components.gameobject;
import terramatter.core.resources.shader;
import terramatter.core.resources.font;
import terramatter.core.resources.texture;
import terramatter.core.resources.mesh;
import terramatter.core.engine;
import terramatter.core.math.vector2;
import terramatter.core.math.vector3;
import terramatter.core.math.matrix4;
import terramatter.core.math.color;

import terramatter.render.window;
import terramatter.render.glwrapper;
import terramatter.render.textrenderer;

class RenderEngine {
    // private SDL_Renderer* _renderer;
    private Engine _engine;

    private TextRenderer _textRenderer;

    private Font _font;
    private Font _font1;

    Shader sh;

    float time = 0;

    Mesh mesh;

    VertexArray vaTriangle;
    // VertexArray vaInvTriangle;
    // VertexArray vaQuad;
    Texture2D quadTex;

    private bool _doDrawWireframe = false;
    
    this() {

        // _renderer = SDL_CreateRenderer(Window.getWindow, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
        
        Window.bindAsRenderTarget();

        if (_doDrawWireframe) {
            glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
        } else {
            glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
        }

        ////////////////////////////////

        mesh = new Mesh();
        mesh.generateQuad();

        sh = Shader.defaultShader;

        float[] trv1 = [
           -0.5f, -0.5f, 0.0f,   1.0f, 0.0f, 1.0f,   0.0f, 0.0f,
            0.5f, -0.5f, 0.0f,   1.0f, 1.0f, 1.0f,   1.0f, 0.0f,
            0.0f,  0.5f, 0.0f,   1.0f, 1.0f, 0.0f,   0.5f, 1.0f
            ];
        
        uint[] tri1 = [0, 1, 2];

        vaTriangle = new VertexArray(
            trv1.ptr, csizeof!float(trv1), 
            tri1.ptr, csizeof!uint(tri1)
            );

        vaTriangle.linkTex2Ddefault();

        quadTex = new Texture2D("res/textures/thing.png");
        quadTex.setFilter(GL_NEAREST, GL_NEAREST);
        
        _font = new Font("res/fonts/Consolas.ttf", 24);
        _font1 = new Font("res/fonts/sector_034.ttf", 36);
        _textRenderer = new TextRenderer();

        // float[] trv2 = [
        //     0.5f, 0.5f, 0.0f,
        //     -0.5f, 0.5f, 0.0f,
        //     0.0f, -0.5f, 0.0f
        //     ];

        // vaInvTriangle = new VertexArray(
        //     trv2, (trv2.length * float.sizeof).to!uint, 
        //     tri1, (tri1.length * int.sizeof).to!uint
        //     );

        // float[] qav1 = [
        // //  pos                   colour
        //      1.0f,  1.0f, 0.0f,   1.0f, 0.0f, 0.0f,  1.0f, 1.0f, // red    t r
        //      1.0f, -1.0f, 0.0f,   0.0f, 1.0f, 0.0f,  1.0f, 0.0f, // green  b r
        //     -1.0f, -1.0f, 0.0f,   0.0f, 0.0f, 1.0f,  0.0f, 0.0f, // blue   b l
        //     -1.0f,  1.0f, 0.0f,   1.0f, 0.0f, 1.0f,  0.0f, 1.0f  // purple t l
        //     ];
        

            // float[] vertices = [
            // //  vpos                  texcoords
            //     xpos,     ypos + h,   0.0f, 0.0f ,            
            //     xpos,     ypos,       0.0f, 1.0f ,
            //     xpos + w, ypos,       1.0f, 1.0f ,
            //     xpos + w, ypos + h,   1.0f, 0.0f 
            // ];
        //             r  g  p  g  b  p
        // uint[] qai1 = [0, 1, 3, 1, 2, 3];

        // vaQuad = new VertexArray(
        //     qav1.ptr, csizeof!float(qav1), 
        //     qai1.ptr, csizeof!uint(qai1)
        //     );
        // vaQuad.linkAttribute(0, 3, GL_FLOAT, csizeof!float(8), csizeof!float(0).vptr);
        // vaQuad.linkAttribute(1, 3, GL_FLOAT, csizeof!float(8), csizeof!float(3).vptr);
        // vaQuad.linkAttribute(2, 2, GL_FLOAT, csizeof!float(8), csizeof!float(6).vptr);
        // vaQuad.linkTex2Ddefault();

        // TEXT
        // glEnable(GL_CULL_FACE);
        // glEnable(GL_BLEND);
        // glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);



        // glGenVertexArrays(1, &textvao);
        // glBindVertexArray(textvao);

        // glGenBuffers(1, &textvbo);
        // glBindBuffer(GL_ARRAY_BUFFER, textvbo);

        // glBufferData(GL_ARRAY_BUFFER, float.sizeof * 6 * 4, null, GL_DYNAMIC_DRAW);
        // glEnableVertexAttribArray(0);

        // glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 4 * float.sizeof, cast(GLvoid*) 0);

        // glBindBuffer(GL_ARRAY_BUFFER, 0);
        // glBindVertexArray(0);

        // glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
        
        // glFrontFace(GL_CW);
        // glCullFace(GL_BACK);

        // glEnable(GL_CULL_FACE);
        // glEnable(GL_DEPTH_TEST);
        // glEnable(GL_DEPTH_CLAMP);
        // glEnable(GL_MULTISAMPLE);
    }

    public void dispose() {
        // vaInvTriangle.dispose();
        // vaTriangle.dispose();
        // vaQuad.dispose();
    }

    public static const (char*) getOpenGLVersion()	{
		return glGetString(GL_VERSION);
	}

    public void render(GameObject obj) {
        // preRender();

        // renderObject(obj);

        // renderLight(obj);

        // postRender();

        // Window.bindAsRenderTarget();

        glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        // sh.set();

        // // vaTriangle.render(GL_TRIANGLES, 3);

        // sh.reset();
        
        glDisable(GL_CULL_FACE);


        mesh.render();

        sh.set();
        vaTriangle.renderTexture2D(GL_TRIANGLES, 3, quadTex);
        sh.reset();

        _textRenderer.renderText("fps: " ~ _engine.fpsString, 10.0f, 10.0f, _font);
        _textRenderer.renderText("The Triangle", 135.0f, 470.0f + sin(time / 20.0f) * 5.0f, _font1);
        // sh.setVec2("v_screenSize", Window.getWidth, Window.getHeight);
        // vaQuad.renderTexture2D(GL_TRIANGLES, 6, quadTex);
        

        // renderText("ABCDEFGHIJKLMNOPQRSTUVWXYZ", 25.0f, Window.getHeight() - 45.0f, 
        //             1.0f, new Vector3f(1.0f, 1.0f, 1.0f));
        // renderText("abcdefghijklmnopqrstuvwxyz", 25.0f, Window.getHeight() - 75.0f, 
        //             1.0f, new Vector3f(1.0f, 1.0f, 1.0f));
                    
        // renderText("Test", 25.0f, 60.0f, 1.0f, new Vector3f(1.0f, 1.0f, 1.0f));
        // renderText("Lorem ipsum dolor amet", 25.0f, 25.0f, 1.0f, new Vector3f(1.0f, 1.0f, 1.0f));

        // SDL_Color white = SDL_Color(255, 255, 255, 255);

        // SDL_Texture* tex = renderText(
        //     "fps: " ~ _engine.getFrames.to!string, 
        //     "res/fonts/Consolas.ttf", 
        //     white, 
        //     25,
        //     _renderer
        //     );

        // SDL_GL_BindTexture(tex, null, null);

        // vaQuad.render(GL_TRIANGLE_STRIP);
        // glVertexPointer(3, GL_FLOAT, 0, quadVertices);
        // glDrawArrays(GL_QUAD_STRIP, 0, 4);

        // SDL_GL_UnbindTexture(tex);

        ++time;

        postRender();

        // Window.bindAsRenderTarget();
    }

    public void preRender() {
    }

    public void postRender() {
        glUseProgram(0);

        glBindVertexArray(0);
        glBindTexture(GL_TEXTURE_2D, 0);

        glDepthFunc(GL_LESS);
        glDepthMask(true);
        glDisable(GL_BLEND);
    }

    public void renderObject(GameObject obj) {
        Window.bindAsRenderTarget();
        
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        // obj.propagateRender(new Shader("", ""), this);
    }

    public void renderLight(GameObject obj) {
        Window.bindAsRenderTarget();

        glEnable(GL_BLEND);
        glBlendFunc(GL_ONE, GL_ONE);
        glDepthMask(false);
        glDepthFunc(GL_EQUAL);

        // obj.propagateRender(new Shader("", ""), this);
    }

    public void setEngine(Engine e) {
        _engine = e;
    }
}