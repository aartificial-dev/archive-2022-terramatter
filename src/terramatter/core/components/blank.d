module terramatter.core.components.blank;

import terramatter.core.components.gameobject;
import terramatter.core.io.input;

class Blank: GameObject {
    protected final override void _create() {}
    
    protected final override void _destroy() {}

    protected final override void _update(float delta) {}

    protected final override void _tick(float delta) {}

    protected final override void _input(InputEvent e) {}

    protected final override void _render() {}
}