module terramatter.core.resources.texture;

import std.stdio: writefln;
import std.path;
import std.string: toStringz;
import std.conv;

import bindbc.opengl;
import bindbc.sdl;

import terramatter.core.math.color;

final class Texture2D {
    private uint _id;
    private uint _w;
    private uint _h;

    private static Texture2D _defaultTexture = null;

    this() {
        glGenTextures(1, &_id);
    }

    this(string path) {
        glGenTextures(1, &_id);
        loadFile(path);
    }

    public void loadFile(string path) {
        path = path.absolutePath.buildNormalizedPath;
        SDL_Surface* img = IMG_Load(path.toStringz);
        if (!img) {
            writefln("Could not load image at '%s'.\nSDL:IMAGE:ERROR: %s", path, IMG_GetError().to!string);
            throw new Error("Error loading image.");
        }
        SDL_LockSurface(img);
        
        flipSurface(img);
        // SDL_PixelFormat* fmt = SDL_AllocFormat(SDL_PIXELFORMAT_RGBA8888);
        SDL_Surface* newImg = SDL_ConvertSurfaceFormat(img, SDL_PIXELFORMAT_RGBA32, 0);
        SDL_LockSurface(newImg);

        // uint bpp = newImg.format.BytesPerPixel.to!uint;
        // GLenum dt = (bpp == 4) ? GL_RGBA : (bpp == 3) ? GL_RGB : (bpp == 2) ? GL_RG: GL_RED;
        setBitmap(0, GL_RGBA, newImg.w, newImg.h, GL_RGBA, GL_UNSIGNED_BYTE, newImg.pixels);

        _w = img.w;
        _h = img.h;

        SDL_UnlockSurface(img);
        SDL_UnlockSurface(newImg);

        SDL_FreeSurface(newImg); 
        SDL_FreeSurface(img); 
    }

    public void setBitmap(int mipmapLevel, uint numComponents, uint width, uint height, 
                   int rgbFormat, GLenum dataType, GLvoid* data) {
        bind();

        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
        glPixelStorei(GL_UNPACK_SKIP_PIXELS, 0);
        glPixelStorei(GL_UNPACK_SKIP_ROWS, 0);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

        glTexImage2D(
            GL_TEXTURE_2D,
            mipmapLevel,
            numComponents,
            width,
            height,
            0, // legacy
            rgbFormat,
            dataType,
            data
        );
        if (mipmapLevel != 0) {
            glGenerateMipmap(GL_TEXTURE_2D);
        }
        setWrap(GL_REPEAT, GL_REPEAT);
        setFilter(GL_LINEAR, GL_LINEAR);
        unbind();
    }

    public void setWrap(GLenum xWrap, GLenum yWrap) {
        // s, t, r == x, y, z
        bind();
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, xWrap);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, yWrap);
        unbind();
    }

    public void setFilter(GLenum minFilter, GLenum magFilter) {
        bind();
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minFilter);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magFilter);
        unbind();
    }

    public void setBorderColor(Color col) {
        bind();
        glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, col.ptr);
        unbind();  
    }

    public void bind() {
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _id);
    }

    public void unbind() {
        glBindTexture(GL_TEXTURE_2D, 0);
    }

    public void dispose() {
        glDeleteTextures(0, &_id);
    }

    public static Texture2D defaultTexture() {
        if (_defaultTexture is null) {
            _defaultTexture = new Texture2D("res/textures/default.png");
            _defaultTexture.setFilter(GL_NEAREST, GL_NEAREST);
            _defaultTexture.setWrap(GL_REPEAT, GL_REPEAT);
        }
        return _defaultTexture;
    }

    public uint id() {
        return _id;
    }

    public static void unbindAll() {
        glBindTexture(GL_TEXTURE_2D, 0);
    }

    public uint width() { return _w; }
    public uint height() { return _h; }

    private void flipSurface(SDL_Surface* surface) {
        SDL_LockSurface(surface);
        
        int pitch = surface.pitch; // row size
        void* temp = (new void[pitch]).ptr; // intermediate buffer
        void* pixels = surface.pixels;
        
        for(int i = 0; i < surface.h / 2; ++i) {
            // get pointers to the two rows to swap
            void* row1 = pixels + i * pitch;
            void* row2 = pixels + (surface.h - i - 1) * pitch;
            
            // swap rows
            dmemcpy(temp, row1, pitch);
            dmemcpy(row1, row2, pitch);
            dmemcpy(row2, temp, pitch);
        }

        SDL_UnlockSurface(surface);
    }

    void * dmemcpy ( void * destination, const void * source, size_t num ) pure nothrow {
        (cast(ubyte*)destination)[0 .. num][]=(cast(const(ubyte)*)source)[0 .. num];
        return destination;
    }
}