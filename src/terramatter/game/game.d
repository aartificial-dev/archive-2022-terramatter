module terramatter.game.game;

import terramatter.core.engine;
import terramatter.core.components.gameobject;
import terramatter.core.io.inputevent;

import terramatter.render.renderengine;

class Game {
    private GameObject _root;

    // aka init
    public void start() {
        getRootObject().propagateCreate();
    }

    public void input(InputEvent e) {
        getRootObject().propagateInput(e);
    }

    public void update(float delta) {
        getRootObject().propagateUpdate(delta);
    }

    public void render(RenderEngine re) {
        re.render(getRootObject());
    }

    public void addObject(GameObject object) {
        getRootObject().addChild(object);
    }

    private GameObject getRootObject() {
        if (_root is null) {
            _root = new GameObject();
        }
        return _root;
    }

    public void setEngine(Engine e) { 
        getRootObject().setEngine(e); 
    }

    public void dispose() {
        
    }
}