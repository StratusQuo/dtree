module app;

import numem.all;

import std.stdio;
import std.datetime.stopwatch : StopWatch;
import flag;
import walker;
import tree;
import item.item_default;
import stat.head;
import stat.total;
import color : ColorConfig, defaultColorConfig;  // Import defaultColorConfig

void main(string[] args) {
    // Initialize flags
    Flag flag = parseFlags(args);

    // Start timer
    StopWatch sw;
    sw.start();

    // Initialize total stats
    Totals total;

    // Set up tree configuration
    Config config = Config([], 0);

    // Initialize tree with the useAscii flag
    Tree tree = Tree(config, flag.useAscii);

    // Initialize header
    HeaderConfig headerConfig = HeaderConfig(flag.layoutType, flag.noAnsi);
    Header header = Header(headerConfig, flag.targetDir);
    //header.printHeader();

	// Print a newline before starting the output
	writeln();

	// Print the header
	header.printHeader();

    // Create ColorConfig
    ColorConfig colorConfig = defaultColorConfig;  // Use the default color configuration

    // Create WalkDir instance
    WalkDirConfig walkDirConfig = WalkDirConfig(
        flag.sortType,
        flag.showHiddenFiles,
        flag.depthLimit,
        flag.showPath,
        flag.noAnsi,
        flag.showFullPath
    );
    WalkDir walkDir = WalkDir(&tree, flag.targetDir, &total, walkDirConfig, &colorConfig);

    // Start walking
    walk(walkDir);

    // Stop timer
    sw.stop();

    // Print stats based on layout type
    double elapsedSeconds = sw.peek().total!"msecs" / 1000.0;
    if (flag.layoutType == LayoutType.all) {
        total.printAllStats(elapsedSeconds);
    } else if (flag.layoutType == LayoutType.defaultLayout) {
        total.printDefaultStats();
    } else {
        total.printSimpleStats();
    }
}