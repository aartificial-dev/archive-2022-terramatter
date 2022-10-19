module terramatter.core.engine;

import std.stdio;
import std.string;
import std.conv;

import terramatter.game.game;
import terramatter.core.os.time;
import terramatter.core.io.input;

import terramatter.render.renderengine;
import terramatter.render.window;

import bindbc.sdl;

class Engine {

    public static int WIDTH = 800;
    public static int HEIGHT = 600;
    public static string TITLE = "terramatter";
    public static float FRAME_CAP = 5000.0f;

    private RenderEngine _renderEngine;
    private bool _isRunning;
    private Game _game;
    private int _width;
    private int _height;
    private float _frameTime;
    private int _frames;
    private int _fps;

    this(int width, int height, float framerate, Game game) {
        assert(game !is null);

        _isRunning = false;
        _game = game;
        _width = width;
        _height = height;
        _frameTime = 1.0f / framerate;
        _frames = 0;
        _fps = 60;
        _game.setEngine(this);
    }

    public void createWindow(string title) {
        Window.createWidnow(_width, _height, title);
        writeln("Succesfully loaded libraries and created SDL window.");
        printf("OpenGL version: '%s'\n\n", RenderEngine.getOpenGLVersion());
        writeln("Starting render engine");
        _renderEngine = new RenderEngine();
        _renderEngine.setEngine(this);
        Window.setTitle("TerraMatter");
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

            /* -------------------------------------------------------------------------- */
            /*                    WHY IT REFERENCES CONSTANT FRAMERATE                    */
            /*               WHEN CLEARLY IT SHOULD GO FOR UNPROCESSEDTIME                */
            /*                                 INSTEAD???                                 */
            /* -------------------------------------------------------------------------- */

            while (unprocessedTime > _frameTime) {
                doNeedRender = true;

                unprocessedTime -= _frameTime;

                if (Window.isCloseRequested) stop();

                Input.update();
                _game.input(new InputEvent());
                _game.update(_frameTime.to!float);

				if (frameCounter >= 1.0) {				
					// writefln("FPS: %d", _frames);
                    // Window.setTitle("TerraMatter | FPS: " ~ _frames.to!string);
                    // writeln(Window.getTitle());
                    _fps = _frames;
					_frames = 0;
					frameCounter = 0;
				}
            }

            if (doNeedRender) {
                _game.render(_renderEngine);
                Window.render();
                ++_frames;
            } else {
                // TF
                Window.delay();
            }
        }

        cleanUp();
    }

    private void cleanUp() {
        _game.dispose();
        _renderEngine.dispose();
        Window.dispose();
    }

    public RenderEngine renderEngine() {
        return _renderEngine;
    }

    public int fps() {
        return _fps;
    }

    public string fpsString() {
        return _fps.to!string;
    }

    public Game game() {
        return _game;
    }
}