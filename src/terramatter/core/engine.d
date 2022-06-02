module terramatter.core.engine;

import std.stdio;
import std.string;
import std.conv;

import derelict.opengl3.gl;
import derelict.assimp3.assimp;

import terramatter.game.game;
import terramatter.core.os.time;
import terramatter.core.io.input;

import terramatter.render.renderengine;
import terramatter.render.window;

class Engine {

    public static int WIDTH = 800;
    public static int HEIGHT = 600;
    public static string TITLE = "terramatter";
    public static float FRAME_CAP = 5000.0f;

    private RenderEngine renderEngine;
    private bool _isRunning;
    private Game _game;
    private int _width;
    private int _height;
    private float _frameTime;

    this(int width, int height, float framerate, Game game) {
        assert(game !is null);

        _isRunning = false;
        _game = game;
        _width = width;
        _height = height;
        _frameTime = 1.0f / framerate;
        _game.setEngine(this);
    }

    public void createWindow(string title) {
        Window.createWidnow(_width, _height, title);
        this.renderEngine = new RenderEngine();
        printf("opengl version: '%s'\n", this.renderEngine.getOpenGLVersion());
    }

    public int start() {
        if (_isRunning) return -1;

        run();
        return 0;
    }

    public void stop() {
        if (!_isRunning) return;

        _isRunning = false;
    }

    private void run() {
        _isRunning = true;

        int frames = 0;
        double frameCounter = 0;

        _game.start();

        double lastTime = Time.getTime();
        double unprocessedTime = 0;

        while (_isRunning) {
            bool doNeedRender = false;

            double startTime = Time.getTime();
            double passedTime = startTime - lastTime;
            lastTime = startTime;

            unprocessedTime += passedTime;
            frameCounter += passedTime;

            /*************************************************
            *     WHY IT REFERENCES CONSTANT FRAMERATE      *
            * WHEN CLEARLY IT SHOULD GO FOR UNPROCESSEDTIME *
            *                  INSTEAD???                   *
            *************************************************/

            while (unprocessedTime > _frameTime) {
                doNeedRender = true;

                unprocessedTime -= _frameTime;

                if (Window.isCloseRequested) stop();

                _game.input(_frameTime.to!float);
                Input.update();
                _game.update(_frameTime.to!float);

				if (frameCounter >= 1.0) {				
					writefln("FPS: %d", frames);
					write("\33[1A\33[2K");
					frames = 0;
					frameCounter = 0;
				}
            }

            if (doNeedRender) {
                _game.render(renderEngine);
                Window.render();
                ++frames;
            } else {
                // TF
                Window.delay();
            }
        }

        cleanUp();
    }

    private void cleanUp() {
        Window.dispose();
    }

    public RenderEngine getRenderEngine() {
        return renderEngine;
    }
}