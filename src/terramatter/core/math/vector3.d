module terramatter.core.math.vector3;

import std.math;
import std.numeric;
import std.conv;

import terramatter.core.math.vector2;

alias Vector3f = Vector3!float;
alias Vector3i = Vector3!int;
alias Vector3d = Vector3!double;

template Vector3(T: float) {
    class Vector3 {
        public T x = 0;
        public T y = 0;
        public T z = 0;

        public float xfloat() { return x.to!float; }
        public float yfloat() { return y.to!float; }
        public float zfloat() { return z.to!float; }

        static alias Zero    = () => new Vector3!T(0, 0, 0);
        static alias One     = () => new Vector3!T(1, 1, 1);
        static alias Inf     = () => new Vector3!T(float.infinity.to!T, float.infinity.to!T, float.infinity.to!T);
        static alias Forward = () => new Vector3!T(0, 0, -1);
        static alias Back    = () => new Vector3!T(0, 0, 1);
        static alias Left    = () => new Vector3!T(-1, 0, 0);
        static alias Right   = () => new Vector3!T(1, 0, 0);
        static alias Up      = () => new Vector3!T(0, 1, 0);
        static alias Down    = () => new Vector3!T(0, -1, 0);
        
        this(T x = 0, T y = 0, T z = 0) {
            this.x = x;
            this.y = y;
            this.z = z;
        }

        this(T xyz) {
            x = xyz;
            y = xyz;
            z = xyz;
        }

        Vector3 opUnary(string op)() {
            switch (op) {
                case "-":
                    x = -x;
                    y = -y;
                    z = -z;
                    return this;
                break;
                case "+":
                    return this;
                break;
            }
        }

        override size_t toHash() const {
            return typeid(x).toHash() + typeid(y).toHash() + typeid(z).toHash();
        }

        bool opEquals(const Vector3 other) const {
            if (other is this) return true;
            if (other is null) return false;
            return (x == other.x) && (y == other.y) && (z == other.z);
        }

        override string toString() const {
            return x.to!string ~ ", " ~ y.to!string ~ ", " ~ z.to!string;
        }

        Vector3 opOpAssign(string op)(Vector3 b) {
            switch (op) {
                case "-":
                    x -= b.x;
                    y -= b.y;
                    z -= b.z;
                    return this;
                break;
                case "+":
                    x += b.x;
                    y += b.y;
                    z += b.z;
                    return this;
                break;
                case "*":
                    x *= b.x;
                    y *= b.y;
                    z *= b.z;
                    return this;
                break;
                case "/":
                    x /= b.x;
                    y /= b.y;
                    z /= b.z;
                    return this;
                break;
                case "%":
                    x %= b.x;
                    y %= b.y;
                    z %= b.z;
                    return this;
                break;
            }
        }

        Vector3 opOpAssign(string op)(T b) {
            switch (op) {
                case "-":
                    x -= b;
                    y -= b;
                    z -= b;
                    return this;
                break;
                case "+":
                    x += b;
                    y += b;
                    z += b;
                    return this;
                break;
                case "*":
                    x *= b;
                    y *= b;
                    z *= b;
                    return this;
                break;
                case "/":
                    x /= b;
                    y /= b;
                    z /= b;
                    return this;
                break;
                case "%":
                    x %= b;
                    y %= b;
                    z %= b;
                    return this;
                break;
            }
        }

        public T[] asArray() {
            return [x, y, z];
        }

        public Vector3 abs() {
            return new Vector3(std.math.abs(x), std.math.abs(y), std.math.abs(z));
        }

        // TODO
        // https://glmatrix.net/docs/vec3.js
        // https://github.com/godotengine/godot/blob/master/core/math/vector3.cpp

        // public T angle() {
        //     return 0;
        // }

        // public T angleTo(Vector3 to) {
        //     return 0;
        // }

        // public T angleToPoint(Vector3 to) {
        //     return 0;
        // }

        // public Vector3 bounce(Vector3 n) {
        //     return new Vector3();
        // }

        public Vector3 ceil() {
            return new Vector3(
                std.math.ceil(xfloat).to!T, 
                std.math.ceil(yfloat).to!T, 
                std.math.ceil(zfloat).to!T);
        }

        public Vector3 clamped(float len) {
            len = len < 0.0f ? 0.0f : len;
            // return new Vector3(std.math.fmin(x));
            return new Vector3();
        }

        public Vector3 cross(Vector3 to) {
            return new Vector3(
                y * to.z - z * to.y,
                z * to.x - x * to.z,
                x * to.y - y * to.x
            );
        }

        // public Vector3 cubicInterpolate(Vector3 b, Vector3 prea, Vector3 postb, float weight) {
        //     return new Vector3();
        // }

        // public Vector3 directionTo(Vector3 n) {
        //     return new Vector3();
        // }

        // public Vector3 distanceSquaredTo(Vector3 n) {
        //     return new Vector3();
        // }

        // public Vector3 distanceTo(Vector3 n) {
        //     return new Vector3();
        // }

        // public T dot(Vector3 to) {
        //     // return dotProduct([x, y], [to.x, to.y]);
        //     return 0;
        // }

        public Vector3 floor() {
            return new Vector3(
                std.math.floor(xfloat).to!T, 
                std.math.floor(yfloat).to!T, 
                std.math.floor(zfloat).to!T);
        }

        // public bool isEqualApprox(Vector3 v) {
        //     return false;
        // }

        public bool isNormalized() {
            return length == 1;
        }
        alias isNormalised = isNormalized;

        public T length() {
            return sqrt(lengthSquared.to!float).to!T;
        }

        public T lengthSquared() {
            return (x * x) + (y * y) + (z * z);
        }

        // public Vector3 linearInterpolate(Vector3 to, float weight) {
        //     return new Vector3();
        // }

        // public Vector3 moveToward(Vector3 n) {
        //     return new Vector3();
        // }

        public Vector3 normalized() {
            float len = lengthSquared;
            if (len > 0) {
                len = 1 / length;
            }
            return new Vector3(
                ((x * len).to!float).to!T, 
                ((y * len).to!float).to!T, 
                ((z * len).to!float).to!T);
        }
        alias normalised = normalized;

        // public Vector3 project(Vector3 b) {
        //     return new Vector3();
        // }

        // public Vector3 reflect(Vector3 n) {
        //     return new Vector3();
        // }

        // public Vector3 rotated(float phi) {
        //     return new Vector3();
        // }

        public Vector3 round() {
            return new Vector3(
                std.math.round(xfloat).to!T, 
                std.math.round(yfloat).to!T, 
                std.math.round(zfloat).to!T);
        }

        public Vector3 sign() {
            return new Vector3(std.math.sgn(x), std.math.sgn(y), std.math.sgn(z));
        }

        // public Vector3 slerp(Vector3 to, float weight) {
        //     return new Vector3();
        // }

        // public Vector3 slide(Vector3 n) {
        //     return new Vector3();
        // }

        // public Vector3 snapped(Vector3 n) {
        //     return new Vector3();
        // }

        // public Vector3 tangent() {
        //     return new Vector3();
        // }
    }
}
