# aqua-linux
A nice script that automatically installs all the dependencies necessary for getting an AQUA development environment quickly setup on Linux (Debian).

## Example usage
Here are a few ways you could use `build.sh`.

~~~~
$ sh build.sh update kos execute example avanced/quote-of-the-day # update everything, compile the KOS, use the advanced/quote-of-the-day example's ROM file to execute at the end
$ sh build.sh execute # simply execute rom.zed without doing anything else
$ sh build.sh execute code amber # compile and execute the Amber code in code/
~~~~

## Command-line arguments
Here is a list of command-line arguments that can be passed to build.sh and how to use them.

### kos
Compile the KOS and all the devices in `devices-source`.
Note that the KOS will always be compiled if an executable named `aqua` is not present in the current directory.
The KOS will also always be compiled if any previously missing dependencies have been newly installed.

### update
Update everything - `git pull` in all the repos.
This will update everything in the extensions too (so the Amber compiler will have its library updated).

### execute
Execute the generated `aqua` executable at the end.
This will run the `rom.zed` ROM if it exists, else it'll unpack `package.zpk` and run it.

### package
Generate a ZED package file `package.zpk` with the `rom.zed` file and the `perm` resources in `root/perm/development`.

### no-vsync
Compile the KOS with the `KOS_VSYNC` flag set to 0.
Note that this only works when the KOS is compiled too (so the `kos` flag is also needed).

### width
Compile the KOS with a certain video width.
This takes an argument that defines the value of the width of the screen to compile the KOS with.
Note that this only works when the KOS is compiled too (so the `kos` flag is also needed).

### height
Same as width, but for video height.

### msaax
Set the multisampling amount in the KOS to the following argument.
Note that this may not work with all KOS's, and some may not support some values.

### code
Compile the code contained in `code/` (or the path defined by the `code-path` argument).
This takes an argument that defines what language to use. `amber` and `asm` are both valid options.
Amber code can have multiple files, as long as there is a root `main.a` file. Assembly code can only be one file, named `main.asm`.
The output will be a ZED ROM file located at `rom.zed`, and a ZASM file located at `rom.asm`.

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

