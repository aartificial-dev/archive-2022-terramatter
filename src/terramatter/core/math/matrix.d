module terramatter.core.math.matrix;

import std.math;
import std.numeric;
import std.conv;
import std.traits;
import std.typetuple;
import std.algorithm;
import std.stdio;
import std.string;

import terramatter.core.math.vector;
import terramatter.core.math.math;

alias Matrix2(T) = Matrix!(T, 2, 2);
// alias Matrix2x3(T) = Matrix!(T, 2, 3);
// alias Matrix2x4(T) = Matrix!(T, 2, 4);
// alias Matrix2xD(T) = Matrix!(T, 2, 0);
// alias Matrix3x2(T) = Matrix!(T, 3, 2);
alias Matrix3(T) = Matrix!(T, 3, 3);
// ...
alias Matrix4(T) = Matrix!(T, 4, 4);

alias Matrix2f = Matrix2!float;
alias Matrix3f = Matrix3!float;
alias Matrix4f = Matrix4!float;

class Matrix(T, size_t W, size_t H) if (isNumeric!T && (W > 0 || H > 0)) {
    public T[W][H] data;
    // visually matrix should look like this
    //     x0 x1 x2 x3
    //     [1  0  0  x] y0
    //     [0  1  0  y] y1
    //     [0  0  1  z] y2
    //     [0  0  0  1] y3
    // but in reality it looks like this
    //     x0 x1 x2 x3
    //     [1  0  0  0] y0
    //     [0  1  0  0] y1
    //     [0  0  1  0] y2
    //     [x  y  z  1] y3
    // it's rotated 90 cw and flipped?
    // [ [1, 0, 0, x], [0, 1, 0, y], [0, 0, 1, z], [0, 0, 0, 1] ]

    alias data this;
    alias dataType = T;
    alias MatType = Matrix!(T, W, H);
    enum size_t width = W;
    enum size_t height = H;

    this() {
        foreach (x; 0 .. W) foreach (y; 0 .. H) data[x][y] = 0;
    }

    this(in T val) {
        foreach (x; 0 .. W) foreach (y; 0 .. H) data[x][y] = val;
    }

    this(in T[W][H] vals...) {
        data = vals;
    }

    this(in T[W*H] vals...) {
        foreach (x; 0 .. W) foreach (y; 0 .. H)  data[x][y] = vals[x * W + y];
    }

    /******************************
    * UNARY OPERATIONS OVERRIDES  *
    ******************************/
    
    // ONLY MAT +- MAT
    // opBinary x [+, -, *, /, %] y
    auto opBinary(string op, R)(in Matrix!(R, W, H) b) const if ( isNumeric!R  && op == "+" && op == "-") {
        MatType mat = new MatType();
        foreach (x; 0 .. W) foreach (y; 0 .. H) 
            mixin( " mat.data[x][y] = data[x][y] " ~ op ~ " b.data[x][y];" ); 
        return  mat;
    }

    // opBinaryRight y [+, -, *, /, %] x
    auto opBinaryRight(string op, R)(in Matrix!(R, W, H) b) const if ( isNumeric!R  && op == "+" && op == "-") {
        MatType mat = new MatType();
        foreach (x; 0 .. W) foreach (y; 0 .. H) 
            mixin( " mat.data[x][y] = b.data[x][y] " ~ op ~ " data[x][y];" ); 
        return  mat;
    }
    
    // ONLY MAT * MAT
    auto opBinary(string op, R, size_t U, size_t V)(in Matrix!(R, U, V) b) const 
        if ( isNumeric!R  && op == "*" && W == V) {
        MatType mat = new MatType();
        foreach (y; 0 .. H) foreach (x; 0 .. W) {
            mat.data[x][y] = 0;
            foreach(w; 0 .. V) {
                mat.data[x][y] += data[x][w] * b.data[w][y];
            }
        }
        return  mat;
    }

