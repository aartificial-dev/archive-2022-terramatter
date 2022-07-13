module terramatter.core.components.world;

import std.algorithm.comparison: min, max, clamp;
import std.array: uninitializedArray;
import std.experimental.allocator.mallocator;
import std.experimental.allocator;

import dlib.math.vector;

import terramatter.core.resources.shader;
import terramatter.core.components.chunk;
import terramatter.core.components.block;
import terramatter.core.components.blocks.air;

final class World {
    private Chunk[][][] _chunks = uninitializedArray!(Chunk[][][])(14, 14, 14);
    private ivec3 _chunkSize;

    this(ivec3 chunkAmount) {
        _chunkSize = chunkAmount;
        // allocate();

        foreach (x; 0 .. _chunkSize.x) 
        foreach (z; 0 .. _chunkSize.y) 
        foreach (y; 0 .. _chunkSize.z) 
            _chunks[x][y][z] = new Chunk(ivec3(x, y, z), this);

        update();
    }

    this(ivec3 chunkAmount, Block delegate(ivec3 chunkPos, ivec3 blockPos) generator) {
        _chunkSize = chunkAmount;
        // allocate();

        foreach (x; 0 .. _chunkSize.x) 
        foreach (z; 0 .. _chunkSize.y) 
        foreach (y; 0 .. _chunkSize.z) 
            _chunks[x][y][z] = new Chunk(ivec3(x, y, z), this, generator);
        
        update();
    }

    public void update() {
        foreach (x; 0 .. _chunkSize.x) 
        foreach (z; 0 .. _chunkSize.y) 
        foreach (y; 0 .. _chunkSize.z) 
            _chunks[x][y][z].update();
    }

    public void render(Shader sh) {
        foreach (x; 0 .. _chunkSize.x) 
        foreach (z; 0 .. _chunkSize.y) 
        foreach (y; 0 .. _chunkSize.z) 
            _chunks[x][y][z].render(sh);
    }

    public void dispose() {
        foreach (x; 0 .. _chunkSize.x) 
        foreach (z; 0 .. _chunkSize.y) 
        foreach (y; 0 .. _chunkSize.z) 
            _chunks[x][y][z].dispose();
    }

    // public Chunk getChunk(ivec3 pos) {
    //     pos.x = clamp(pos.x, 0, _chunkSize.x - 1);
    //     pos.y = clamp(pos.y, 0, _chunkSize.y - 1);
    //     pos.z = clamp(pos.z, 0, _chunkSize.z - 1);
    //     return _chunks[pos.x][pos.y][pos.z];
    // }

    public Block getBlock(ivec3 chunkPos, ivec3 blockPos) {
        // GET ADJACENT CHUNK
        if (chunkPos.x < 0 || chunkPos.y < 0 || chunkPos.z < 0 || 
            chunkPos.x >= _chunkSize.x || 
            chunkPos.y >= _chunkSize.y || 
            chunkPos.z >= _chunkSize.z) return new Air();
        if (_chunks[chunkPos.x][chunkPos.y][chunkPos.z].isEmpty) return new Air();
        return _chunks[chunkPos.x][chunkPos.y][chunkPos.z].getBlock(blockPos);
    }

    // public void resize(ivec3 chunkAmount) {
    //     deallocate();
    //     _chunkSize = chunkAmount;
    //     allocate();
    // }

    // public void deallocate() {
    //     Mallocator.instance.disposeMultidimensionalArray(_chunks);
    // }

    // private void allocate() {
    //     _chunks = Mallocator.instance.makeMultidimensionalArray!Chunk(_chunkSize.x, _chunkSize.y, _chunkSize.z);
    // }
}