module walker;

import std.stdio;
import std.file;
import std.path;
import std.array : array;
import std.range;
import std.algorithm;
import std.exception : enforce;
import std.parallelism;
import core.sync.mutex;

import tree;
import sort;
import stat.total;
import item.item_default : ItemCollector;
import color : ColorConfig, defaultColorConfig;

// Define the compile-time constant for parallelism
enum useParallelism = false;

struct WalkDirConfig {
    SortType sortType;
    bool showHiddenFiles;
    size_t depthLimit;
    bool showPath;
    bool noAnsi;
    bool showFullPath;
}

struct WalkDir {
    Tree* tree;
    string path;
    Totals* total;
    WalkDirConfig config;
    ColorConfig* colorConfig;
}

void walk(ref WalkDir walkDir) {
    walkDir.total.directories += 1; // Count the root directory
    // Start the recursive walking
    walkRecursiveParallel(walkDir, 0);
}

private void walkRecursiveParallel(ref WalkDir walkDir, size_t currentDepth) {
    if (walkDir.config.depthLimit != size_t.max && currentDepth >= walkDir.config.depthLimit) {
        return;
    }

    try {
        auto entries = dirEntries(walkDir.path, SpanMode.shallow)
            .filter!(e => walkDir.config.showHiddenFiles || !isHidden(e.name))
            .array();

        sortEntries(entries, walkDir.config.sortType);

        size_t totalEntries = entries.length;

        foreach (index, entry; entries) {
            bool isLast = (index == totalEntries - 1);

            synchronized {
                if (currentDepth >= walkDir.tree.config.nodes.length) {
                    walkDir.tree.config.nodes ~= isLast ? 0 : 1;
                } else {
                    walkDir.tree.config.nodes[currentDepth] = isLast ? 0 : 1;
                }

                walkDir.tree.printTree(currentDepth, isLast);

                auto itemCollector = ItemCollector(entry, currentDepth);
                itemCollector.getItem(walkDir, walkDir.colorConfig ? *walkDir.colorConfig : defaultColorConfig);
            }

            if (entry.isDir) {
                auto subDir = WalkDir(
                    walkDir.tree,
                    entry.name,
                    walkDir.total,
                    walkDir.config,
                    walkDir.colorConfig
                );

                static if (useParallelism) {
                    import std.parallelism : taskPool, task;
                    auto t = task({
                        walkRecursiveParallel(subDir, currentDepth + 1);
                    });
                    taskPool.put(t);
                } else {
                    walkRecursiveParallel(subDir, currentDepth + 1);
                }
            }
        }

        synchronized {
            if (currentDepth < walkDir.tree.config.nodes.length) {
                walkDir.tree.config.nodes = walkDir.tree.config.nodes[0..currentDepth];
            }
        }

    } catch (Exception e) {
        writeln("Error reading directory '", walkDir.path, "': ", e.msg);
    }
}

bool isHidden(string path) {
    return baseName(path).startsWith(".");
}