# Wolfram Language Runtime (SDK) demo in Zig

A demo of the new [Wolfram Language Runtime](https://writings.stephenwolfram.com/2024/07/yet-more-new-ideas-and-new-functions-launching-version-14-1-of-wolfram-language-mathematica/#standalone-wolfram-language-applications) written in [Zig](https://ziglang.org).

I wrote a Wolfram community post expanding on the details [Wolfram Language Runtime (SDK) demo in Zig](https://community.wolfram.com/groups/-/m/t/3252532).

## Demo

We will create two standalone executables that run the [Transliterate](https://reference.wolfram.com/language/ref/Transliterate.html) function from Wolfram Language.
The executables are written in C and Zig.

### Build

The `zig build` command will build both the C and the Zig executables:
```shell
$ zig build --summary all
Build Summary: 5/5 steps succeeded
install success
├─ install transliterate-zig success
│  └─ zig build-exe transliterate-zig Debug native cached 45ms MaxRSS:36M
└─ install transliterate-c success
   └─ zig build-exe transliterate-c Debug native cached 45ms MaxRSS:36M
```

By default, the executables are stored in `zig-out/bin`:
```shell
$ ls zig-out/bin                                                                                                                                                   ─╯
transliterate-c   transliterate-zig
```

### C

Now that the executable is compiled, see the usage:
```shell
$ ./zig-out/bin/transliterate-c
Usage: ./transliterate-c "input"
```

Use the executable:
```shell
$ ./zig-out/bin/transliterate-c 'しんばし'
shinbashi
```

### Zig

Instead of specifying where the C header library is (see [build.zig](./build.zig)), we are using a handwritten Zig package: [WolframLanguageRuntime.zig](./src/WolframLanguageRuntime.zig).

Now that the executable is compiled, see the usage:
```shell
$ ./zig-out/bin/transliterate-zig
Usage: ./transliterate-zig "input"
```

Use the executable:
```shell
$ ./zig-out/bin/transliterate-zig 'しんばし'
shinbashi
```

## Prerequisites

### Architecture

Tested on:
```shell
$ uname -a
Darwin mac.lan 24.2.0 Darwin Kernel Version 24.2.0: Fri Dec  6 19:03:40 PST 2024; root:xnu-11215.61.5~2/RELEASE_ARM64_T6041 arm64
```

### Wolfram Language version

Tested on:
```Mathematica
In[]:= $Version
Out[]= "14.3.0 for Mac OS X ARM (64-bit) (March 26, 2025)"
```

### Zig version

Tested on:
```shell
$ zig version
0.14.0
```

Zig is not on version [1.0](https://github.com/ziglang/zig/milestone/2).
The language is in constant development and some things might break in the future.

## References

- [Yet More New Ideas and New Functions: Launching Version 14.1 of Wolfram Language & Mathematica - Standalone Wolfram Language Applications!](https://writings.stephenwolfram.com/2024/07/yet-more-new-ideas-and-new-functions-launching-version-14-1-of-wolfram-language-mathematica/#standalone-wolfram-language-applications)
- [Zig Language Reference](https://ziglang.org/documentation/)
- [Zig Standard Library](https://ziglang.org/documentation/master/std/)
- [Expression API rough documentation](http://files.wolfram.com/temp-store/ccooley/june/apidefinition_8h.html)
