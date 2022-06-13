module terramatter.core.components.camera;

import dlib.math.matrix;
import dlib.math.vector;
import dlib.math.transformation;
import dlib.math.quaternion;
import dlib.math.utils;

import terramatter.core.components.gameobject;
import terramatter.core.math.transform;
import terramatter.game.game;
import terramatter.core.io.input;
import terramatter.core.math.dlibwrapper;

import std.math;
import std.algorithm.comparison;

// LINK https://gecko0307.github.io/dlib/docs/dlib/math/vector.html
class Camera: GameObject {

    public Vector3f _rotation = Vector3f(0.0f);
    private Vector3f _up = Vector3f(0.0f, 0.1f, 0.0f);

    protected final override void _create() {
        transform.position = Vector3f(0.0f, 32.0f, 2.0f);
        transform.rotation = Quaternionf().identity;
        // turn(180);
        _rotation = Vector3f(0.0f, 0.0f, 0.0f);
        transform.updateTransformation();
    }

    protected final override void _destroy() {}

    protected final override void _update(float delta) {
        float rotY = _rotation.y.degtorad; 
        
        float speed = Input.isKeyPressed(Input.KeyCode.keyLeftShift) ? 10.0f : 7.0f;

        Matrix4f rotMat = rotationMatrix(Axis.y, -rotY);
        if (Input.isKeyPressed(Input.KeyCode.keyD)) {
            translate(Vector3f(delta, 0.0f, 0.0f) * rotMat * speed);
        }
        if (Input.isKeyPressed(Input.KeyCode.keyA)) {
            translate(Vector3f(-delta, 0.0f, 0.0f) * rotMat * speed);
        }
        if (Input.isKeyPressed(Input.KeyCode.keyW)) {
            translate(Vector3f(0.0f, 0.0f, -delta) * rotMat * speed);
        }
        if (Input.isKeyPressed(Input.KeyCode.keyS)) {
            translate(Vector3f(0.0f, 0.0f, delta) * rotMat * speed);
        }
        if (Input.isKeyPressed(Input.KeyCode.keySpace)) {
            translate(Vector3f(0.0f, delta, 0.0f) * speed);
        }
        if (Input.isKeyPressed(Input.KeyCode.keyLeftControl)) {
            translate(Vector3f(0.0f, -delta, 0.0f) * speed);
        }

        float _yrot = -Input.getMouseRelative.y * delta * 4.0f;
        float _xrot = -Input.getMouseRelative.x * delta * 4.0f;
        // if (_rotation.x + _yrot > -80.0f && _rotation.x + _yrot < 80.0f) {
        //     _rotation.x += _yrot;
        // }
        _rotation.y += _xrot;
        while (_rotation.y > 360) _rotation.y -= 360;
        while (_rotation.y < 0) _rotation.y += 360;
        // transform.setRotation(_rotation);
        _rotation.x += _yrot;
        _rotation.x = _rotation.x.clamp(-80, 80);
        transform.rotation = Quaternionf().identity * 
                             Quaternionf.fromEulerAngles(Vector3f(_rotation.x.degtorad, _rotation.y.degtorad, 0.0f));
        // if (_rotation.x > PI_2 + 0.05f || _rotation.x < -PI_2 - 0.05f) {
            // pitch(_yrot);
        // }
        // turn(_xrot);
    }

    protected final override void _tick(float delta) {}

    protected final override void _input(InputEvent e) {}

    protected final override void _render() {}
    
    public final void setActive() {
        game.setCamera(this);
    }

    public Matrix4f viewMatrix() {
        transform.updateTransformation();
        Vector3f from = transform.position;
        Vector3f to = transform.position - transform.direction;
        return lookAtMatrix(from, to, _up);
    }
}