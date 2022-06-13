module terramatter.core.os.filesystem;

import std.stdio;
import std.file;
import std.path;

string readFile(string path) {
    path = path.absolutePath.buildNormalizedPath;

    if (!path.isFile) {
        writefln("ERROR: Unable to find file at '%s'.", path);
        throw new Error("Unable to read file.");
    }

    string t = readText(path);
    return t;
}

string[] listdir(string pathname) {
    import std.algorithm;
    import std.array;
    import std.file;
    import std.path;

    return std.file.dirEntries(pathname, SpanMode.shallow)
        .filter!(a => a.isFile)
        .map!((return a) => baseName(a.name))
        .array;
}