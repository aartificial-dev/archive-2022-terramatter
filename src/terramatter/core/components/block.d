module terramatter.core.components.block;

import terramatter.core.math.transform;
import terramatter.core.resources.textureatlas;
import terramatter.core.resources.texture;

class Block {
    protected string _texFront = "empty";
    protected string _texBack = "empty";
    protected string _texLeft = "empty";
    protected string _texRight = "empty";
    protected string _texTop = "empty";
    protected string _texBottom = "empty";
    
    public final TextureRegion textureFront() {
        return TextureAtlas.getAtlasTexture("blocks", _texFront);
    }
    
    public final TextureRegion textureBack() {
        return TextureAtlas.getAtlasTexture("blocks", _texBack);
    }
    
    public final TextureRegion textureLeft() {
        return TextureAtlas.getAtlasTexture("blocks", _texLeft);
    }
    
    public final TextureRegion textureRight() {
        return TextureAtlas.getAtlasTexture("blocks", _texRight);
    }
    
    public final TextureRegion textureTop() {
        return TextureAtlas.getAtlasTexture("blocks", _texTop);
    }
    
    public final TextureRegion textureBottom() {
        return TextureAtlas.getAtlasTexture("blocks", _texBottom);
    }

    public bool isBlock(T)() {
        // throws null by some unknown reason
        if (this is null) return false;
        return typeid(T).isBaseOf(typeid(this));
       
        // return typeof(this).stringof == T.stringof;

        // return this.classinfo.name == T.classinfo.name;
    }
}