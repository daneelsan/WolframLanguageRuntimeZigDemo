# Wolfram Language Runtime (SDK) demo in Zig

A demo of the new [Wolfram Language Runtime](https://writings.stephenwolfram.com/2024/07/yet-more-new-ideas-and-new-functions-launching-version-14-1-of-wolfram-language-mathematica/#standalone-wolfram-language-applications) written in [Zig](https://ziglang.org).

I wrote a Wolfram community post expanding on the details [Wolfram Language Runtime (SDK) demo in Zig](https://community.wolfram.com/groups/-/m/t/3252532).

## Demo

We will create a standalone executable that runs the [Transliterate](https://reference.wolfram.com/language/ref/Transliterate.html) function from Wolfram Language.

### C

```shell
$ zig cc main.c -o transliterate-c \
	-L"/Applications/Wolfram.app/Contents/SystemFiles/Components/StandaloneApplicationsSDK/MacOSX-x86-64/" \
	-I"/Applications/Wolfram.app/Contents/SystemFiles/Components/StandaloneApplicationsSDK/MacOSX-x86-64/" \
	-lstdc++ \
	-lStandaloneApplicationsSDK \
	-target x86_64-macos
```

Notice that even tough I'm compiling in ARM64 (see the section [Prerequisites](#prerequisites)), I'm targeting the `x86_64-macos` architecture.
This is because there is a bug in the current MacOSX-ARM64 `StandaloneApplicationsSDK` library; though should be fixed soon.
The executable will still be able to run because of Rosetta.

Now that the executable is compiled, see the usage:
```shell
$ ./transliterate-c
Usage: ./transliterate-c "input"
```

Use the executable:
```shell
$ ./transliterate-c 'しんばし'
shinbashi
```

### Zig

```shell
$ zig build-exe main.zig --name transliterate-zig \
	-L"/Applications/Wolfram.app/Contents/SystemFiles/Components/StandaloneApplicationsSDK/MacOSX-x86-64/" \
	-lStandaloneApplicationsSDK \
	-lc++ \
	-target x86_64-macos
```
Again, notice we are targeting `x86_64-macos` (as explained in the section above).

Instead of specifying where the header library is (as is the case for the C demo), we are using our handwritten Zig package: [wlr.zig](./wlr.zig).

Now that the executable is compiled, see the usage:
```shell
$ ./transliterate-zig
Usage: ./transliterate-zig "input"
```

Use the executable:
```shell
$ ./transliterate-zig 'しんばし'
shinbashi
```

## Prerequisites

### Architecture

Tested on:
```shell
$ uname -a
Darwin m6502.local 23.5.0 Darwin Kernel Version 23.5.0: Wed May  1 20:12:58 PDT 2024; root:xnu-10063.121.3~5/RELEASE_ARM64_T6000 arm64
```

### Wolfram Language version

Tested on:
```Mathematica
In[]:= $Version
Out[]= "14.1.0 for Mac OS X ARM (64-bit) (July 16, 2024)"
```

Another thing to make sure is to rename the SDK library found in `"/Applications/Wolfram.app/Contents/SystemFiles/Components/StandaloneApplicationsSDK/MacOSX-x86-64/"` to have the `lib` prefix (libraries are expected to have them in Unix-like systems).
Otherwise, `zig cc` and `zig build-exe` won't be able to find the library with `-lStandaloneApplicationsSDK`.
```shell
$ mv /Applications/Wolfram.app/Contents/SystemFiles/Components/StandaloneApplicationsSDK/MacOSX-x86-64/StandaloneApplicationsSDK.a /Applications/Wolfram.app/Contents/SystemFiles/Components/StandaloneApplicationsSDK/MacOSX-x86-64/libStandaloneApplicationsSDK.a
```

### Zig version

Tested on:
```shell
$ zig version
0.14.0-dev.823+624fa8523
```

Zig is not on version [1.0](https://github.com/ziglang/zig/milestone/2).
The language is in constant development and some things might break in the future.

## References

- [Yet More New Ideas and New Functions: Launching Version 14.1 of Wolfram Language & Mathematica - Standalone Wolfram Language Applications!](https://writings.stephenwolfram.com/2024/07/yet-more-new-ideas-and-new-functions-launching-version-14-1-of-wolfram-language-mathematica/#standalone-wolfram-language-applications)
- [Zig Language Reference](https://ziglang.org/documentation/)
- [Zig Standard Library](https://ziglang.org/documentation/master/std/)
