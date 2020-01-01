
#!/bin/sh
set -e 
 
echo "AQUA Linux builder"
echo "Parsing arguments ..."

kos=""
update=""
execute=""
package=""
msaa="0"
vsync="1"
width="800"
height="480"
code=""
code_path="code"
example=""
git_prefix="https://github.com"

while test $# -gt 0; do
	if   [ "$1" = "kos"       ]; then kos="kos"
	elif [ "$1" = "update"    ]; then update="update"
	elif [ "$1" = "execute"   ]; then execute="execute"
	elif [ "$1" = "package"   ]; then package="package"
	elif [ "$1" = "no-vsync"  ]; then vsync="0"
	elif [ "$1" = "msaax"     ]; then msaa="$2";      shift
	elif [ "$1" = "width"     ]; then width="$2";     shift
	elif [ "$1" = "height"    ]; then height="$2";    shift
	elif [ "$1" = "code"      ]; then code="$2";      shift
	elif [ "$1" = "code-path" ]; then code_path="$2"; shift
	elif [ "$1" = "example"   ]; then example="$2";   shift
	elif [ "$1" = "git-ssh"   ]; then git_prefix="ssh://git@github.com"
	elif [ "$1" = "help"      ]; then cat README.md
	else echo "WARNING Unknown argument '$1' (pass 'help' as an argument to get a list of all arguments)";
	fi
	
	shift
done

echo "Creating code directory ..."
mkdir -p code

echo "Installing potential missing dependencies ..."
set +e

if [ "`command -v gcc`" = "" ] || [ "`command -v g++`" = "" ]; then
	echo "Installing GCC and G++ ..."
	
	if [ "`command -v apt`" != "" ]; then
		sudo apt-get install -y gcc
		sudo apt-get install -y g++
	elif [ "`command -v yum`" != "" ]; then
		sudo yum install -y gcc
		sudo yum install -y gcc-c++
	else
		echo "WARNING Platform not supported for installing GCC"
		exit 1
	fi
fi
if [ "`command -v git`" = "" ]; then
	echo "Installing Git ..."
	
	if [ "`command -v apt`" != "" ]; then
		sudo apt-get install -y git
	elif [ "`command -v yum`" != "" ]; then
		sudo yum install -y git
	else
		rm -rf install-dump
		mkdir -p install-dump
		cd install-dump
		
		wget https://github.com/git/git/archive/v2.17.1.tar.gz
		tar -xzvf v2.17.1.tar.gz
		cd git-2.17.1
		
		make configure
		./configure --prefix=/usr
		make all
		sudo make install
		
		cd ../..
		rm -rf install-dump
	fi
fi
ld -lSDL2 >/dev/null 2>&1 || {
	echo "Installing SDL2 ..."
	
	if [ "`command -v apt`" != "" ]; then
		sudo apt-get install -y libsdl2-2.0-0
		sudo apt-get install -y libsdl2-dev
	elif [ "`command -v `yum" != "" ]; then
		sudo yum install -y SDL2-devel
	else
		rm -rf install-dump
		mkdir -p install-dump
		cd install-dump
		
		git clone https://github.com/spurious/SDL-mirror
		cd SDL-mirror
		mkdir -p build
		cd build
		
		../configure
		make all
		sudo make install
		
		cd ../../..
		rm -rf install-dump
	fi
}
ld -lGL -lGLU >/dev/null 2>&1 || {
	echo "Installing MESA (GL) ..."
	
	if [ "`command -v apt`" != "" ]; then
		sudo add-apt-repository -y ppa:ubuntu-x-swat/updates
		sudo apt-get -y update
		sudo apt-get -y dist-upgrade
	elif [ "`command -v yum`" != "" ]; then
		sudo yum install -y mesa-libGL
		sudo yum install -y mesa-libGL-devel
	else
		echo "WARNING Platform not supported for installing the MESA library" 
		exit 1
	fi
}

rm a.out

set -e
echo "Downloading potential missing components ..."

if [ ! -d "kos" ]; then
	git clone $git_prefix/inobulles/aqua-kos --depth 1 -b master
	mv aqua-kos kos
fi

if [ ! -d "kos/zvm" ]; then
	git clone $git_prefix/inobulles/aqua-zvm --depth 1 -b master
	mv aqua-zvm kos/zvm
fi

if [ ! -d "root" ]; then
	git clone $git_prefix/inobulles/aqua-root --depth 1 -b master
	mv aqua-root root
