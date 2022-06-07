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
import terramatter.core.math.vector;
import terramatter.core.math.matrix;
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
        
        glDisable(GL_CULL_FACE);

        mesh.render();

        sh.set();
        vaTriangle.renderTexture2D(GL_TRIANGLES, 3, quadTex);
        sh.reset();

        _textRenderer.renderText("fps: " ~ _engine.fpsString, 10.0f, 10.0f, _font);
        _textRenderer.renderText("The Triangle", 135.0f, 470.0f + sin(time / 20.0f) * 5.0f, _font1);
        
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