module terramatter.core.components.node;

import terramatter.core.components.gameobject;

class Node: GameObject {
    public string name;
    public ulong id;

    public void ready(){}
    public void update(){}
    public void input(){}
    public void onCreate(){}
    public void onDestroy(){}
}