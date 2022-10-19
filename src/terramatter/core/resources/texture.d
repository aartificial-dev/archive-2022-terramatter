module terramatter.core.resources.texture;

import std.stdio: writefln;
import std.path;
import std.string: toStringz;
import std.conv: to;
import std.algorithm.searching: canFind;
import std.array: split, join;
import std.algorithm.comparison: max;
import std.range: dropBack;

import bindbc.opengl;
import bindbc.sdl;

import terramatter.core.math.color;
import terramatter.core.os.filesystem;

final class Texture2D {
    private uint _id;
    private uint _w;
    private uint _h;

    private bool _doUseMipmaps = false;

    private static Texture2D _defaultTexture = null;
    private static string _defaultPath = "res/textures/default.png";

    private TextureType _textureType = TextureType.texture2D;

    this(TextureType type = TextureType.texture2D) {
        _textureType = type;
        glGenTextures(1, &_id);
    }

    this(string path, TextureType type = TextureType.texture2D) {
        _textureType = type;
        glGenTextures(1, &_id);
        if (type == TextureType.cubeMap) {
            writefln("Use loadCubemap function instead of default constructor for '%s'.", path);
        }
        loadFile(path);
    }

    // TODO probably change to texture array
    /** 
     * 
     * Params:
     *   folderPath = Path to folder relative to app root folder (not bin)
     *   size = Atlas width and height
     *   clampSize = Fake border size. Used to remove seams on texture edges
     * Returns: `TextureRegion[]` of loaded textures `TextureRegion(w, h, u, v, name)`
     */
    public TextureRegion[string] loadAtlas(string folderPath, uint size, int clampSize) {
        SDL_Surface* atlas = SDL_CreateRGBSurface(0, size, size, 32, 0x000000ff, 0x0000ff00, 0x00ff0000, 0xff000000);
        TextureRegion[string] regions;

        SDL_UnlockSurface(atlas);

        int yoff = 0;
        int xoff = 0;
        int ymax = 0;
        // float margin = max(1.0f / size, 0.01f);

        float texelCorrection = 0.01f / size;

        string path = folderPath.absolutePath.buildNormalizedPath;
        string[] files = listdir(path);
        foreach (file; files) {
            if (!file.canFind(".png")) continue;
            string filepath = path ~ "\\" ~ file;
            SDL_Surface* img = loadSurface(filepath);
            SDL_UnlockSurface(img);
            // SDL_LockSurface(img);
            if (yoff + img.h + clampSize * 2 > size) {
                writefln("TEX::ERROR Atlas size for '%s' is too small. ", path); break;}
            if (xoff + img.w + clampSize * 2 > size) {
                xoff = 0; yoff += ymax + clampSize * 2; ymax = 0; } else { ymax = ymax.max(img.h); }

            float u = ((xoff.to!float + clampSize) / size.to!float) + texelCorrection;
            float v = ((yoff.to!float + clampSize) / size.to!float) + texelCorrection;
            float uvw = (img.w.to!float / size.to!float) - texelCorrection;
            float uvh = (img.h.to!float / size.to!float) - texelCorrection;
            
            string texname = file.split(".").dropBack(1).join(".");
            regions[texname] = TextureRegion( img.w, img.h, u, v, uvw, uvh, texname );
            
            // SDL_Rect irct;
            // irct.x = 0;
            // irct.y = 0;
            // irct.w = img.w;
            // irct.h = img.h;
            // SDL_Rect rect; // pos of img paste 
            // rect.x = xoff;
            // rect.y = yoff; // size - img.h - yoff; // flipped Y (do not, its opengl)
            // rect.w = img.w;
            // rect.h = img.h;
            // SDL_BlitSurface(img, &irct, atlas, &rect);
            if (clampSize > 0) {
                blitSurfaceScaled(img, Rect(0, 0, 1, img.h), atlas, 
                    Rect(xoff, yoff + clampSize, clampSize, img.h)); // copy left edge

                blitSurfaceScaled(img, Rect(img.w - 1, 0, 1, img.h), atlas, 
                    Rect(xoff + img.w + clampSize, yoff + clampSize, clampSize, img.h)); // right edge

                blitSurfaceScaled(img, Rect(0, 0, img.w, 1), atlas, 
                    Rect(xoff + clampSize, yoff, img.w, clampSize)); // top edge

                blitSurfaceScaled(img, Rect(0, img.h - 1, img.w, 1), atlas, 
                    Rect(xoff + clampSize, yoff + img.h + clampSize, img.w, clampSize)); // bottom edge

                
                blitSurfaceScaled(img, Rect(0, 0, 1, 1), atlas, 
                    Rect(xoff, yoff, clampSize, clampSize)); // copy top left corner

                blitSurfaceScaled(img, Rect(img.w - 1, 0, 1, 1), atlas, 
                    Rect(xoff + img.w + clampSize, yoff, clampSize, clampSize)); // copy top right corner

                blitSurfaceScaled(img, Rect(0, img.h - 1, 1, 1), atlas, 
                    Rect(xoff, yoff + img.h + clampSize, clampSize, clampSize));  // copy bottom left corner

                blitSurfaceScaled(img, Rect(img.w - 1, img.h - 1, 1, 1), atlas, 
                    Rect(xoff + img.w + clampSize, yoff + img.h + clampSize, clampSize, clampSize));  // copy bottom right corner
            }

            blitSurface(img, Rect(0, 0, img.w, img.h), atlas, Rect(xoff + clampSize, yoff + clampSize, img.w, img.h));

            xoff += img.w + clampSize * 2;
            SDL_FreeSurface(img);
        }

        setBitmap(_doUseMipmaps, GL_RGBA, size, size, GL_RGBA, GL_UNSIGNED_BYTE, atlas.pixels);
        _w = size;
        _h = size;
        // SDL_SaveBMP(atlas, (path ~ "\\atlas.bmp").toStringz);
        SDL_FreeSurface(atlas); 
        checkErrors();

        return regions;
    }

