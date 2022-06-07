module terramatter.core.components.gameobject;

import std.stdio: writeln, writefln;
import std.array: split, join;
import std.algorithm.mutation: remove;

import terramatter.core.engine;
import terramatter.core.math.transform;
import terramatter.core.io.input;

import terramatter.render.renderengine;
import terramatter.core.resources.shader;

// REVIEW
// NOTE maybe try ECS system?
// might go well
class GameObject {
    private string _name;
    private ulong _id;

    private GameObject _parent;
    private GameObject[] _children;
    private Transform _transform;
    private Engine _engine;

    public this() {
        _transform = new Transform();
        _engine = null;
    }

    public final void addChild(GameObject child) {
        _children ~= child;
        child.setEngine(_engine);
        child.getTransform().setParent(_transform);
    }

    public final void setParent(GameObject parent) {
        if (isRoot) {
            writeln("Cannot set parent of root object.");
            return;
        }
        _parent = parent;
    }

    public final GameObject getChild(string path) {
        string[] p = _name.split("/");
        GameObject c = null;
        foreach (child; _children) {
            if (p[0] == child.getName) {
                c = getChild(p.remove(0).join());
            }
        }
        if (c is null) {
            writefln("GameObject with path [%s] does not exist.", path);
        }
        return c;
    }

    public final GameObject getParent() {
        return _parent;
    }

    /*********************************
    * ADD TEMPLATE GET CHILD PARENT  *
    *********************************/

    public final bool isRoot() {
        return (_parent == this);
    }

    public final void propagateCreate() {
        // all necessary create here

        create();
        
        foreach(child; _children) {
            child.create();
        }
    }

    public final void propagateDestroy() {
        // all necessary cleanup here

        destroy();
        
        foreach(child; _children) {
            child.destroy();
        }
    }

    public final void propagateUpdate(float delta) {
        _transform.update();
        // all necessary update here

        update(delta);
        
        foreach(child; _children) {
            child.update(delta);
        }
    }

    public final void propagateInput(InputEvent e) {
        // all necessary input here

        input(e);

        foreach(child; _children) {
            child.input(e);
        }

    }

    public final void propagateRender(Shader shader, RenderEngine re) {
        /******************
        * RENDER HERE???  *
        ******************/

        render();

        foreach(child; _children) {
            child.propagateRender(shader, re);
        }
    }

    public final void setEngine(Engine e) {
        if (_engine != e) {
            _engine = e;
            foreach (child; _children) {
                child.setEngine(e);
            }
        } 
    }

    public final string getName() {
        return _name;
    }

    // method called right after object was created and before ready
    public void create() {}
    // method called right before object will be destroyed
    public void destroy() {}
    // main update method. will be called each frame
    public void update(float delta) {}
    // input handling method. will be called when there's unprocessed input
    public void input(InputEvent e) {}
    // public render method. should be used to do any custom graphics
    public void render() {}

    /**********************************
    * ADD GETSET FOR TRANSFORM LATER  *
    **********************************/
    
    public final Transform getTransform() {
        return _transform;
    }


}