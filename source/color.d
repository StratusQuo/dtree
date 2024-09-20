module color;

struct ColorConfig {
    string directory = "\033[1;34m"; // Blue
    string file = "\033[0m"; // Default color
    string executable = "\033[1;32m"; // Green
    string symlink = "\033[1;36m"; // Cyan
    string fifo = "\033[33m"; // Yellow
    string socket = "\033[1;35m"; // Magenta
    string blockDevice = "\033[1;33m"; // Yellow (bold)
    string charDevice = "\033[1;33m"; // Yellow (bold)
    string setuid = "\033[37;41m"; // White on red background
    string setgid = "\033[30;43m"; // Black on yellow background
    string sticky = "\033[37;44m"; // White on blue background
    string otherWritable = "\033[34;42m"; // Blue on green background
    string stickyOtherWritable = "\033[30;42m"; // Black on green background
    string reset = "\033[0m";
}

ColorConfig defaultColorConfig;

string colorize(string text, string color, bool noAnsi) {
    return noAnsi ? text : color ~ text ~ defaultColorConfig.reset;
}