    // ANY NON +- MAX ? NUMBER
    auto opBinary(string op, R)(in R b) const if ( isNumeric!R && op != "+" && op != "-") {
        MatType mat = new MatType();
        foreach (x; 0 .. W) foreach (y; 0 .. H) 
            mixin( " mat.data[x][y] = data[x][y] " ~ op ~ " b;" ); 
        return  mat;
    }

    auto opBinaryRight(string op, R)(in R b) const if ( isNumeric!R && op != "+" && op != "-") {
        MatType mat = new MatType();
        foreach (x; 0 .. W) foreach (y; 0 .. H) 
            mixin( " mat.data[x][y] = b " ~ op ~ " data[x][y];" ); 
        return  mat;
    }

    // opEquals x == y
    bool opEquals(R)(in Matrix!(R, W, H) b) const if ( isNumeric!R ) {
        bool eq = true;
        foreach (x; 0 .. W) foreach (y; 0 .. H) 
            eq = eq && data[x][y] == b.data[x][y];
        return eq;
    }

    // opUnary [-, +, --, ++] x
    auto opUnary(string op)() if(op == "-") {
        MatType mat = new MatType();
        if (op == "-")
            foreach (x; 0 .. W) foreach (y; 0 .. H) mat.data[x][y] = -data[x][y];
        return  mat;
    }
    
    // opOpAssign x [+, -, *, /, %]= y
    auto opOpAssign(string op, R)(in Matrix!(R, W, H) b ) if ( isNumeric!R ) {
        foreach (x; 0 .. W) foreach (y; 0 .. H) 
            mixin( "data[x][y] = data[x][y] " ~ op ~ " b.data[x][y];" ); 
        return  this;
    }
    
    auto opOpAssign(string op, R)( in R b ) if ( isNumeric!R ) { 
        foreach (x; 0 .. W) foreach (y; 0 .. H) 
            mixin( "data[x][y] = data[x][y] " ~ op ~ " b;" ); 
        return  this;
    }

    override size_t toHash() const @nogc @safe pure nothrow {
        T s = 0;
        foreach (x; 0 .. W) foreach (y; 0 .. H) { s += data[x][y]; }
        return cast(size_t) s;
    }

    public override string toString() const {
        import std.array : appender;
        import std.conv : to;
        auto s = appender!string;
        static foreach (x; 0 .. W) {
        	s ~= "[";
            foreach (y; 0 .. H) {
                s ~= data[x][y].to!string;
                if (y != H - 1) s ~= ", ";
            }
            s ~= "]\n";
        }
        return s[];
    }

    /******************************
    * STATIC GETTERS AND SETTERS  *
    ******************************/

    public T[W * H] createBuffer() {
        T[W * H] buf;
        foreach (x; 0 .. W) foreach (y; 0 .. H) {
            buf[x * W + y] = data[x][y];
        }
        return buf;
    }

    public MatType initIdentity() {
        // i know it looks wierd, but i'm just iterating
        initZero();
        for (int i = 0; i < W.min(H); i ++) {
            data[i][i] = 1;
        }
        return this;
    }

    public MatType setAll(T val) {
        foreach (x; 0 .. W) foreach (y; 0 .. H) {
            data[x][y] = val;
        }
        return this;
    }

    public MatType initZero() { return setAll(0); }

    public MatType initOne() { return setAll(1); }

