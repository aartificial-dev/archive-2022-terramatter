module terramatter.render.renderengine;

import std.conv;
import std.string: toStringz;
import std.stdio: write, writef, writefln, writeln;
import std.math;

import bindbc.opengl;
import bindbc.sdl;

import dlib.math.vector;
import dlib.math.matrix;
import dlib.math.transformation;
import dlib.math.utils;

import terramatter.core.components.gameobject;
import terramatter.core.components.camera;
import terramatter.core.components.skybox;
import terramatter.core.components.chunk;
import terramatter.core.components.world;
import terramatter.core.components.block;
import terramatter.core.components.blocks.air;
import terramatter.core.components.blocks.grass;
import terramatter.core.components.blocks.stone;
import terramatter.core.components.blocks.dirt;
import terramatter.core.resources.shader;
import terramatter.core.resources.font;
import terramatter.core.resources.texture;
import terramatter.core.resources.mesh;
import terramatter.core.resources.textureatlas;
import terramatter.core.engine;
import terramatter.core.math.color;
import terramatter.core.io.input;
import terramatter.core.io.string;

import terramatter.render.window;
import terramatter.render.glwrapper;
import terramatter.render.textrenderer;

final class RenderEngine {
    // private SDL_Renderer* _renderer;
    private Engine _engine;

    private TextRenderer _textRenderer;

    private Font _font;
    private Font _font1;

    Shader sh;

    float time = 0;

    Mesh mesh;
    Mesh plane;

    public World world;

    VertexArray vaTriangle;
    VertexArray vaBlock;
    Texture2D testTex;
    // VertexArray vaInvTriangle;
    // VertexArray vaQuad;
    Texture2D quadTex;
    int bindlen = 0;

    Skybox skybox;

    Matrix4f projMatrix;
    Matrix4f mTransform;

    Shader.DrawMode drawMode = Shader.DrawMode.normal;

    private bool _doDrawWireframe = false;
    private float _visibleChunks = 8;
    private float _renderDistance = 16 * 8;
    
    this() {
        Input.setRelativeMouseMode(true);
        initRender();
        ////////////////////////////////

        TextureAtlas.generateAtlas("res/textures/blocks", "blocks", 2048, 2);
        
        world = new World(ivec3(4, 4, 4), 
            delegate Block(ivec3 c, ivec3 p) {
                int offset = (sin((c.x * 16.0 + p.x) / 8.0f) * 4.0f).to!int + 
                             (cos((c.z * 16.0 + p.z) / 8.0f) * 4.0f).to!int;
                if (c.y * 16 + p.y + offset > 28) return new Air();
                if (c.y * 16 + p.y + offset == 28) return new Grass();
                if (c.y * 16 + p.y + offset >= 20) return new Dirt();
                // if (c.y * 16 + p.y >= 0) 
                return new Stone();
            });


        Texture2D texx = new Texture2D("res/textures/default.png");

        mesh = new Mesh();
        mesh.generateQuad();
        mesh.setTexture(texx);

        sh = new Shader("res/shaders/model.vs", "res/shaders/model.fs");

        float[] trv1 = [
           -0.5f, -0.5f, 0.0f,   1.0f, 0.0f, 1.0f,   0.0f, 0.0f,
            0.0f,  0.5f, 0.0f,   1.0f, 1.0f, 0.0f,   0.5f, 1.0f,
            0.5f, -0.5f, 0.0f,   1.0f, 1.0f, 1.0f,   1.0f, 0.0f
            ];
        
        uint[] tri1 = [0, 1, 2];

        vaTriangle = new VertexArray(
            trv1.ptr, csizeof!float(trv1), 
            tri1.ptr, csizeof!uint(tri1)
            );

        vaTriangle.linkTex2Ddefault();

        
        quadTex = new Texture2D("res/textures/thing.png");
        quadTex.setFilter(GL_NEAREST, GL_NEAREST);


        // testTex = new Texture2D("res/textures/prototype/texture_08.png");
        testTex = new Texture2D("res/textures/uniform.png");
        plane = new Mesh();
        plane.generatePlane( Vector2f(100.0f, 100.0f), Vector2f(9.0f, 9.0f), sh, testTex);

        mTransform = Matrix4f.identity();

        projMatrix = perspectiveMatrix(85, Window.aspectRatio, 0.1f, _renderDistance);
        // projMatrix.setOrtho(0.0f, Window.getWidth, 0.0f, Window.getHeight, 1.0, -1.0);
        
        _font = new Font("res/fonts/Consolas.ttf", 24);
        _font1 = new Font("res/fonts/sector_034.ttf", 36);
        _textRenderer = new TextRenderer();

        skybox = new Skybox();
    }