    /** 
     * Copies SDL surface into another SDL surface
     * Params:
     *   s_from = SDL surface to copy from
     *   r_from = Rectangle to copy
     *   s_to = SDL surface to copy into
     *   r_to = Rectangle to copy into
     */
    private void blitSurface(SDL_Surface* s_from, Rect r_from, SDL_Surface* s_to, Rect r_to) {
        SDL_Rect frect;
        frect.x = r_from.x;
        frect.y = r_from.y;
        frect.w = r_from.w;
        frect.h = r_from.h;
        SDL_Rect trect; // pos of img paste 
        trect.x = r_to.x;
        trect.y = r_to.y; // size - img.h - yoff; // flipped Y (do not, its opengl)
        trect.w = r_to.w;
        trect.h = r_to.h;
        SDL_BlitSurface(s_from, &frect, s_to, &trect);
    }

    /** 
     * Copies SDL surface into another SDL surface
     * Params:
     *   s_from = SDL surface to copy from
     *   r_from = Rectangle to copy
     *   s_to = SDL surface to copy into
     *   r_to = Rectangle to copy into
     */
    private void blitSurfaceScaled(SDL_Surface* s_from, Rect r_from, SDL_Surface* s_to, Rect r_to) {
        SDL_Rect frect;
        frect.x = r_from.x;
        frect.y = r_from.y;
        frect.w = r_from.w;
        frect.h = r_from.h;
        SDL_Rect trect; // pos of img paste 
        trect.x = r_to.x;
        trect.y = r_to.y; // size - img.h - yoff; // flipped Y (do not, its opengl)
        trect.w = r_to.w;
        trect.h = r_to.h;
        SDL_BlitScaled(s_from, &frect, s_to, &trect);
    }

    private struct Rect {
        int x, y, w, h;
        this(int _x, int _y, int _w, int _h) {
            x = _x;
            y = _y;
            w = _w;
            h = _h;
        }
    }

