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