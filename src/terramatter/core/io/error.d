module terramatter.core.io.error;

import std.stdio: write, writef, writeln, writefln;

alias ErrLog = ErrorLogger;

static class ErrorLogger {
    private static string lastError = "";
    
    /**
     * Params:
     *    errorMessage = Error message
     */
    public static void queueError(string errorMessage) {
        if (errorMessage != lastError) {
            lastError = errorMessage;
            write("\n" ~ lastError);
        } else {
            write(".");
        }
    }
}