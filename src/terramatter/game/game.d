module terramatter.game.game;

import terramatter.core.engine;
import terramatter.core.components.gameobject;
import terramatter.core.io.input;
import terramatter.core.components.camera;

import terramatter.render.renderengine;

class Game {
    private GameObject _root;
    private Camera _currentCamera;

    // aka init
    public void start() {
        Camera cam = new Camera();
        addObject(cam);
        cam.setActive();
        rootObject.propagateCreate();
    }

    public void input(InputEvent e) {
        rootObject.propagateInput(e);
    }

    public void update(float delta) {
        rootObject.propagateUpdate(delta);
    }

    public void render(RenderEngine re) {
        re.render(rootObject);
    }

    public void addObject(GameObject object) {
        rootObject.addChild(object);
    }

    private GameObject rootObject() {
        if (_root is null) {
            _root = new GameObject();
            _root.game(this);
        }
        return _root;
    }

    public void setEngine(Engine e) { 
        rootObject.engine(e); 
    }

    public void setCamera(Camera cam) {
        _currentCamera = cam;
    }

    public Camera camera() {
        return _currentCamera;
    }

    public void dispose() {
        
    }

    // LINK https://github.com/pythoneer/3DGameEngineD/blob/master/source/
}
