# DTree

This is a port of the classic Unix `tree` utility to the D programming language.  

Just like the original, it displays directories and files in a tree-like structure, making it easy to visualize the layout of your file system. 

#### Example:

```
dtree
├── dub.json
├── dub.selections.json
├── source
│   ├── app.d
│   ├── color.d
│   ├── flag.d
│   ├── item
│   │   ├── all.d
│   │   └── item_default.d
│   ├── sort.d
│   ├── tree.d
│   └── walker.d
└── stat
    ├── head.d
    └── total.d

  4 folders, 12 files, 0 hidden folders
```

## Why D?

The original `tree` is written in C and has been around for *quite* some time -- this project aims to explore what can be achieved in D by recreating this tool and extending it a bit.

#### Some planned features:

- **Additional Styling**: More colors, styles, and themes for different types of filesystem objects.
- **Analytics**: More in depth information about folders and files
- **Permissions**: Ideally an intuitive way to view all permissions will be implemented too.
- **Symlink Handling**: Currently this is unimplemented -- as I'm still trying to decide how to best handle this.



## Features
- **Basic directory tree listing**: The core functionality of displaying directories and files in a hierarchical tree structure is implemented.
* **Color Support:** Directory names, executables, & symlinks are all rendered in color, making it a bit easier to reason about a directory.
- **Hidden Files**: Show or hide files and directories using the `--hidden-file` option 
- **Depth limiting**: Use the `-L` option to limit the levels of tree output.
* **Cross-Platform Potential:** D can be compiled for various platforms, opening up the possibility for a cross-platform `tree` implementation.

## Status

This project is currently under development and may not yet have all the features and stability of the original `tree`. Contributions and bug reports are welcome!

## Building

To build `tree-d`, you will need a D compiler (e.g., DMD, LDC, or GDC).  

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/tree-d.git
   cd tree-d
   ```

2. Compile the Project _(LDC Preferred)_:

```
dub build --build=release --compiler=ldc2
```

## Usage

Basic usage is the same as the original tree:

```
dtree [directory]
```

If no directory is specified, it will default to the current directory.


## Contributing
Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.


## License
This project is licensed under the MIT License.