    // public TextureRegion[] loadAtlas(ubyte[] pixelData, uint size) {
    //     // SDL_CreateRGBSurfaceFrom
    // }

    /** 
     * Loads image from `path` into `SDL_Surface`
     * Params:
     *   path = Path to image
     * Returns: Flipped `SDL_Surface`
     */
    public SDL_Surface* loadSurface(string path) {
        path = path.absolutePath.buildNormalizedPath;
        SDL_Surface* img = IMG_Load(path.toStringz);
        if (!img) {
            assert(path != _defaultPath, "Could not load default image");
            writefln("Could not load image at '%s'.\nSDL:IMAGE:ERROR: %s", path, IMG_GetError().to!string);
            // throw new Error("Error loading image.");
            return loadSurface(_defaultPath);
        }
        flipSurface(img);
        SDL_Surface* flippedImg = SDL_ConvertSurfaceFormat(img, SDL_PIXELFORMAT_RGBA32, 0);
        SDL_LockSurface(flippedImg);

        SDL_FreeSurface(img); 

        return flippedImg;
    }

    /** 
     * 
     * Params:
     *   path = Path to face folder
     *   faces = Array of filenames in order: `right, left, top, bottom, front, back`
     */
    public void loadCubemap(string path, string[] faces) {
        bind();

        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
        glPixelStorei(GL_UNPACK_SKIP_PIXELS, 0);
        glPixelStorei(GL_UNPACK_SKIP_ROWS, 0);
        
        path = path.absolutePath.buildNormalizedPath;

        for (uint i = 0; i < faces.length; i ++) {
            string p = path ~ "\\" ~ faces[i];
            SDL_Surface* surf = loadSurface(p);
            glTexImage2D(
                GL_TEXTURE_CUBE_MAP_POSITIVE_X + i, 
                0, 
                GL_RGBA.to!int, 
                surf.w, 
                surf.h, 
                0, // legacy
                GL_RGBA, 
                GL_UNSIGNED_BYTE,
                surf.pixels);
            
            SDL_FreeSurface(surf);
        }

        setWrap(GL_REPEAT, GL_REPEAT);
        setFilter(GL_NEAREST, GL_NEAREST);

        unbind();
    }

    /** 
     * Loads png surface into current texture
     * Params:
     *   path = Path to image
     */
    public void loadFile(string path) {
        SDL_Surface* img = loadSurface(path);

        setBitmap(_doUseMipmaps, GL_RGBA, img.w, img.h, GL_RGBA, GL_UNSIGNED_BYTE, img.pixels);

        _w = img.w;
        _h = img.h;

        SDL_FreeSurface(img); 
    }

    /** 
     * Sets pixeldata for current texture
     * Params:
     *   genMipmaps = Do generate mipmaps
     *   numComponents = Components (rgba) stored (internal), use `GL_RGBA`
     *   width = Width of texture
     *   height = Height of texture
     *   rgbFormat = Components (rgba) stored, use `GL_RGBA`
     *   dataType = Data array format type
     *   data = Pixel data to bind
     */
    public void setBitmap(bool genMipmaps, uint numComponents, uint width, uint height, 
                   int rgbFormat, GLenum dataType, GLvoid* data) {
        bind();

        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
        glPixelStorei(GL_UNPACK_SKIP_PIXELS, 0);
        glPixelStorei(GL_UNPACK_SKIP_ROWS, 0);

        glTexImage2D(
            glType(_textureType),
            0, //mipmapLevel,
            numComponents,
            width,
            height,
            0, // legacy
            rgbFormat,
            dataType,
            data
        );

        setWrap(GL_REPEAT, GL_REPEAT);

        if (genMipmaps) {
            setFilter(GL_NEAREST_MIPMAP_LINEAR, GL_NEAREST); // FIXME mipmaps
            glGenerateMipmap(glType(_textureType));
            glTexParameterf(glType(_textureType), GL_TEXTURE_LOD_BIAS, -1);
        } else {
            setFilter(GL_NEAREST, GL_NEAREST);
        }

        
        unbind();
    }

