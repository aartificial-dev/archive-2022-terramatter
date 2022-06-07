module terramatter.core.resources.font;

import std.string: toStringz;
import std.stdio;
import std.conv;
import std.path;

import bindbc.freetype;
import bindbc.opengl;
import bindbc.sdl;

import terramatter.core.math.vector;
import terramatter.core.resources.texture;

final class Font {
    private FT_Face _font;
    private FontCharacter[char] _characters;

    private static FT_Library _lib;

    this(string fontPath, int fontSize) {
        initLibrary();
        fontPath = fontPath.absolutePath.buildNormalizedPath;

        if (FT_New_Face(_lib, fontPath.toStringz, 0, &_font)) {
            throw new Error("Failed to load font at '" ~ fontPath ~ "'.");
        }

        FT_Set_Pixel_Sizes(_font, 0, fontSize);

        generateCharacters();

        FT_Done_Face(_font);
        FT_Done_FreeType(_lib);
    }

    private void generateCharacters() {
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

        for (char c = 0; c < 128; c++) {
            if (FT_Load_Char(_font, c, FT_LOAD_RENDER)) {
                writeln("Failed to load Glyph");
                continue;
            }

            Texture2D tex = new Texture2D();
            
            tex.setBitmap(
                0,
                GL_RED,
                _font.glyph.bitmap.width,
                _font.glyph.bitmap.rows,
                GL_RED,
                GL_UNSIGNED_BYTE,
                _font.glyph.bitmap.buffer
            );

            tex.setFilter(GL_LINEAR, GL_LINEAR);
            tex.setWrap(GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE);
            
            FontCharacter ch = {
                texture: tex,
                size: new Vector2i(_font.glyph.bitmap.width, _font.glyph.bitmap.rows),
                bearing: new Vector2i(_font.glyph.bitmap_left, _font.glyph.bitmap_top),
                advance: _font.glyph.advance.x.to!uint
            };
            _characters[c] = ch;
        }
        glBindTexture(GL_TEXTURE_2D, 0);
    }

    public void initLibrary() {
        if (FT_Init_FreeType(&_lib)) {
            throw new Error("Could not init FreeType library.");
        }
    }

    public FontCharacter[char] getCharacters() {
        return _characters;
    }
}

struct FontCharacter {
    Texture2D texture;
    Vector2i size;
    Vector2i bearing;
    uint advance;
}