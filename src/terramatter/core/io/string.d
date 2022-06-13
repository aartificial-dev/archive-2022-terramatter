module terramatter.core.io.string;

import std.format: format;
import std.conv: to;

string toStringf(float[] arr, int decimals) {
    size_t size = arr.length;
    string s;
    s ~= "[";
    foreach (i; 0 .. size) {
        s ~= format("%." ~ decimals.to!string ~ "f", arr[i]);
        if (i != size - 1) s ~= ", ";
    }
    s ~= "]";
    return s;
}