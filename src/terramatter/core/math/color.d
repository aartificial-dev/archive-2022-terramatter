module terramatter.core.math.color;

import std.math;
import std.algorithm.comparison;
import std.conv;

import terramatter.core.math.vector4;

class Color {
    public float r;
    public float g;
    public float b;
    public float a;

    this(float r = 1, float g = 1, float b = 1, float a = 1) {
        this.r = r;
        this.g = g;
        this.b = b;
        this.a = a;
    }

    override size_t toHash() const {
        return typeid(r).toHash() + typeid(g).toHash() + typeid(b).toHash();
    }

    bool opEquals(const Color other) const {
        if (other is this) return true;
        if (other is null) return false;
        return (r == other.r) && (g == other.g) && (b == other.b);
    }

    override string toString() const {
        return r.to!string ~ ", " ~ g.to!string ~ ", " ~ b.to!string;
    }

    Color opOpAssign(string op)(Color c) {
        switch (op) {
            case "-":
                r -= c.r;
                g -= c.g;
                b -= c.b;
                a -= c.a;
                return this;
            break;
            case "+":
                r += c.r;
                g += c.g;
                b += c.b;
                a += c.a;
                return this;
            break;
            case "*":
                r *= c.r;
                g *= c.g;
                b *= c.b;
                a *= c.a;
                return this;
            break;
            case "/":
                r /= c.r;
                g /= c.g;
                b /= c.b;
                a /= c.a;
                return this;
            break;
            case "%":
                r %= c.r;
                g %= c.g;
                b %= c.b;
                a %= c.a;
                return this;
            break;
        }
    }

    public float[] asArray() {
        return [r, g, b, a];
    }

    Color clone() {
        return new Color(r, g, b, a);
    }

    Vector4f toVec4() {
        return new Vector4f(r, g, b, a);
    }

    bool isClose(Color col) {
        return std.math.isClose(r, col.r) &&
               std.math.isClose(g, col.g) &&
               std.math.isClose(b, col.b) &&
               std.math.isClose(a, col.a);
    }

    Color clamped(const Color p_min = new Color(0, 0, 0, 0), 
                  const Color p_max = new Color(1, 1, 1, 1)) {
        return new Color(
            r.clamp(p_min.r, p_max.r) ,
            g.clamp(p_min.g, p_max.g) ,
            b.clamp(p_min.b, p_max.b) ,
            a.clamp(p_min.a, p_max.a)
            );
    }

    void invert() {
        r = 1.0f - r;
        g = 1.0f - g;
        b = 1.0f - b;
    }

    Color inverted() {
        return new Color(
            1.0f - r,
            1.0f - g,
            1.0f - b
        );
    }

    float luminance() {
        return 0.2126f * r + 0.7152f * g + 0.0722f * b;
    }

	Color lerp(const Color p_to, float p_weight) {
		Color res = clone();
		res.r += (p_weight * (p_to.r - r));
		res.g += (p_weight * (p_to.g - g));
		res.b += (p_weight * (p_to.b - b));
		res.a += (p_weight * (p_to.a - a));
		return res;
	}

	Color darkened(float p_amount) {
		Color res = clone();
		res.r = res.r * (1.0f - p_amount);
		res.g = res.g * (1.0f - p_amount);
		res.b = res.b * (1.0f - p_amount);
		return res;
	}

	Color lightened(float p_amount) {
		Color res = clone();
		res.r = res.r + (1.0f - res.r) * p_amount;
		res.g = res.g + (1.0f - res.g) * p_amount;
		res.b = res.b + (1.0f - res.b) * p_amount;
		return res;
	}

    // TODO
    // https://github.com/godotengine/godot/blob/master/core/math/color.h
    // https://github.com/godotengine/godot/blob/master/core/math/color.cpp
}