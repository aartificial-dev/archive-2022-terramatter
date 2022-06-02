module terramatter.render.window;

import std.stdio;
import std.string;
import std.conv;

import bindbc.sdl;
import derelict.opengl3.gl;
import derelict.freeimage.freeimage;

import loader = bindbc.loader.sharedlib;

class Window {
    private static SDL_Window *_window;
    private static SDL_GLContext _context;

    private static bool isRequestingClose;

    private static int width;
    private static int height;

    this() {
        isRequestingClose = false;
    }

    public static void createWidnow(int width, int height, string title) {
        Window.width = width;
        Window.height = height;

        // Loading OpenGL
        DerelictGL3.load();

        // Loading SDL

        SDLSupport ret = loadSDL("../lib/SDL2.dll");
        if (ret != sdlSupport) {
            if (ret == SDLSupport.noLibrary) {
                throw new Error("Failed to load SDL library.");
            } else
            if (ret == SDLSupport.badLibrary) {
                throw new Error("Failed to load one of more SDL symbols");
            }
        }

        // version(Windows) loadSDL("libs/sdl2.dll");

        SDL_GL_SetAttribute(SDL_GLattr.SDL_GL_CONTEXT_MAJOR_VERSION, 3);

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
            writeln("SDL window created");
        }

        _context = SDL_GL_CreateContext(_window);

        DerelictGL3.reload();
        DerelictFI.load("../lib/FreeImage.dll");
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
        SDL_Quit();
    }

    public static bool isCloseRequested() {
        return isRequestingClose;
    }

    public static void setRequestedClose(bool close) {
        this.isRequestingClose = close;
    }

    public static int getWidth() {
        return Window.width;
    }

    public static int getHeight() {
        return Window.height;
    }

    public static void bindAsRenderTarget() {
        glBindTexture(GL_TEXTURE_2D, 0);
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
        glViewport(0, 0, Window.width, Window.height);
    }

}