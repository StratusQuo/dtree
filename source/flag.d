// source/flag.d
module flag;

import std.getopt;
import std.path;
import std.file;
import std.conv : to;
import std.file : getcwd;
import sort : SortType;
import std.stdio : writeln;
import std.exception : enforce;

enum LayoutType {
    none,
    defaultLayout,
    all,
}

struct Flag {
    string targetDir;
    SortType sortType = SortType.caseSensitive;
    LayoutType layoutType = LayoutType.none;
    bool showHiddenFiles = false;
    bool showPath = false;
    size_t depthLimit = size_t.max;
    bool noAnsi = false;
    bool useAscii = false;
    bool showFullPath = false;
}

Flag parseFlags(string[] args) {
    Flag flag;
    bool defaultFlag = false;
    bool allFlag = false;

    try {
        auto helpInformation = getopt(
            args,
            "default|d", "Use default layout", &defaultFlag,
            "all|a", "Show all details", &allFlag,
            "case-sensitive|s", "Use case-sensitive sorting", &flag.sortType,
            "no-ansi|n", "Disable ANSI color output", &flag.noAnsi,
            "hidden-file", "Show hidden files", &flag.showHiddenFiles,
            "show-path|p", "Show full path", &flag.showPath,
            "level|L", "Set depth limit", &flag.depthLimit,
            "ascii", "Use ASCII characters for tree branches", &flag.useAscii,
            "full-path|f", "Show full path for root directory", &flag.showFullPath
        );

        if (helpInformation.helpWanted) {
            defaultGetoptPrinter("Usage: treecraft_d [options] [directory]", helpInformation.options);
            import core.stdc.stdlib : exit;
            exit(0);
        }

        // Set layout type based on flags
        if (defaultFlag) flag.layoutType = LayoutType.defaultLayout;
        if (allFlag) flag.layoutType = LayoutType.all;

        // Determine the target directory
        if (args.length > 1) {
            string potentialDir = args[$ - 1];
            flag.targetDir = exists(potentialDir) ? potentialDir : dirName(potentialDir);
        } else {
            flag.targetDir = getcwd();
        }
    } catch (Exception e) {
        writeln("Error parsing command-line arguments: ", e.msg);
        import core.stdc.stdlib : exit;
        exit(1);
    }

    // ! Debugging: Print parsed flags (remove in production)
    // writeln("Parsed Flags:");
    // writeln("  Target Directory: ", flag.targetDir);
    // writeln("  Sort Type: ", flag.sortType);
    // writeln("  Layout Type: ", flag.layoutType);
    // writeln("  Show Hidden Files: ", flag.showHiddenFiles);
    // writeln("  Show Path: ", flag.showPath);
    // writeln("  Depth Limit: ", flag.depthLimit);
    // writeln("  No ANSI: ", flag.noAnsi);
    // writeln("  Use ASCII: ", flag.useAscii);
    // writeln("  Show Full Path: ", flag.showFullPath);

    return flag;
}