    /******************************
    *           MATRIX4F          *
    ******************************/
    static if (W == 4 && H == 4 && isFloatingPoint!T) {
        public MatType initTranslation(T[3] p_pos ...) {
            initIdentity();
            data[0][3] = p_pos[0];
            data[1][3] = p_pos[1];
            data[2][3] = p_pos[2];
            return this;
        }

        public MatType initScale(T[3] p_scale ...) {
            initIdentity();
            data[0][0] = p_scale[0];
            data[1][1] = p_scale[1];
            data[2][2] = p_scale[2];
            return this;
        }

        public MatType initPerspective(T fov, T aspectRatio, T zNear, T zFar) {
            T ar = aspectRatio;
            T tanHalfFOV = tan(fov / 2);
            T zRange = zNear - zFar;

            initZero();
            data[0][0] = 1.0f / (tanHalfFOV * ar);
            data[1][1] = 1.0f / tanHalfFOV;
            data[2][2] = (-zNear -zFar)/zRange;	
            data[2][3] = 2 * zFar * zNear / zRange;
            data[3][2] = 1;
            return this;
        }
        
        public MatType initOrthographic(T left, T right, T bottom, T top, T near, T far) {
            float w = (right - left);
            float h = (top - bottom);
            float depth = (far - near);

            initZero();
            data[0][0] = 2/w; 
            data[1][1] = 2/h; 
            data[2][2] = -2/depth; 
            data[3][0] = -(right + left)/w;
            data[3][1] = -(top + bottom)/h;
            data[3][2] = -(far + near)/depth;
            data[3][3] = 1; 
            return this;
        }

        public MatType initRotation(T[3] p_rot ...) {
            MatType rx = new MatType();
            MatType ry = new MatType();
            MatType rz = new MatType();

            rx.initIdentity();
            rx.initIdentity();
            rx.initIdentity();

            p_rot[0] = degToRad(p_rot[0]);
            p_rot[1] = degToRad(p_rot[1]);
            p_rot[2] = degToRad(p_rot[2]);

            rz.data[0][0] = cos(p_rot[2]); rz.data[0][1] = -sin(p_rot[2]);
            rz.data[1][0] = sin(p_rot[2]); rz.data[1][1] = cos(p_rot[2]);

            rx.data[1][1] = cos(p_rot[0]); rx.data[1][2] = -sin(p_rot[0]);
            rx.data[2][1] = sin(p_rot[0]); rx.data[2][2] = cos(p_rot[0]);

            ry.data[0][0] = cos(p_rot[1]); ry.data[0][2] = -sin(p_rot[1]);
            ry.data[2][0] = sin(p_rot[1]); ry.data[2][2] = cos(p_rot[1]);

            MatType m = rz * ry * rx;
            data = m.data;
            return this;
        }
        
        public MatType initRotation(Vector3!T forward, Vector3!T up) {
            Vector3!T f = forward.normalized();

            Vector3!T r = up.normalized();
            r = r.cross(f);

            Vector3!T u = f.cross(r);

            return initRotation(f, u, r);
        }
        
        public MatType initRotation(Vector3!T forward, Vector3!T up, Vector3!T right) {
            Vector3!T f = forward;
            Vector3!T r = right;
            Vector3!T u = up;

            data[0][0] = r.x;	data[0][1] = r.y;	data[0][2] = r.z;	data[0][3] = 0;
            data[1][0] = u.x;	data[1][1] = u.y;	data[1][2] = u.z;	data[1][3] = 0;
            data[2][0] = f.x;	data[2][1] = f.y;	data[2][2] = f.z;	data[2][3] = 0;
            data[3][0] = 0;		data[3][1] = 0;		data[3][2] = 0;		data[3][3] = 1;
            return this;
        }

        public MatType translate(T[3] p_dist ...) {return this;}
        public MatType rotate(T p_angle, T[3] p_axis ...) {return this;}
        public MatType scale(T[3] p_scale ...) {return this;}
        
        // public Vector3!T vec3transform(Vector3f r) {
        //     return new Vector3f(data[0][0] * r.x + data[0][1] * r.y + data[0][2] * r.z + data[0][3],
        //                         data[1][0] * r.x + data[1][1] * r.y + data[1][2] * r.z + data[1][3],
        //                         data[2][0] * r.x + data[2][1] * r.y + data[2][2] * r.z + data[2][3]);
        // }
    }

    // TODO

    // LINK https://github.com/dexset/descore/blob/master/import/des/math/linear/matrix.d
    // LINK https://github.com/godotengine/godot/blob/master/core/math/camera_matrix.cpp
}