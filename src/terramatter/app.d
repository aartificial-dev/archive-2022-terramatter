import std.stdio;
import std.string;

import terramatter.core.engine;
import terramatter.game.game;

int main(string[] args) {
    dstring winName = `
====  |===  |==\  |==\   / |  /\  /\   / |  ====  ====  |===  |==\
 ||   |--   | /   | /   /--|  | \/ |  /--|   ||    ||   |--   | / 
 ||   |___  |  \  |  \  |  |  |    |  |  |   ||    ||   |___  |  \
`d;

    dstring winNameAlt = `
 #                           #   #          
### ### ### ###  ## ###  ## ### ### ### ### 
 #  ##  #   #   # # ### # #  #   #  ##  #   
 ## ### #   #   ### # # ###  ##  ## ### #   
`d;

    dstring unixName = `
▀█▀ █▀▀ █▀█ █▀█ ▄▀█ █▀▄▀█ ▄▀█ ▀█▀ ▀█▀ █▀▀ █▀█
 █  ██▄ █▀▄ █▀▄ █▀█ █ ▀ █ █▀█  █   █  ██▄ █▀▄
`d;

    dstring unixNameAlt = `
▀▀█▀▀ █▀▀ █▀▀█ █▀▀█ █▀▀█ █▀▄▀█ █▀▀█ ▀▀█▀▀ ▀▀█▀▀ █▀▀ █▀▀█ 
░░█░░ █▀▀ █▄▄▀ █▄▄▀ █▄▄█ █░▀░█ █▄▄█ ░░█░░ ░░█░░ █▀▀ █▄▄▀ 
░░▀░░ ▀▀▀ ▀░▀▀ ▀░▀▀ ▀░░▀ ▀░░░▀ ▀░░▀ ░░▀░░ ░░▀░░ ▀▀▀ ▀░▀▀
`d;

    version(Windows) {
        writef("%s\n", winNameAlt);
    } else {
        writef("%s\n", unixNameAlt);
    }

    writeln("Creating Engine instance.\n");

    Engine engine = new Engine(800, 600, 60, new Game());
    engine.createWindow("TerraMatter");
    
    return engine.start();
}