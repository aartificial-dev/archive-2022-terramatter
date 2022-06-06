module terramatter.core.math.vector2;

import std.math;
import std.numeric;
import std.conv;
import std.traits;

import terramatter.core.math.vector3;

alias Vector2f = Vector2!float;
alias Vector2d = Vector2!double;
alias Vector2r = Vector2!real;
alias Vector2i = Vector2!int;
alias Vector2l = Vector2!long;

template Vector2(T: float) {
    class Vector2 {
        public T x = 0;
        public T y = 0;

        static alias Zero  = () => new Vector2!T(0, 0);
        static alias One   = () => new Vector2!T(1, 1);
        static alias Inf   = () => new Vector2f(float.infinity, float.infinity);
        static alias Left  = () => new Vector2!T(-1, 0);
        static alias Right = () => new Vector2!T(1, 0);
        static alias Up    = () => new Vector2!T(0, -1);
        static alias Down  = () => new Vector2!T(0, 1);

        this(T x = 0, T y = 0) {
            this.x = x;
            this.y = y;
        }

        this(T xy) {
            x = xy;
            y = xy;
        }

        /******************************
        * UNARY OPERATIONS OVERRIDES  *
        ******************************/

        Vector2 opUnary(string op)() {
            switch (op) {
                case "-":
                    x = -x;
                    y = -y;
                    return this;
                break;
                case "+":
                    return this;
                break;
            }
        }

        override size_t toHash() const {
            return typeid(x).toHash() + typeid(y).toHash();
        }

        bool opEquals(const Vector2 other) const {
            if (other is this) return true;
            if (other is null) return false;
            return (x == other.x) && (y == other.y);
        }

        override string toString() const {
            return x.to!string ~ ", " ~ y.to!string;
        }

        Vector2 opOpAssign(string op)(Vector2 b) {
            switch (op) {
                case "-":
                    x -= b.x;
                    y -= b.y;
                    return this;
                break;
                case "+":
                    x += b.x;
                    y += b.y;
                    return this;
                break;
                case "*":
                    x *= b.x;
                    y *= b.y;
                    return this;
                break;
                case "/":
                    x /= b.x;
                    y /= b.y;
                    return this;
                break;
                case "%":
                    x %= b.x;
                    y %= b.y;
                    return this;
                break;
            }
        }

        Vector2 opOpAssign(string op)(T b) {
            switch (op) {
                case "-":
                    x -= b;
                    y -= b;
                    return this;
                break;
                case "+":
                    x += b;
                    y += b;
                    return this;
                break;
                case "*":
                    x *= b;
                    y *= b;
                    return this;
                break;
                case "/":
                    x /= b;
                    y /= b;
                    return this;
                break;
                case "%":
                    x %= b;
                    y %= b;
                    return this;
                break;
            }
        }

        /******************************
        * STATIC GETTERS AND SETTERS  *
        ******************************/

        public T[] asArray() {
            return [x, y];
        }

        public Vector2!T clone() {
            return new Vector2!T(x, y);
        }

        public static Vector2f fromAngle(float p_angle) {
            return new Vector2f(cos(p_angle), sin(p_angle));
        }
        
        /**************************
        *   FLOATING POINT MATH   *
        ***************************/
        static if(isFloatingPoint!T) {
            // TODO
            // https://glmatrix.net/docs/vec2.js
            // https://github.com/godotengine/godot/blob/master/core/math/vector2.cpp

            public Vector2!T abs() {
                return new Vector2!T(std.math.abs(x), std.math.abs(y));
            }
            
            public float angle() {
                return atan2(y, x);
            }

            // public T angleTo(Vector2 to) {
            //     return 0;
            // }

            // public T angleToPoint(Vector2 to) {
            //     return 0;
            // }

            public T aspect() {
                return x / y;
            }

            // public Vector2 bounce(Vector2 n) {
            //     return new Vector2();
            // }

            public Vector2!T ceil() {
                return new Vector2!T(
                    std.math.ceil(x), 
                    std.math.ceil(y)
                    );
            }

            public Vector2!T clamped(float len) {
                len = len < 0.0f ? 0.0f : len;
                // return new Vector2(std.math.fmin(x));
                return new Vector2!T();
            }

            public Vector3f cross(Vector2!T to) {
                return new Vector3f(0, 0, x * to.y - y * to.x);
            }

            // public Vector2 cubicInterpolate(Vector2 b, Vector2 prea, Vector2 postb, float weight) {
            //     return new Vector2();
            // }

            // public Vector2 directionTo(Vector2 n) {
            //     return new Vector2();
            // }

            // public Vector2 distanceSquaredTo(Vector2 n) {
            //     return new Vector2();
            // }

            // public Vector2 distanceTo(Vector2 n) {
            //     return new Vector2();
            // }

            public T dot(Vector2 to) {
                return dotProduct([x, y], [to.x, to.y]);
            }

            public Vector2!T floor() {
                return new Vector2!T(
                    std.math.floor(x), 
                    std.math.floor(y));
            }

            // public bool isEqualApprox(Vector2 v) {
            //     return false;
            // }

            public bool isNormalized() {
                return isClose(lengthSquared, 1, float.epsilon);
            }
            alias isNormalised = isNormalized;

            public float length() {
                return sqrt(lengthSquared);
            }

            public float lengthSquared() {
                return (x * x) + (y * y);
            }

            // public Vector2 linearInterpolate(Vector2 to, float weight) {
            //     return new Vector2();
            // }

            // public Vector2 moveToward(Vector2 n) {
            //     return new Vector2();
            // }

            public void normalize() {
                if (isIntegral!T) return;
                float l = lengthSquared;
                if (l != 0) {
                    l = sqrt(lengthSquared);
                    x = x / l;
                    y = y / l;
                }
            }

            public Vector2!T normalized() {
                Vector2!T v = clone();
                v.normalize();
                return v;
            }
            alias normalised = normalized;

            // public Vector2 project(Vector2 b) {
            //     return new Vector2();
            // }

            // public Vector2 reflect(Vector2 n) {
            //     return new Vector2();
            // }

            // public Vector2 rotated(float phi) {
            //     return new Vector2();
            // }

            public Vector2!T round() {
                return new Vector2!T(
                    std.math.round(x), 
                    std.math.round(y));
            }

            public Vector2!T sign() {
                return new Vector2!T(std.math.sgn(x), std.math.sgn(y));
            }

            // public Vector2!T slerp(Vector2 to, float weight) {
            //     return new Vector2!T();
            // }

            // public Vector2!T slide(Vector2 n) {
            //     return new Vector2!T();
            // }

            // public Vector2!T snapped(Vector2 n) {
            //     return new Vector2!T();
            // }

            // public Vector2!T tangent() {
            //     return new Vector2!T();
            // }
        }
    }
}