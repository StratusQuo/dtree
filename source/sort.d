module sort;

import mir.ndslice.sorting : sort;
import mir.functional : naryFun;
import mir.algorithm.iteration : cmp;

import std.path : extension, baseName;
import std.string : toLower;
import std.file : DirEntry, timeLastModified;
import std.conv : to;
// import std.algorithm.comparison : cmp;

enum SortType {
    caseInsensitive,
    caseSensitive,
    none,
    extension,
    size,
    time,
    version_
}

void sortEntries(ref DirEntry[] entries, SortType sortType) {
    final switch (sortType) {
        case SortType.caseInsensitive:
            sort!((a, b) => toLower(a.name) < toLower(b.name))(entries);
            break;
        case SortType.caseSensitive:
            sort!((a, b) => a.name < b.name)(entries);
            break;
        case SortType.extension:
            sort!((a, b) => extension(a.name) == extension(b.name) ? baseName(a.name) < baseName(b.name) : extension(a.name) < extension(b.name))(entries);
            break;
        case SortType.size:
            sort!((a, b) => a.size < b.size)(entries);
            break;
        case SortType.time:
            sort!((a, b) => a.timeLastModified < b.timeLastModified)(entries);
            break;
        case SortType.version_:
            sort!((a, b) => compareVersions(a, b) < 0)(entries);
            break;
        case SortType.none:
            // Do nothing
            break;
    }
}

int compareVersions(DirEntry a, DirEntry b) {
    import std.regex : regex, matchAll;
    import std.conv : to;

    auto versionRegex = regex(r"\d+");
    auto matchesA = matchAll(a.name, versionRegex);
    auto matchesB = matchAll(b.name, versionRegex);

    while (!matchesA.empty && !matchesB.empty) {
        int numA = matchesA.front.hit.to!int;
        int numB = matchesB.front.hit.to!int;
        if (numA != numB) return numA - numB;
        matchesA.popFront();
        matchesB.popFront();
    }

    return matchesA.empty && matchesB.empty ? 0 : (matchesA.empty ? -1 : 1);
}