    public void dispose() {
        // vaInvTriangle.dispose();
        // vaTriangle.dispose();
        // vaQuad.dispose();
    }

    public static const (char*) getOpenGLVersion()	{
		return glGetString(GL_VERSION);
	}

    public void switchDrawMode() {
        if (drawMode == Shader.DrawMode.normal) {
            drawMode = Shader.DrawMode.black;
        } else
        if (drawMode == Shader.DrawMode.black) {
            drawMode = Shader.DrawMode.depth;
        } else
        if (drawMode == Shader.DrawMode.depth) {
            drawMode = Shader.DrawMode.normalMap;
        } else
        if (drawMode == Shader.DrawMode.normalMap) {
            drawMode = Shader.DrawMode.normal;
        }
    }

    public void toggleRenderDistance() {
        _visibleChunks++;
        if (_visibleChunks > 16) _visibleChunks = 4;
        changeRenderDistance(_visibleChunks);
    }

    public void changeRenderDistance(float visibleChunks) {
        _visibleChunks = visibleChunks;
         _renderDistance = 16 * _visibleChunks;
        projMatrix = perspectiveMatrix(85, Window.aspectRatio, 0.1f, _renderDistance);
    }

    public void renderWorld(GameObject p_root) {
        sh.setDrawMode(drawMode);

        sh.setMat4("m_transform", translationMatrix(vec3(0.0f, -1.0f, 0.0f)));
        plane.render();
        // sh.setMat4("m_transform", translationMatrix(vec3(0.0f, 0.0f, 0.0f)));
        // vaTriangle.renderTexture2D(GL_TRIANGLES, 3, quadTex);

        // sh.setMat4("m_transform", translationMatrix(vec3(0.0f, 0.0f, -1.0f)));
        // mesh.render();

        // sh.setMat4("m_transform", translationMatrix(vec3(0.0f, 0.0f, 0.0f)));
        // blockTex[0].bindTo(GL_TEXTURE0);
        // blockTex[1].bindTo(GL_TEXTURE1);
        // blockTex[2].bindTo(GL_TEXTURE2);
        world.render(sh);
        // blockTex[0].unbindAll();
    }

    public void renderUI() {
        if (Input.isKeyPressed(Input.KeyCode.keyR)) {
            _textRenderer.renderText("The Triangle", 135.0f, 470.0f + sin(time / 20.0f) * 5.0f, _font1);
        }

        // TODO change to debug info
        if (true) {
            float yof = 0;
            _textRenderer.renderText("fps:   " ~ _engine.fpsString, 10.0f, 10.0f + 25.0f * yof++, _font);
            _textRenderer.renderText("mouse: " ~ Input.getMousePosition.toString, 10.0f, 10.0f + 25.0f * yof++, _font);
            _textRenderer.renderText("mmove: " ~ Input.getMouseRelative.toString, 10.0f, 10.0f + 25.0f * yof++, _font);
            _textRenderer.renderText(
                "pos: " ~ _engine.game.camera.transform.position.arrayof.toStringf(2), 
                10.0f, 10.0f + 25.0f * yof++, _font);
            _textRenderer.renderText(
                "rot: " ~ _engine.game.camera._rotation.arrayof.toStringf(2), 
                10.0f, 10.0f + 25.0f * yof++, _font);
            _textRenderer.renderText("dir: " ~ lookingDirection, 10.0f, 10.0f + 25.0f * yof++, _font);
            _textRenderer.renderText("rndist: " ~ _renderDistance.to!string, 10.0f, 10.0f + 25.0f * yof++, _font);
            _textRenderer.renderText("mode: " ~ drawMode.to!string, 10.0f, 10.0f + 25.0f * yof++, _font);
            _textRenderer.renderText("wire: " ~ _doDrawWireframe.to!string, 10.0f, 10.0f + 25.0f * yof++, _font);
            // _textRenderer.renderText(_engine.game.camera.viewMatrix.toString, 10.0f, 10.0f + 25.0f * yof++, _font); yof += 4;
            // _textRenderer.renderText(projMatrix.toString, 10.0f, 10.0f + 25.0f * yof++, _font);
        }
    }

