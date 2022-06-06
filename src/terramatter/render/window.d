module terramatter.render.window;

import std.stdio;
import std.string;
import std.conv;

import bindbc.sdl;
import bindbc.opengl;
import bindbc.freetype;

import terramatter.core.resources.font;


class Window {
    private static SDL_Window* _window;
    private static SDL_GLContext _context;

    private static bool _isRequestingClose = false;

    private static int _width;
    private static int _height;

    public static void createWidnow(int width, int height, string title) {
        Window._width = width;
        Window._height = height;

        // Loading SDL

        Window.loadLibraries();

        // version(Windows) loadSDL("libs/sdl2.dll");

        SDL_GL_SetAttribute(SDL_GLattr.SDL_GL_CONTEXT_MAJOR_VERSION, 4);
        SDL_GL_SetAttribute(SDL_GLattr.SDL_GL_CONTEXT_MINOR_VERSION, 3);

        SDL_GL_SetAttribute(SDL_GLattr.SDL_GL_MULTISAMPLEBUFFERS, 1);
        SDL_GL_SetAttribute(SDL_GLattr.SDL_GL_MULTISAMPLESAMPLES, 4);

        _window = SDL_CreateWindow(
            title.toStringz,
            SDL_WINDOWPOS_CENTERED,
            SDL_WINDOWPOS_CENTERED,
            width,
            height,
            SDL_WINDOW_SHOWN | SDL_WINDOW_OPENGL
        );

        if (_window == null) {
			writefln("Could not create window: %s\n", SDL_GetError());
			return;
        } else {
            writeln("SDL window created.");
        }

        _context = SDL_GL_CreateContext(_window);

        // Loading OpenGL
        GLSupport retVal = loadOpenGL();

        if (retVal == GLSupport.noLibrary) {
            throw new Error("Failed to load OpenGL library.");
        } else
        if (retVal == GLSupport.badLibrary) {
            throw new Error("Failed to load one of more OpenGL symbols.");
        }

        writefln("Supported OpenGL context: '%s'. \nLoaded OpenGL context: '%s'.", 
                openGLContextVersion, loadedOpenGLVersion);

        writeln("");
    }

    public static void render() {
        SDL_GL_SwapWindow(_window);
    }

    public static void delay() {
        SDL_Delay(1);
    }

    public static void dispose() {
        SDL_GL_DeleteContext(_context);
        SDL_DestroyWindow(_window);
        IMG_Quit();
        TTF_Quit();
        SDL_Quit();
    }

    public static bool isCloseRequested() {
        return _isRequestingClose;
    }

    public static void setRequestedClose(bool close) {
        this._isRequestingClose = close;
    }

    public static int getWidth() {
        return Window._width;
    }

    public static int getHeight() {
        return Window._height;
    }

    public static void bindAsRenderTarget() {
        glBindTexture(GL_TEXTURE_2D, 0);
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
        glViewport(0, 0, Window._width, Window._height);
    }

    public static void setTitle(string title) {
        SDL_SetWindowTitle(_window, title.toStringz);
    }

    public static string getTitle() {
        return to!string(SDL_GetWindowTitle(_window));
    }

    public static SDL_Window* getWindow() {
        return _window;
    }

    public static void loadLibraries() {
        SDLSupport retsdl = loadSDL("../lib/SDL2.dll");
        if (retsdl != sdlSupport) {
            if (retsdl == SDLSupport.noLibrary) {
                throw new Error("Failed to load SDL library.");
            } else
            if (retsdl == SDLSupport.badLibrary) {
                throw new Error("Failed to load one of more SDL symbols.");
            }
        }
        writeln("SDL library successfully loaded.");

        SDL_Init(SDL_INIT_EVERYTHING);

        SDLTTFSupport retttf = loadSDLTTF("../lib/SDL2_ttf.dll");
        if (retttf != sdlTTFSupport) {
            if (retttf == sdlTTFSupport.noLibrary) {
                throw new Error("Failed to load SDL TTF library.");
            } else
            if (retttf == sdlTTFSupport.badLibrary) {
                throw new Error("Failed to load one of more SDL TTF symbols.");
            }
        }
        writeln("SDL TTF library successfully loaded.");

        TTF_Init();

        SDLImageSupport imgsdl = loadSDLImage("../lib/SDL2_image");
        if (imgsdl != sdlImageSupport) {
            if (imgsdl == sdlImageSupport.noLibrary) {
                throw new Error("Failed to load SDL Image library.");
            } else
            if (imgsdl == sdlImageSupport.badLibrary) {
                throw new Error("Failed to load one of more SDL Image symbols.");
            }
        }
        writeln("SDL Image library successfully loaded.");

        IMG_Init(IMG_INIT_PNG);
        

        FTSupport retftp = loadFreeType("../lib/FreeType.dll");
        if (retftp != ftSupport) {
            if (retftp == ftSupport.noLibrary) {
                throw new Error("Failed to load FreeType library.");
            } else
            if (retftp == ftSupport.badLibrary) {
                throw new Error("Failed to load one of more FreeType symbols.");
            }
        }
        writeln("FreeType library successfully loaded.");

        writeln();
    }

}