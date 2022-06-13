module terramatter.core.resources.textureatlas;

import std.stdio;
import std.algorithm.searching: canFind;

import terramatter.core.resources.texture;

static class TextureAtlas {
    private static Texture2D[string] _textures;
    private static TextureRegion[string][string] _regions;

    private static const int s_defaultSize = 1024;
    private static const int s_defaultClamp = 2;

    /** 
     * Adds existing texture to atlas.
     * Params:
     *   texture = Texture to add
     *   name = Name of texture to use in functions
     */
    public static void addTexture(Texture2D texture, string name) {
        if (name == "default") {
            writeln("TEXTUREATLAS::ERROR Can't add texture with name 'default'. Please specify unique name"); return;}

        _textures[name] = texture;
    }

    public static Texture2D getTexture(string textureName) {
        if (!_textures.keys.canFind(textureName)) {
            writeln("TEXTUREATLAS::ERROR Can't find texture with name '" ~ textureName ~ "'."); 
            return defaultTexture;
        }

        return _textures[textureName];
    }

    /** 
     * Generate new atlas from contents of `filePath` folder, **without including sub-folders**.
     * Params:
     *   filePath = Path to folder that contains **`png`** textures
     *   name = Name of texture to use in functions
     *   size = Fake border size. Used to remove seams on texture edges
     */
    public static void generateAtlas(string filePath, string name, 
                                     int size = s_defaultSize, 
                                     int clampSize = s_defaultClamp) {
        if (name == "default") {
            writeln("TEXTUREATLAS::ERROR Can't add texture with name 'default'. Please specify unique name"); return;}

        _textures[name] = new Texture2D();
        _regions[name] = _textures[name].loadAtlas(filePath, size, clampSize);
    }

    public static TextureRegion getAtlasTexture(string atlasName, string textureName) {
        if (!_textures.keys.canFind(atlasName)) {
            writeln("TEXTUREATLAS::ERROR Can't find atlas with name '" ~ atlasName ~ "'."); 
            return TextureRegion.defaultRegion;
        }
        if (!_regions[atlasName].keys.canFind(textureName)) {
            writeln("TEXTUREATLAS::ERROR Can't texture in '" ~ atlasName ~"' atlas with name '" ~ textureName ~ "'."); 
            return TextureRegion.defaultRegion;
        }

        return _regions[atlasName][textureName];
    }

    public static Texture2D defaultTexture() {
        if (!_textures.keys.canFind("default")) {
            _textures["default"] = Texture2D.defaultTexture();
        }
        return _textures["default"];
    }
}