    private string lookingDirection() {
        return (_engine.game.camera.transform.rotation * vec3(0.0f, 0.0f, -1.0f)).arrayof.toStringf(1);
    }

    public void render(GameObject p_root) {

        preRender();
        sh.set(); 

        sh.setMat4("m_viewMatrix", _engine.game.camera.viewMatrix);
        sh.setMat4("m_projMatrix", projMatrix);
        // mTransform = translationMatrix(_engine.game.camera.transform.position).inverse();
        // mTransform = rotationMatrix(Axis.y, time / 100.0f);
        sh.setMat4("m_transform", mTransform);
        sh.setVec3("uClearCol", 0.1f, 0.1f, 0.1f);
        sh.setVec3("uCameraPos", _engine.game.camera.transform.position);
        sh.setFloat("uRenderDistance", _renderDistance);

        renderWorld(p_root);

        sh.reset();

        skybox.shader.set();
        // glDepthMask(false);
        glDepthFunc(GL_LEQUAL);
        
        skybox.shader.setMat4("m_viewMatrix", _engine.game.camera.viewMatrix);
        // skybox.shader.setMat4("m_viewMatrix", matrix3x3to4x4(matrix4x4to3x3(_engine.game.camera.viewMatrix)));
        skybox.shader.setMat4("m_projMatrix", projMatrix);

        skybox.render();
        glDepthFunc(GL_LESS);
        // glDepthMask(true);
        skybox.shader.reset();

        if (Input.isKeyJustPressed(Input.KeyCode.keyF1)) {
            _doDrawWireframe = !_doDrawWireframe;

            if (_doDrawWireframe) {
                glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
            } else {
                glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
            }
        }
        if (Input.isKeyJustPressed(Input.KeyCode.keyF2)) {
            switchDrawMode();
        }
        if (Input.isKeyJustPressed(Input.KeyCode.keyF3)) {
            toggleRenderDistance();
        }

        preRenderUI();
        // renderObject(p_root);

        // renderLight(p_root);

        renderUI();
        
        ++time;

        postRender();

        checkglErrors();
    }

    public void initRender() {
        Window.bindAsRenderTarget();

        if (_doDrawWireframe) {
            glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
        } else {
            glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
        }

        glDisable(GL_POLYGON_SMOOTH);
    }

    public void preRender() {

        glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
        // glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        // glEnable(GL_CULL_FACE);
        // glFrontFace(GL_CW);
        // glCullFace(GL_BACK);
        
        // glEnable(GL_MULTISAMPLE);
        glDisable(GL_MULTISAMPLE); // disabled to fix mipmaps
        
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LESS);
        glEnable(GL_DEPTH_CLAMP);
        glDepthMask(true);

        // glEnable(GL_BLEND);
        // glBlendFunc(GL_ONE, GL_ONE);
    }

    public void preRenderUI() {
        glDisable(GL_CULL_FACE);
        
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    }

    public void postRender() {
        glUseProgram(0);

        glBindVertexArray(0);
        glBindTexture(GL_TEXTURE_2D, 0);

        glDisable(GL_BLEND);
    }

    public void renderObject(GameObject obj) {
        // Window.bindAsRenderTarget();
        
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        obj.propagateRender(this);
    }

    public void renderLight(GameObject obj) {
        // Window.bindAsRenderTarget();

        glEnable(GL_BLEND);
        glBlendFunc(GL_ONE, GL_ONE);

        glDepthMask(false);
        glDepthFunc(GL_EQUAL);

        obj.propagateRender(this);
    }

    public void setEngine(Engine e) {
        _engine = e;
    }
}