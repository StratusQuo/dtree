module stat.head;

import std.stdio;
import std.path;
import std.string : format;
import std.format : FormatException; // Import FormatException
import flag : LayoutType;

struct HeaderConfig {
    LayoutType layoutType;
    bool noAnsi;
    // Add other necessary flag properties here
}

struct Header {
    HeaderConfig config;
    string targetDir;

    this(HeaderConfig config, string targetDir) {
        this.config = config;
        this.targetDir = targetDir;
    }

    void printHeader() {
        string dirName = baseName(targetDir);
        try {
            if (config.layoutType == LayoutType.all) {
                modHeader(dirName);
            } else {
                writeln(format("%s", dirName));
            }
        } catch (FormatException e) {
            writeln("Formatting error in printHeader: ", e.msg);
        }
    }

    private void modHeader(string dirName) {
        try {
            // Calculate padding for alignment
            size_t totalSpaces = 4;
            size_t dirNameLen = dirName.length;

            size_t remainingSpaces = (dirNameLen < totalSpaces) ? (totalSpaces - dirNameLen) : 0;

            string indentedDirName = format("%*s%s%s%s",
                remainingSpaces,
                "",
                config.noAnsi ? "\033[1;32m" : "", // Bright green
                dirName,
                config.noAnsi ? "\033[0m" : ""     // Reset
            );

            writeln();
            writeln("  ", indentedDirName);
            writeln("    .");
        } catch (FormatException e) {
            writeln("Formatting error in modHeader: ", e.msg);
        }
    }
}
