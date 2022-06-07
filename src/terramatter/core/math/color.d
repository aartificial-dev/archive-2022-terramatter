module terramatter.core.math.color;

import std.math;
import std.algorithm.comparison;
import std.conv;

import terramatter.core.math.vector;

class Color: Vector!(float, 4) {

    this() {
        super();
    }

    this(in float val) {
        super(val);
    }

    this(in float[4] vals...) {
        super(vals);
    }

    public Vector4f toVec4() {
        return new Vector4f(data);
    }

    public void invert() {
        data[0] = 1.0f - data[0];
        data[1] = 1.0f - data[1];
        data[2] = 1.0f - data[2];
        data[3] = 1.0f - data[3];
    }

    public Color inverted() {
        Color col = new Color(data);
        col.invert();
        return col;
    }

    public float luminance() {
        return 0.2126f * data[0] + 0.7152f * data[1] + 0.0722f * data[2];
    }

	public Color lerp(const Color p_to, float p_weight) {
		Color res = copyof();
		res.data[0] += (p_weight * (p_to.data[0] - data[0]));
		res.data[1] += (p_weight * (p_to.data[1] - data[1]));
		res.data[2] += (p_weight * (p_to.data[2] - data[2]));
		res.data[3] += (p_weight * (p_to.data[3] - data[3]));
		return res;
	}

	public Color darkened(float p_amount) {
		Color res = copyof();
		res.data[0] = res.data[0] * (1.0f - p_amount);
		res.data[1] = res.data[1] * (1.0f - p_amount);
		res.data[2] = res.data[2] * (1.0f - p_amount);
		return res;
	}

	public Color lightened(float p_amount) {
		Color res = copyof();
		res.data[0] = res.data[0] + (1.0f - res.data[0]) * p_amount;
		res.data[1] = res.data[1] + (1.0f - res.data[1]) * p_amount;
		res.data[2] = res.data[2] + (1.0f - res.data[2]) * p_amount;
		return res;
	}

    public Color copyof() {
        return new Color(data);
    }
    // TODO
    // https://github.com/godotengine/godot/blob/master/core/math/color.h
    // https://github.com/godotengine/godot/blob/master/core/math/color.cpp
}