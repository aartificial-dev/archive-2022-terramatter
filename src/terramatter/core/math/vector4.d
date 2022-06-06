module terramatter.core.math.vector4;

import std.math;
import std.numeric;
import std.conv;

import terramatter.core.math.vector3;
import terramatter.core.math.vector2;

alias Vector4f = Vector4!float;
alias Vector4i = Vector4!int;
alias Vector4d = Vector4!double;

template Vector4(T: float) {
    class Vector4 {
        public T x = 0;
        public T y = 0;
        public T z = 0;
        public T w = 0;

        public float xfloat() { return x.to!float; }
        public float yfloat() { return y.to!float; }
        public float zfloat() { return z.to!float; }
        public float wfloat() { return w.to!float; }

        static alias Zero    = () => new Vector4!T(0, 0, 0, 0);
        static alias One     = () => new Vector4!T(1, 1, 1, 1);
        static alias Inf     = () => new Vector4!T(float.infinity.to!T, float.infinity.to!T, 
                                                   float.infinity.to!T, float.infinity.to!T);

        this(T xyzw) {
            x = xyzw;
            y = xyzw;
            z = xyzw;
            w = xyzw;
        }

        this(T x = 0, T y = 0, T z = 0, T w = 0) {
            this.x = x;
            this.y = y;
            this.z = z;
            this.w = w;
        }

        Vector4 opUnary(string op)() {
            switch (op) {
                case "-":
                    x = -x;
                    y = -y;
                    z = -z;
                    w = -w;
                    return this;
                break;
                case "+":
                    return this;
                break;
            }
        }

        override size_t toHash() const {
            return typeid(x).toHash() + typeid(y).toHash() + typeid(z).toHash() + typeid(w).toHash();
        }

        bool opEquals(const Vector4 other) const {
            if (other is this) return true;
            if (other is null) return false;
            return (x == other.x) && (y == other.y) && (z == other.z) && (w == other.w);
        }

        override string toString() const {
            return x.to!string ~ ", " ~ y.to!string ~ ", " ~ z.to!string ~ ", " ~ w.to!string;
        }

        Vector4 opOpAssign(string op)(Vector4 b) {
            switch (op) {
                case "-":
                    x -= b.x;
                    y -= b.y;
                    z -= b.z;
                    w -= b.w;
                    return this;
                break;
                case "+":
                    x += b.x;
                    y += b.y;
                    z += b.z;
                    w += b.w;
                    return this;
                break;
                case "*":
                    x *= b.x;
                    y *= b.y;
                    z *= b.z;
                    w *= b.w;
                    return this;
                break;
                case "/":
                    x /= b.x;
                    y /= b.y;
                    z /= b.z;
                    w /= b.w;
                    return this;
                break;
                case "%":
                    x %= b.x;
                    y %= b.y;
                    z %= b.z;
                    w %= b.w;
                    return this;
                break;
            }
        }

        Vector4 opOpAssign(string op)(T b) {
            switch (op) {
                case "-":
                    x -= b;
                    y -= b;
                    z -= b;
                    w -= b;
                    return this;
                break;
                case "+":
                    x += b;
                    y += b;
                    z += b;
                    w += b;
                    return this;
                break;
                case "*":
                    x *= b;
                    y *= b;
                    z *= b;
                    w *= b;
                    return this;
                break;
                case "/":
                    x /= b;
                    y /= b;
                    z /= b;
                    w /= b;
                    return this;
                break;
                case "%":
                    x %= b;
                    y %= b;
                    z %= b;
                    w %= b;
                    return this;
                break;
            }
        }

        public T[] asArray() {
            return [x, y, z, w];
        }

        public Vector4 abs() {
            return new Vector4(std.math.abs(x), std.math.abs(y), std.math.abs(z), std.math.abs(w));
        }

        // TODO
        // https://glmatrix.net/docs/vec3.js
        // https://github.com/godotengine/godot/blob/master/core/math/vector3.cpp

        // public T angle() {
        //     return 0;
        // }

        // public T angleTo(Vector4 to) {
        //     return 0;
        // }

        // public T angleToPoint(Vector4 to) {
        //     return 0;
        // }

        // public Vector4 bounce(Vector4 n) {
        //     return new Vector4();
        // }

        public Vector4 ceil() {
            return new Vector4(
                std.math.ceil(xfloat).to!T, 
                std.math.ceil(yfloat).to!T, 
                std.math.ceil(zfloat).to!T, 
                std.math.ceil(wfloat).to!T);
        }

        // public Vector4 clamped(float len) {
        //     len = len < 0.0f ? 0.0f : len;
        //     // return new Vector4(std.math.fmin(x));
        //     return new Vector4();
        // }

        // public Vector4 cross(Vector4 to) {
        //     return new Vector4(
        //         y * to.z - z * to.y,
        //         z * to.x - x * to.z,
        //         x * to.y - y * to.x
        //     );
        // }

        // public Vector4 cubicInterpolate(Vector4 b, Vector4 prea, Vector4 postb, float weight) {
        //     return new Vector4();
        // }

        // public Vector4 directionTo(Vector4 n) {
        //     return new Vector4();
        // }

        // public Vector4 distanceSquaredTo(Vector4 n) {
        //     return new Vector4();
        // }

        // public Vector4 distanceTo(Vector4 n) {
        //     return new Vector4();
        // }

        // public T dot(Vector4 to) {
        //     // return dotProduct([x, y], [to.x, to.y]);
        //     return 0;
        // }

        public Vector4 floor() {
            return new Vector4(
                std.math.floor(xfloat).to!T, 
                std.math.floor(yfloat).to!T, 
                std.math.floor(zfloat).to!T, 
                std.math.floor(wfloat).to!T);
        }

        // public bool isEqualApprox(Vector4 v) {
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
            return (x * x) + (y * y) + (z * z) + (w * w);
        }

        // public Vector4 linearInterpolate(Vector4 to, float weight) {
        //     return new Vector4();
        // }

        // public Vector4 moveToward(Vector4 n) {
        //     return new Vector4();
        // }

        public Vector4 normalized() {
            float len = lengthSquared;
            if (len > 0) {
                len = 1 / length;
            }
            return new Vector4(
                ((x * len).to!float).to!T, 
                ((y * len).to!float).to!T, 
                ((z * len).to!float).to!T, 
                ((w * len).to!float).to!T);
        }
        alias normalised = normalized;

        // public Vector4 project(Vector4 b) {
        //     return new Vector4();
        // }

        // public Vector4 reflect(Vector4 n) {
        //     return new Vector4();
        // }

        // public Vector4 rotated(float phi) {
        //     return new Vector4();
        // }

        public Vector4 round() {
            return new Vector4(
                std.math.round(xfloat).to!T, 
                std.math.round(yfloat).to!T, 
                std.math.round(zfloat).to!T, 
                std.math.round(wfloat).to!T);
        }

        public Vector4 sign() {
            return new Vector4(std.math.sgn(x), std.math.sgn(y), std.math.sgn(z), std.math.sgn(w));
        }

        // public Vector4 slerp(Vector4 to, float weight) {
        //     return new Vector4();
        // }

        // public Vector4 slide(Vector4 n) {
        //     return new Vector4();
        // }

        // public Vector4 snapped(Vector4 n) {
        //     return new Vector4();
        // }

        // public Vector4 tangent() {
        //     return new Vector4();
        // }
    }
}
