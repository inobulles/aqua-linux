# aqua-linux
A nice script that automatically installs all the dependencies necessary for getting an AQUA development environment quickly setup on Linux (Debian).

## Example usage
Here are a few ways you could use `build.sh`.

~~~~
$ sh build.sh update kos devices # update everything, compile the KOS and devices
$ sh build.sh execute # simply execute root/boot.zpk without doing anything else
$ sh build.sh execute code amber # compile, create root/development.zpk, and execute the Amber code in code/
~~~~

## Command-line arguments
Here is a list of command-line arguments that can be passed to build.sh and how to use them.

### kos
Compile the KOS.
Note that the KOS will always be compiled if an executable named `aqua` is not present in the current directory.
The KOS will also always be compiled if any previously missing dependencies have been newly installed.

### devices
Compile all the devices in `devices-source`.
Devices will automatically be compiled on the the same conditions as the KOS.
Note that this option won't work if it's not accompanied by the `kos` option.

### update
Update everything - `git pull` in all the repos.
This will update everything in the extensions too (so the Amber compiler will have its library updated).
This will also force the KOS and devices to be recompiled.

### root
Specify the `--root` option for when executing AQUA.
This takes an argument that defines the root directory.
For more info, run the `aqua` executable with the `--help` option.

### boot
Specify the `--boot` option for when executing AQUA.
This takes an argument that defines where the boot package is.
Note that this is relative to the working directory, not the root directory.
For more info, run the `aqua` executable with the `--help` option.

### execute
Execute the generated `aqua` executable at the end.
This will run the currently set boot file (default is `root/boot.zpk`) or `root/development.zpk` if `code` is also passed.

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
The output will be a package file located at `root/development.apk`, and a ZASM file located at `rom.asm`.

### code-path
Change the path of the code from the default.
This takes an argument that defines the path of the code to be compiled.

### example (needs updating, doesn't work)
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

