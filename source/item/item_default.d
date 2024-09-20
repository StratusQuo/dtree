module item.item_default;

import std.stdio : write, writeln;
import std.file;
import std.path;
import std.string : toStringz;  // Add this import
import walker : WalkDir;
import tree : Tree;
import stat.total : Totals;
import std.exception : enforce;
import color : ColorConfig, colorize;


struct ItemCollector {
    string name;
    string path;
    size_t depth;
    DirEntryType fileType;
    ulong size;

    this(ref DirEntry entry, size_t depth) {
        this.path = entry.name;
        this.name = baseName(this.path);
        this.depth = depth;
        this.fileType = entry.isDir ? DirEntryType.directory : DirEntryType.file;
        this.size = entry.size ? entry.size : 0;
    }

    void getItem(ref WalkDir walkDir, ref ColorConfig colorConfig) {
        try {
            string itemColor = colorConfig.file;

            if (isSymlink(path)) {
                itemColor = colorConfig.symlink;
            } else if (isDir(path)) {
                itemColor = colorConfig.directory;
            } else if (isExecutable(path)) {
                itemColor = colorConfig.executable;
            } else if (isFIFO(path)) {
                itemColor = colorConfig.fifo;
            } else if (isSocket(path)) {
                itemColor = colorConfig.socket;
            } else if (isBlockDevice(path)) {
                itemColor = colorConfig.blockDevice;
            } else if (isCharacterDevice(path)) {
                itemColor = colorConfig.charDevice;
            }

            // Check for special permissions
            if (hasSetUID(path)) {
                itemColor = colorConfig.setuid;
            } else if (hasSetGID(path)) {
                itemColor = colorConfig.setgid;
            } else if (hasSticky(path)) {
                itemColor = colorConfig.sticky;
            } else if (isOtherWritable(path)) {
                itemColor = colorConfig.otherWritable;
            } else if (isStickyOtherWritable(path)) {
                itemColor = colorConfig.stickyOtherWritable;
            }

            write(colorize(name, itemColor, walkDir.config.noAnsi));

            // Show path if enabled
            if (walkDir.config.showPath) {
                write(" --> ", path);
            }

            writeln(); // Newline

            // Update statistics
            if (fileType == DirEntryType.directory) {
                walkDir.total.directories += 1;
            } else {
                walkDir.total.files += 1;
            }

            walkDir.total.size += size;
        } catch (Exception e) {
            writeln("Error collecting item '", name, "': ", e.msg);
        }
    }
}

enum DirEntryType {
    directory,
    file,
}

bool isExecutable(string path) {
    version(Posix) {
        import core.sys.posix.unistd;
        return access(path.toStringz, X_OK) == 0;
    } else {
        // On non-Posix systems, we could check for specific extensions
        // This is a simplistic approach and might need refinement
        import std.string : toLower, endsWith;
        return path.toLower.endsWith(".exe", ".bat", ".cmd");
    }
}

bool isSymlink(string path) {
    return std.file.isSymlink(path);
}

bool isDir(string path) {
    return std.file.isDir(path);
}

bool isFIFO(string path) {
    version(Posix) {
        import core.sys.posix.sys.stat;
        stat_t statbuf;
        return stat(path.toStringz, &statbuf) == 0 && S_ISFIFO(statbuf.st_mode);
    } else {
        return false; // FIFOs are not typically found on non-Posix systems
    }
}

bool isSocket(string path) {
    version(Posix) {
        import core.sys.posix.sys.stat;
        stat_t statbuf;
        return stat(path.toStringz, &statbuf) == 0 && S_ISSOCK(statbuf.st_mode);
    } else {
        return false; // Sockets are not typically found as files on non-Posix systems
    }
}

bool isBlockDevice(string path) {
    version(Posix) {
        import core.sys.posix.sys.stat;
        stat_t statbuf;
        return stat(path.toStringz, &statbuf) == 0 && S_ISBLK(statbuf.st_mode);
    } else {
        return false; // Block devices are not typically found on non-Posix systems
    }
}

bool isCharacterDevice(string path) {
    version(Posix) {
        import core.sys.posix.sys.stat;
        stat_t statbuf;
        return stat(path.toStringz, &statbuf) == 0 && S_ISCHR(statbuf.st_mode);
    } else {
        return false; // Character devices are not typically found on non-Posix systems
    }
}

bool hasSetUID(string path) {
    version(Posix) {
        import core.sys.posix.sys.stat;
        stat_t statbuf;
        return stat(path.toStringz, &statbuf) == 0 && (statbuf.st_mode & S_ISUID);
    } else {
        return false; // SetUID is not typically used on non-Posix systems
    }
}

bool hasSetGID(string path) {
    version(Posix) {
        import core.sys.posix.sys.stat;
        stat_t statbuf;
        return stat(path.toStringz, &statbuf) == 0 && (statbuf.st_mode & S_ISGID);
    } else {
        return false; // SetGID is not typically used on non-Posix systems
    }
}

bool hasSticky(string path) {
    version(Posix) {
        import core.sys.posix.sys.stat;
        stat_t statbuf;
        return stat(path.toStringz, &statbuf) == 0 && (statbuf.st_mode & S_ISVTX);
    } else {
        return false; // Sticky bit is not typically used on non-Posix systems
    }
}

bool isOtherWritable(string path) {
    version(Posix) {
        import core.sys.posix.sys.stat;
        stat_t statbuf;
        return stat(path.toStringz, &statbuf) == 0 && (statbuf.st_mode & S_IWOTH);
    } else {
        // On Windows, we miiiight want to check if the file is writable by everyone...
        // ! Simplistic approach -- might need refinement
        return (getAttributes(path) & 2) != 0;
    }
}

bool isStickyOtherWritable(string path) {
    version(Posix) {
        import core.sys.posix.sys.stat;
        stat_t statbuf;
        return stat(path.toStringz, &statbuf) == 0 && (statbuf.st_mode & S_ISVTX) && (statbuf.st_mode & S_IWOTH);
    } else {
        return false; // This combination is not typically used on non-Posix systems
    }
}