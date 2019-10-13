# aqua-linux
A nice script that automatically installs all the dependencies necessary for getting an AQUA development environment quickly setup on Linux (Debian).

## Example usage
Here are a few ways you could use `build.sh`.

~~~~
$ sh build.sh update kos execute example avanced/quote-of-the-day # update everything, compile the KOS, use the advanced/quote-of-the-day example's ROM file to execute at the end
$ sh build.sh execute # simply execute rom.zed without doing anything else
$ sh build.sh execute code c # compile and execute the C code in code/
~~~~

## Command-line arguments
Here is a list of command-line arguments that can be passed to build.sh and how to use them.

### kos
Compile the KOS.
Note that the KOS will always be compiled if an executable named `aqua` is not present in the current directory.
The KOS will also always be compiled if any previously missing dependencies have been newly installed.

### update
Update everything - `git pull` in all the repos.
This will update everything in the extensions too (so C compiler will have its library updated).

### execute
Execute the generated `aqua` executable at the end.

### vsync
Compile the KOS with the `KOS_ENABLE_VSYNC` flag set.
Note that this only works when the KOS is compiled too (so the `kos` flag is also needed).

### code
Compile the code contained in `code/` (or the path defined by the `code-path` argument).
This takes an argument that defines what language to use. `c` and `asm` are both valid options.
C code can have multiple files, as long as there is a root `main.c` file. Assembly code can only be one file, named `main.asm`.

### code-path
Change the path of the code from the default.
This takes an argument that defines the path of the code to be compiled.

### example
Download and run an example from `inobulles/aqua-examples`.
This takes an argument that defines the name of the example to use.
If run with the `code` argument, this will compile from source.
Else, it will use the `rom.zed` file contained in the example folder as a ROM.
Note that the `code` argument still needs its language argument, if compiling from source.
Also note that the newly compiled `rom.zed` file will be placed back in the example directory if run with the `code` argument.

### git-ssh
Use SSH link as origin for cloning git repos.
Note that this argument will be completely useless for 99% of people, so no point in using it if you don't understand it.

### help
Print out the contents of the `README.md` (this) file.

