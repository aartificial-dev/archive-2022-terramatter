module terramatter.core.components.chunk;

import std.conv;
import std.algorithm.comparison: max, min;

import dlib.math.vector;
import dlib.math.matrix;
import dlib.math.utils;
import dlib.math.transformation;

import bindbc.opengl;

import terramatter.core.resources.mesh;
import terramatter.core.resources.textureatlas;
import terramatter.core.resources.shader;
import terramatter.core.components.block;
import terramatter.core.components.world;
import terramatter.core.components.blocks.air;

import terramatter.render.glwrapper;

final class Chunk {
    public static const byte CHUNK_SIZE = 16;

    private Block[CHUNK_SIZE][CHUNK_SIZE][CHUNK_SIZE] _blocks;
    private ivec3 _chunkPosition;
    private World _world;

    private VertexArray _va;
    private int _vaLength;

    private bool _isEmpty = true;
    public bool isEmpty() { return _isEmpty; }

    this(ivec3 chunkPos, World world) {
        _chunkPosition = chunkPos;
        _world = world;

        foreach (x; 0 .. CHUNK_SIZE) 
        foreach (z; 0 .. CHUNK_SIZE) 
        foreach (y; 0 .. CHUNK_SIZE) 
            _blocks[x][y][z] = new Air();
    }

    this(ivec3 chunkPos, World world, Block delegate(ivec3 chunkPos, ivec3 blockPos) generator) {
        _chunkPosition = chunkPos;
        _world = world;

        _isEmpty = true;

        foreach (x; 0 .. CHUNK_SIZE) 
        foreach (z; 0 .. CHUNK_SIZE) 
        foreach (y; 0 .. CHUNK_SIZE) {
            _blocks[x][y][z] = generator(_chunkPosition, ivec3(x, y, z));
            if (!_blocks[x][y][z].isBlock!Air) _isEmpty = false;
        }
    }

    public void update() {
        // FIXME dispose of prev arrays
        if (_va !is null) _va.dispose();
        
        _isEmpty = true;

        float[] vert = [];
        uint[] indx = [];

        int i = 0;
        foreach (x; 0 .. CHUNK_SIZE) 
        foreach (z; 0 .. CHUNK_SIZE) 
        foreach (y; 0 .. CHUNK_SIZE) {
            Block bl = _blocks[x][y][z];
            vec3 pos = vec3(x.to!float, y.to!float, z.to!float);
            if (bl.isBlock!Air) continue;
            if (_isEmpty) _isEmpty = false;
            // Mesh.generateBlock([
            //     bl.textureFront, bl.textureBack,
            //     bl.textureRight, bl.textureLeft,
            //     bl.textureTop, bl.textureBottom
            //     ], pos, vert, indx, i++);

            if (getBlock(ivec3(x, y, z - 1)).isBlock!Air) 
                Mesh.genFaceNorth(bl.textureFront, pos, vert, indx, i++);
            if (getBlock(ivec3(x, y, z + 1)).isBlock!Air) 
                Mesh.genFaceSouth(bl.textureBack, pos, vert, indx, i++);
            if (getBlock(ivec3(x - 1, y, z)).isBlock!Air) 
                Mesh.genFaceWest(bl.textureLeft, pos, vert, indx, i++);
            if (getBlock(ivec3(x + 1, y, z)).isBlock!Air) 
                Mesh.genFaceEast(bl.textureRight, pos, vert, indx, i++);
            if (getBlock(ivec3(x, y - 1, z)).isBlock!Air) 
                Mesh.genFaceDown(bl.textureBottom, pos, vert, indx, i++);
            if (getBlock(ivec3(x, y + 1, z)).isBlock!Air) 
                Mesh.genFaceUp(bl.textureTop, pos, vert, indx, i++);
        }
        
        _vaLength = indx.length.to!int;

        _va = new VertexArray(
            vert.ptr, csizeof!float(vert),
            indx.ptr, csizeof!uint(indx)
        );
        _va.linkTex2Ddefault();
    }

    public void dispose() {

    }

    public void setBlock(ivec3 pos, Block block) {
        _blocks[pos.x][pos.y][pos.z] = block;
        update();
    }

    public Block getBlock(ivec3 pos) {
        if (_isEmpty) return new Air();
        // GET ADJACENT CHUNK
        if (pos.x < 0) 
            return _world.getBlock(_chunkPosition + ivec3(-1, 0, 0), pos + ivec3(CHUNK_SIZE.to!int, 0, 0));
        if (pos.x >= CHUNK_SIZE.to!int) 
            return _world.getBlock(_chunkPosition + ivec3(1, 0, 0), pos + ivec3(-CHUNK_SIZE.to!int, 0, 0));
        if (pos.y < 0)
            return _world.getBlock(_chunkPosition + ivec3(0, -1, 0), pos + ivec3(0, CHUNK_SIZE.to!int, 0));
        if (pos.y >= CHUNK_SIZE.to!int)
            return _world.getBlock(_chunkPosition + ivec3(0, 1, 0), pos + ivec3(0, -CHUNK_SIZE.to!int, 0));
        if (pos.z < 0)
            return _world.getBlock(_chunkPosition + ivec3(0, 0, -1), pos + ivec3(0, 0, CHUNK_SIZE.to!int));
        if (pos.z >= CHUNK_SIZE.to!int)
            return _world.getBlock(_chunkPosition + ivec3(0, 0, 1), pos + ivec3(0, 0, -CHUNK_SIZE.to!int));
            
        return _blocks[pos.x][pos.y][pos.z];
    }

    public void render(Shader sh) {
        if (_isEmpty) return;
        // FIXME do not render empty
        sh.setMat4("m_transform", translationMatrix(_chunkPosition.to!vec3 * CHUNK_SIZE.to!float));
        _va.renderTexture2D(GL_TRIANGLES, _vaLength, TextureAtlas.getTexture("blocks"));
    }
}