    /** 
     * 
     * Params:
     *   xWrap = Wrapping on X axis
     *   yWrap = Wrapping on Y axis
     *   zWrap = Wrapping on Z axis
     */
    public void setWrap(GLenum xWrap, GLenum yWrap, GLenum zWrap = GL_REPEAT) {
        // s, t, r == x, y, z
        bind();
        glTexParameteri(glType(_textureType), GL_TEXTURE_WRAP_S, xWrap);
        glTexParameteri(glType(_textureType), GL_TEXTURE_WRAP_T, yWrap);
        glTexParameteri(glType(_textureType), GL_TEXTURE_WRAP_R, zWrap);
        unbind();
    }

    /** 
     * 
     * Params:
     *   minFilter = Minifying filter
     *   magFilter = Magnifying filter
     */
    public void setFilter(GLenum minFilter, GLenum magFilter) {
        bind();
        glTexParameteri(glType(_textureType), GL_TEXTURE_MIN_FILTER, minFilter);
        glTexParameteri(glType(_textureType), GL_TEXTURE_MAG_FILTER, magFilter);
        unbind();
    }

    /** 
     * Sets border color with border wrapping
     * Params:
     *   col = Color to set border
     */
    public void setBorderColor(Color col) {
        bind();
        glTexParameterfv(glType(_textureType), GL_TEXTURE_BORDER_COLOR, col.arrayof.ptr);
        unbind();  
    }

    /** 
     * Binds current texture to GL_TEXTURE0
     */
    public void bind() {
        bindTo(GL_TEXTURE0);
    }

    /** 
     * Binds current texture to `textureidx`
     * Params:
     *   textureidx = Texture index to bind to
     */
    public void bindTo(GLenum textureidx) {
        glActiveTexture(textureidx);
        glBindTexture(glType(_textureType), _id);
    }

    /** 
     * Binds current texture to 0
     */
    public void unbind() {
        glBindTexture(glType(_textureType), 0);
    }


    /** 
     * Binds current texture to 0
     * Params:
     *   type = Type of texture to unbind
     */
    public static void unbindType(TextureType type) {
        glBindTexture(glType(type), 0);
    }

    /** 
     * Deletes this texture from memory 
     */
    public void dispose() {
        glDeleteTextures(0, &_id);
    }

    /** 
     * 
     * Returns: texture at default path
     */
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

    public uint width() { return _w; }
    public uint height() { return _h; }

    /** 
     * Flips SDL surface
     * Params:
     *   surface = Surface to flip
     */
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
    
    /** 
     * Copies array
     * Params:
     *   destination = Pointer to destination array where the content is to be copied
     *   source = Pointer to the source of data to be copied
     *   num = Number of bytes to copy
     * Returns: `destination`
     */
    void * dmemcpy ( void * destination, const void * source, size_t num ) pure nothrow {
        (cast(ubyte*)destination)[0 .. num][]=(cast(const(ubyte)*)source)[0 .. num];
        return destination;
    }

    /** 
     * Checks for any SDL errors and logs them if they occur
     */
    void checkErrors() {
        const char *error = SDL_GetError();
        if (*error) {
            SDL_Log("SDL::ERROR %s", error);
            SDL_ClearError();
        }
    }

    /** 
     * Wrapping between engine and opengl
     * Params:
     *   type = Texture type
     * Returns: OpenGL TextureType enum
     */
    private static GLenum glType(TextureType type) {
        switch (type) {
            case TextureType.texture2D:
                return GL_TEXTURE_2D;
            case TextureType.cubeMap:
                return GL_TEXTURE_CUBE_MAP;
            default: 
                return GL_TEXTURE_2D;
        }
    }

    public enum TextureType {
        texture2D, cubeMap
    }
}

struct TextureRegion {
    int w;
    int h;
    float u;
    float v;
    float uvw;
    float uvh;
    string name;
    static TextureRegion defaultRegion = TextureRegion(0, 0, 0, 0, 0, 0, "");
}