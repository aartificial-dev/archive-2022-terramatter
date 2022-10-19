module terramatter.core.components.gameobject;

import std.stdio: writeln, writefln;
import std.array: split, join;
import std.algorithm.mutation: remove;

import dlib.math.vector;
import dlib.math.quaternion;
import dlib.math.utils;

import terramatter.core.engine;
import terramatter.core.math.transform;
import terramatter.core.io.input;
import terramatter.core.resources.shader;

import terramatter.game.game;

import terramatter.render.renderengine;

// REVIEW
// NOTE maybe try ECS system?
// might go well
class GameObject {
    protected string _name;
    protected ulong _id;

    protected GameObject _parent;
    protected GameObject[] _children;
    protected Transform _transform;
    private Engine _engine;
    private Game _game;

    public this() {
        _transform = new Transform();
        _engine = null;
    }
    
    public final void addChild(GameObject child) {
        _children ~= child;
        child.engine(_engine);
        child.game(_game);
        child.transform().parent(_transform);
        child.propagateCreate();
    }

    public final void parent(GameObject p_parent) {
        if (isRoot) {
            writeln("Cannot set parent of root object.");
            return;
        }
        _parent = p_parent;
    }

    public final GameObject getChild(string path) {
        string[] p = _name.split("/");
        GameObject c = null;
        foreach (child; _children) {
            if (p[0] == child.name) {
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

    /*┌───────────────────────────────┐  
      │ ADD TEMPLATE GET CHILD PARENT │  
      └───────────────────────────────┘*/

    public final bool isRoot() {
        return (_parent == this);
    }

    public final void propagateCreate() {
        // all necessary create here
        _create();
        create();
        
        foreach(child; _children) {
            child.propagateCreate();
        }
    }

    public final void propagateDestroy() {
        // all necessary cleanup here

        _destroy();
        destroy();
        
        foreach(child; _children) {
            child.propagateDestroy();
        }
    }

    public final void propagateUpdate(float delta) {
        _transform.update();
        // all necessary update here

        _update(delta);
        update(delta);
        
        foreach(child; _children) {
            child.propagateUpdate(delta);
        }
    }

    public final void propagateInput(InputEvent e) {
        // all necessary input here

        _input(e);
        input(e);

        foreach(child; _children) {
            child.propagateInput(e);
        }

    }

    public final void propagateRender(RenderEngine re) {
        // TODO Add render here

        _render();
        render();

        foreach(child; _children) {
            child.propagateRender(re);
        }
    }

    public final void engine(Engine e) {
        if (_engine != e) {
            _engine = e;
            foreach (child; _children) {
                child.engine(e);
            }
        } 
    }

    public final Engine engine() {
        return _engine;
    }

    public final void game(Game g) {
        if (_game != g) {
            _game = g;
            foreach (child; _children) {
                child.game(g);
            }
        } 
    }

    public final Game game() {
        return _game;
    }

    public final string name() {
        return _name;
    }

    // method called right after object was created and before ready
    public void create() {}
    // method called right before object will be destroyed
    public void destroy() {}
    // main update method. will be called each frame
    public void update(float delta) {}
    // fixed update method. will be called each N ms
    public void tick(float delta) {}
    // input handling method. will be called when there's unprocessed input
    public void input(InputEvent e) {}
    // public render method. should be used to do any custom graphics
    public void render() {}
    
     // TODO tick
    // second set of functions. going to be used in parent objects
    protected void _create() {}
    protected void _destroy() {}
    protected void _update(float delta) {}
    protected void _tick(float delta) {}
    protected void _input(InputEvent e) {}
    protected void _render() {}

    /// Get object transform
    public final Transform transform() {
        return _transform;
    }

    /// Set object transform
    public final void transform(Transform tr) {
        _transform = tr;
    }

    public final void translate(vec3 offset) {
        transform.translate(offset);
    }

    public final void scale(vec3 offset) {
        transform.scale(offset);
    }

    public final void rotate(vec3 v) {
        auto r =
            rotationQuaternion!float(Axis.x, degtorad(v.x)) *
            rotationQuaternion!float(Axis.y, degtorad(v.y)) *
            rotationQuaternion!float(Axis.z, degtorad(v.z));
        transform.rotation *= r;
    }

    public final void rotate(float x, float y, float z) {
        transform.rotate(x, y, z);
    }

    /** 
     * Look up/down
     * Params:
     *   angle = angle in degrees
     */
    public final void pitch(float angle) {
        transform.pitch(angle);
    }

    /** 
     * Look left/right
     * Params:
     *   angle = angle in degrees
     */
    public final void turn(float angle) {
        transform.turn(angle);
    }

    /** 
     * Tilt left/right
     * Params:
     *   angle = angle in degrees
     */
    public final void roll(float angle) {
        transform.roll(angle);
    }


}