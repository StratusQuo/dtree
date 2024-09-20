module tree;

import numem.all;
import std.stdio;
import std.path : baseName, dirName;
import flag;

@nogc void nogcWrite(const(char)[] s) {
    import core.stdc.stdio : fwrite, stderr;
    fwrite(s.ptr, 1, s.length, stderr);
    //fwrite(s.ptr, 1, s.length, stdout); //! For Debugging to StdOut
}

struct Tree {
    Config config;
    bool useAscii; // Determines whether to use ASCII or Unicode

    @nogc this(Config config, bool useAscii) {
        this.config = config;
        this.useAscii = useAscii;
    }

    @nogc void printRoot(string path, bool showFullPath) {
        if (showFullPath) {
            nogcWrite(path);
            nogcWrite("\n");
        } else {
            nogcWrite(baseName(path));
            nogcWrite("\n");
        }
    }

    @nogc void printTree(size_t currentDepth, bool isLast) {
        for (size_t i = 0; i < currentDepth; i++) {
            if (i < config.nodes.length && config.nodes[i] == 1) {
                nogcWrite(useAscii ? "|   " : "│   ");
            } else {
                nogcWrite("    ");
            }
        }

        if (isLast) {
            nogcWrite(useAscii ? "`-- " : "└── ");
        } else {
            nogcWrite(useAscii ? "|-- " : "├── ");
        }
    }
}


struct Config {
    size_t[] nodes;
    size_t depth;
}