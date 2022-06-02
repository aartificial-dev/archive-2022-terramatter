module terramatter.core.components.gameobject;

import terramatter.core.engine;
import terramatter.core.math.transform;

class GameObject {
    private GameObject[] children;
    private Transform transform;
    private Engine engine;
}