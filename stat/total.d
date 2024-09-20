module stat.total;

import std.stdio;
import std.string : format;
import std.conv : to;
import std.datetime;
import std.format : FormatException; // Import FormatException
import flag;

struct Totals {
    size_t directories = 0;
    size_t files = 0;
    ulong size = 0;
    size_t hiddenFiles = 0;

    void printAllStats(double elapsedSeconds) {
        try {
            writeln();
            writeln("  Insights:");
            writeln("    .");
            writeln(format("    %sProcessing Time      : %.2f seconds",
                branchSymbol(), elapsedSeconds));
            writeln(format("    %sVisible Dirs         : %s",
                branchSymbol(), formatWithCommas(directories)));
            writeln(format("    %sVisible Files        : %s",
                branchSymbol(), formatWithCommas(files)));
            writeln(format("    %s*Hidden Dirs/Files   : %s",
                branchSymbol(), formatWithCommas(hiddenFiles)));
            writeln(format("    %sTotal Items(excl.*)  : %s",
                branchSymbol(), formatWithCommas(files + directories)));
            writeln(format("    %sTotal Size           : %.2f GB (%s bytes)",
                branchEndSymbol(), size.to!double / 1_073_741_824.0, formatWithCommas(size)));
            writeln();
        } catch (FormatException e) {
            writeln("Formatting error in printAllStats: ", e.msg);
        }
    }

    void printDefaultStats() {
        try {
            writeln();
            write(format("%s directories, ", formatWithCommas(directories)));
            writeln(format("%s files", formatWithCommas(files)));
        } catch (FormatException e) {
            writeln("Formatting error in printDefaultStats: ", e.msg);
        }
    }

    void printSimpleStats() {
        try {
            writeln();
            write(format("  %s folders, ", formatWithCommas(directories)));
            write(format("%s files, ", formatWithCommas(files)));
            writeln(format("%s hidden folders", formatWithCommas(hiddenFiles)));
            writeln();
        } catch (FormatException e) {
            writeln("Formatting error in printSimpleStats: ", e.msg);
        }
    }

    private string formatWithCommas(T)(T num) {
        import std.string : format;
        string numStr = to!string(num);
        string result;
        size_t len = numStr.length;
        size_t count = 0;

        foreach_reverse (i; 0 .. len) {
            result = numStr[i .. i + 1] ~ result;
            count++;
            if (count % 3 == 0 && i != 0) {
                result = "," ~ result;
            }
        }
        return result;
    }

    private string branchSymbol() {
        return "├── "; // Unicode branch with left turn
    }

    private string branchEndSymbol() {
        return "└── "; // Unicode final branch
    }
}