fi

if [ ! -d "devices-source" ]; then
	git clone $git_prefix/inobulles/aqua-devices --depth 1 -b master
	mv aqua-devices devices-source
fi

if [ "$update" = "update" ]; then
	echo "Updating components ..."
	
	cd kos
	git pull origin master
	cd zvm
	git pull origin master
	cd ../../root
	git pull origin master
	cd ../devices-source
	git pull origin master
	cd  ..
fi

if [ "$example" != "" ]; then
	if [ ! -d "examples" ]; then
		echo "Downloading examples repository ..."
		git clone $git_prefix/inobulles/aqua-examples --depth 1 -b master
		mv aqua-examples examples
	elif [ "$update" = "update" ]; then
		echo "Updating examples repository ..."
		cd examples
		git pull origin master
		cd ..
	fi
fi

if [ "$code" != "" ]; then
	if [ ! -d "compiler" ]; then
		echo "Installing compiler extension ..."
		git clone $git_prefix/inobulles/aqua-compiler --depth 1 -b master
		mv aqua-compiler compiler
	fi
	
	if [ "$update" = "update" ]; then
		echo "Updating compiler extension ..."
		cd compiler
		git pull origin master
		cd ..
	fi
	
	rm -rf compiler/code
	mkdir -p compiler/code
	
	if [ "$example" != "" ]; then
		echo "Copying example code to compiler ..."
		cp -r examples/$example/* compiler/code
	else
		echo "Copying code to compiler ..."
		cp -r $code_path/* compiler/code
	fi
	
	if [ -d "compiler/code/perm" ]; then
		echo "Moving perm/ from compiler to root/perm/development/ ..."
		rm -rf root/perm/development
        mkdir -p root/perm
		mkdir -p root/perm/development
		mv compiler/code/perm/* root/perm/development
	fi
	
	echo "Compiling code with universal compiler ..."
	cd compiler
	sh build.sh git-prefix $git_prefix $update code $code
	cd ..
	
	mv compiler/rom.zed rom.zed
	mv compiler/rom.asm rom.asm
	
	if [ "$example" != "" ]; then
		echo "Copying generated ROM file to example folder ..."
		cp rom.zed examples/$example/rom.zed
	fi
else
	if [ "$example" != "" ]; then
		echo "Getting example ROM to execute ..."
		cp examples/$example/rom.zed rom.zed
	fi
fi

if [ ! -f "aqua" ] || [ "$update" = "update" ] || [ "$kos" = "kos" ]; then
	echo "Compiling devices ..."
	
	rm -rf devices
	mkdir -p devices
	
	(
		cd devices-source
		for path in `find . -maxdepth 1 -type d -not -name "*git*" | tail -n +2`; do
			(
				echo "Compiling $path device ..."
				cd $path
				sh build.sh
				mv device ../../devices/$path
			) & # compiling in parallel!
		done
		wait
	)
	
	echo "Compiling KOS ..."
	
	rm -f aqua
	gcc kos/glue.c -o aqua -std=gnu99 -Wall -no-pie \
		-DKOS_PLATFORM=KOS_PLATFORM_DESKTOP -DKOS_DEVICES_PATH=\"devices/\" -DKOS_VSYNC=$vsync -DKOS_VIDEO_WIDTH=$width -DKOS_VIDEO_HEIGHT=$height -DKOS_MSAA=$msaa \
		-Wno-parentheses -Wno-maybe-uninitialized -Wno-unused-result -Wno-unused-variable -Wno-unused-but-set-variable -Wno-main \
		-lSDL2 -lGL -ldl
fi

if [ "$package" = "package" ]; then
	echo "Packaging app ..."
	mkdir package
	cp rom.zed package/rom.zed
	mkdir -p package/perm
	cp -r root/perm/development/* package/perm/
	tar -cf package.zpk package
	rm -rf package
fi

if [ "$execute" = "execute" ]; then
	if [ ! -f "rom.zed" ]; then
		echo "ROM file does not exist, unpacking package.zpk ..."
		tar -xf package.zpk
		mv package/rom.zed rom.zed
		
		rm -rf root/perm/development/*
		mkdir -p root/perm
		mkdir -p root/perm/development
		mv package/perm/* root/perm/development/
		
		rm -rf package
	fi
	
	echo "Executing KOS ..."
	./aqua
fi

echo "AQUA Linux builder terminated with no errors"
exit 0
