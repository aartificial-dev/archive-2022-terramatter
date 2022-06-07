module terramatter.core.io.input;

import bindbc.sdl;

import terramatter.render.window;

static class Input {
    // private static bool[] _keysHeld = new bool[500];
    // private static bool[] _mouseButtonsHeld = new bool[10];

    public static void update() {
        SDL_Event e;

        while (SDL_PollEvent(&e)) {
            // if (e.key.keysym.sym < 500) {
            //     _keysHeld[e.key.keysym.sym] = (e.type == SDL_EventType.SDL_KEYDOWN);
            // }

            switch (e.type) {
                case SDL_EventType.SDL_KEYDOWN:
                    // keydown
                    // e.key.keysym.scancode
                break;
                case SDL_EventType.SDL_QUIT:
                    Window.setRequestedClose(true);
                break;
                default:
                    //
            }


        }
    }

    // public static bool isKeyPressed(int keyCode){ 
	// 	return _keysHeld[keyCode];
	// }

	// public static bool isMouseButtonPressed(int keyCode) {
	// 	return _mouseButtonsHeld[keyCode];
	// }
}

class InputEvent {
    
}