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
    
    // opBinary x [+, -, *, /, %] y
    auto opBinary(string op, R)(in Matrix!(R, W, H) b) const if ( isNumeric!R ) {
        MatType mat = new MatType();
        foreach (x; 0 .. W) foreach (y; 0 .. H) 
            mixin( " mat.data[x][y] = data[x][y] " ~ op ~ " b.data[x][y];" ); 
        return  mat;
    }

    auto opBinary(string op, R)(in R b) const if ( isNumeric!R ) {
        MatType mat = new MatType();
        foreach (x; 0 .. W) foreach (y; 0 .. H) 
            mixin( " mat.data[x][y] = data[x][y] " ~ op ~ " b;" ); 
        return  mat;
    }

    // opBinaryRight y [+, -, *, /, %] x
    auto opBinaryRight(string op, R)(in Matrix!(R, W, H) b) const if ( isNumeric!R ) {
        MatType mat = new MatType();
        foreach (x; 0 .. W) foreach (y; 0 .. H) 
            mixin( " mat.data[x][y] = data[x][y] " ~ op ~ " b.data[x][y];" ); 
        return  mat;
    }

    auto opBinaryRight(string op, R)(in R b) const if ( isNumeric!R ) {
        MatType mat = new MatType();
        foreach (x; 0 .. W) foreach (y; 0 .. H) 
            mixin( " mat.data[x][y] = data[x][y] " ~ op ~ " b;" ); 
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
        s ~= "[";
        static foreach (x; 0 .. W) {
            foreach (y; 0 .. H) {
                s ~= data[x][y].to!string;
                s ~= ", ";
            }
            s ~= "]\n[";
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

    public void initIdentity() {
        // i know it looks wierd, but i'm just iterating
        initZero();
        for (int i = 0; i < W.min(H); i ++) {
            data[i][i] = 1;
        }
    }

    public void setAll(T val) {
        foreach (x; 0 .. W) foreach (y; 0 .. H) {
            data[x][y] = val;
        }
    }

    public void initZero() { setAll(0); }

    public void initOne() { setAll(1); }

    /******************************
    *           MATRIX4F          *
    ******************************/
    static if (W == 4 && H == 4 && isFloatingPoint!T) {
        public void initTranslation(T tx, T ty, T tz) {
            initIdentity();
            data[0][3] = tx;
            data[1][3] = ty;
            data[2][3] = tz;
        }

        public void initScale(T tx, T ty, T tz) {
            initIdentity();
            data[0][0] = tx;
            data[1][1] = ty;
            data[2][2] = tz;
        }

        public void initPerspective(T fov, T aspectRatio, T zNear, T zFar) {
            T ar = aspectRatio;
            T tanHalfFOV = tan(fov / 2);
            T zRange = zNear - zFar;

            initZero();
            data[0][0] = 1.0f / (tanHalfFOV * ar);
            data[1][1] = 1.0f / tanHalfFOV;
            data[2][2] = (-zNear -zFar)/zRange;	
            data[2][3] = 2 * zFar * zNear / zRange;
            data[3][2] = 1;
        }
        
        public void initOrthographic(T left, T right, T bottom, T top, T near, T far) {
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
        }

        public void initRotation(T x, T y, T z) {
            MatType rx = new MatType();
            MatType ry = new MatType();
            MatType rz = new MatType();

            rx.initIdentity();
            rx.initIdentity();
            rx.initIdentity();

            x = degToRad(x);
            y = degToRad(y);
            z = degToRad(z);

            rz.data[0][0] = cos(z); rz.data[0][1] = -sin(z);
            rz.data[1][0] = sin(z); rz.data[1][1] = cos(z);

            rx.data[1][1] = cos(x); rx.data[1][2] = -sin(x);
            rx.data[2][1] = sin(x); rx.data[2][2] = cos(x);

            ry.data[0][0] = cos(y); ry.data[0][2] = -sin(y);
            ry.data[2][0] = sin(y); ry.data[2][2] = cos(y);

            MatType m = rz * ry * rx;
            data = m.data;
        }
        
        public void initRotation(Vector3!T forward, Vector3!T up) {
            Vector3!T f = forward.normalized();

            Vector3!T r = up.normalized();
            r = r.cross(f);

            Vector3!T u = f.cross(r);

            return initRotation(f, u, r);
        }
        
        public void initRotation(Vector3!T forward, Vector3!T up, Vector3!T right) {
            Vector3!T f = forward;
            Vector3!T r = right;
            Vector3!T u = up;

            data[0][0] = r.x;	data[0][1] = r.y;	data[0][2] = r.z;	data[0][3] = 0;
            data[1][0] = u.x;	data[1][1] = u.y;	data[1][2] = u.z;	data[1][3] = 0;
            data[2][0] = f.x;	data[2][1] = f.y;	data[2][2] = f.z;	data[2][3] = 0;
            data[3][0] = 0;		data[3][1] = 0;		data[3][2] = 0;		data[3][3] = 1;
        }
        
        public Vector3!T transform(Vector3f r) {
            return new Vector3f(data[0][0] * r.x + data[0][1] * r.y + data[0][2] * r.z + data[0][3],
                                data[1][0] * r.x + data[1][1] * r.y + data[1][2] * r.z + data[1][3],
                                data[2][0] * r.x + data[2][1] * r.y + data[2][2] * r.z + data[2][3]);
        }
    }
}