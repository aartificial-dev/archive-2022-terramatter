/*┌──────────────────────────────────────┐  
  │             TERRAMATTER              │  
  ├──────────────────────────────────────┤  
  │    GAME BY AL1-CE (AKA SILYNEKO)     │  
  │ GAME ENGINE BY AL1-CE (AKA SILYNEKO) │  
  │          PART OF ARTIFICIAL          │  
  │       COPYRIGHT (C) 2022-2022        │  
  └──────────────────────────────────────┘*/

import std.stdio;
import std.string;

import terramatter.core.engine;
import terramatter.game.game;

int main(string[] args) {

    dstring winName = `
 #                           #   #          
### ### ### ###  ## ###  ## ### ### ### ### 
 #  ##  #   #   # # ### # #  #   #  ##  #   
 ## ### #   #   ### # # ###  ##  ## ### #   
`d;

    dstring unixName = `
▀█▀ █▀▀ █▀█ █▀█ ▄▀█ █▀▄▀█ ▄▀█ ▀█▀ ▀█▀ █▀▀ █▀█
 █  ██▄ █▀▄ █▀▄ █▀█ █ ▀ █ █▀█  █   █  ██▄ █▀▄
`d;

    version(Windows) {
        writef("%s\n", winName);
    } else {
        writef("%s\n", unixName);
    }

    writeln("Creating Engine instance.\n");

    Engine engine = new Engine(800, 600, 60, new Game());
    engine.createWindow("TerraMatter");
    
    return engine.start();
}