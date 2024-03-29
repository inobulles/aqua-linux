
#!/bin/sh
set -e 
 
echo "AQUA Linux builder"
echo "Parsing arguments ..."

kos=""
devices=""
update=""
execute=""
broadcom=""
root="root"
boot="$root/boot.zpk"
msaa="0"
vsync="1"
width="800"
height="480"
code=""
code_path="code"
#~ example=""
git_prefix="https://github.com"

while test $# -gt 0; do
	if   [ "$1" = "kos"       ]; then kos="kos"
	elif [ "$1" = "devices"   ]; then devices="devices"
	elif [ "$1" = "update"    ]; then update="update"
	elif [ "$1" = "execute"   ]; then execute="execute"
	elif [ "$1" = "broadcom"  ]; then broadcom="broadcom"
	elif [ "$1" = "no-vsync"  ]; then vsync="0"
	elif [ "$1" = "root"      ]; then root="$2";      shift
	elif [ "$1" = "boot"      ]; then boot="$2";      shift
	elif [ "$1" = "msaa"      ]; then msaa="$2";      shift
	elif [ "$1" = "width"     ]; then width="$2";     shift
	elif [ "$1" = "height"    ]; then height="$2";    shift
	elif [ "$1" = "code"      ]; then code="$2";      shift
	elif [ "$1" = "code-path" ]; then code_path="$2"; shift
	#~ elif [ "$1" = "example"   ]; then example="$2";   shift
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
if [ "`command -v iar`" = "" ]; then
	echo "Installing IAR command line utility ..."
	git clone $git_prefix/inobulles/iar --depth 1 -b master
	( cd iar
	sh build.sh )
	rm -rf iar
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
ld -lGL >/dev/null 2>&1 || {
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

( if [ ! -d "kos" ]; then
	git clone $git_prefix/inobulles/aqua-kos --depth 1 -b master
	mv aqua-kos kos
fi

if [ ! -d "kos/zvm" ]; then
	git clone $git_prefix/inobulles/aqua-zvm --depth 1 -b master
	mv aqua-zvm kos/zvm
fi ) &

( if [ ! -d "$root" ]; then
	git clone $git_prefix/inobulles/aqua-root --depth 1 -b master
	mv aqua-root $root
fi ) &

( if [ ! -d "devices-source" ]; then
	git clone $git_prefix/inobulles/aqua-devices --depth 1 -b master
	mv aqua-devices devices-source
fi ) &

( if [ "$code" != "" ] && [ ! -d "compiler" ]; then
	echo "Installing compiler extension ..."
	git clone $git_prefix/inobulles/aqua-compiler --depth 1 -b master
	mv aqua-compiler compiler
fi ) &

wait

if [ "$update" = "update" ]; then
	echo "Updating components ..."
	
	( cd kos
	git pull origin master ) &
	
	( cd kos/zvm
	git pull origin master ) &
	
	( cd $root
	git pull origin master ) &
	
	( cd devices-source
	git pull origin master ) &
	
	( if [ "$code" != "" ]; then
		cd compiler
		git pull origin master
	fi ) &
	
	wait
fi

#~ if [ "$example" != "" ]; then
	#~ if [ ! -d "examples" ]; then
		#~ echo "Downloading examples repository ..."
		#~ git clone $git_prefix/inobulles/aqua-examples --depth 1 -b master
		#~ mv aqua-examples examples
	#~ elif [ "$update" = "update" ]; then
		#~ echo "Updating examples repository ..."
		#~ cd examples
		#~ git pull origin master
		#~ cd ..
	#~ fi
#~ fi

if [ "$code" != "" ]; then
	rm -rf compiler/code
	mkdir -p compiler/code
	
	#~ if [ "$example" != "" ]; then
		#~ echo "Copying example code to compiler ..."
		#~ cp -r examples/$example/* compiler/code
	#~ else
		echo "Copying code to compiler ..."
		cp -r $code_path/* compiler/code
	#~ fi
	
	echo "Compiling code with universal compiler ..."
	( cd compiler
	sh build.sh git-prefix $git_prefix $update code $code )
	
	mv compiler/rom.asm rom.asm
	mv compiler/package.zpk $root/development.zpk
	boot="$root/development.zpk"
	
	#~ if [ "$example" != "" ]; then
		#~ echo "Copying generated ROM file to example folder ..."
		#~ cp rom.zed examples/$example/rom.zed
	#~ fi
#~ else
	#~ if [ "$example" != "" ]; then
		#~ echo "Getting example ROM to execute ..."
		#~ cp examples/$example/rom.zed rom.zed
	#~ fi
fi

if [ ! -f "aqua" ] || [ "$update" = "update" ] || [ "$kos" = "kos" ]; then
	echo "Compiling KOS ..."
	
	gcc_flags=""
	
	if [ "$broadcom" = "broadcom" ]; then
		echo "Compiling for Broadcom ..."
		gcc_flags="-DKOS_PLATFORM=KOS_PLATFORM_BROADCOM -Wno-int-to-pointer-cast -Wno-pointer-to-int-cast -L/opt/vc/lib/ -lbrcmGLESv2 -lbrcmEGL -lopenmaxil -lbcm_host -lvcos -lvchiq_arm -lilclient -L/opt/vc/src/hello_pi/libs/ilclient -I/opt/vc/include/ -I/opt/vc/include/interface/vcos/pthreads -I/opt/vc/include/interface/vmcs_host/linux -I./ -I/src/libs/ilclient"
		# -DSTANDALONE -D__STDC_CONSTANT_MACROS -D__STDC_LIMIT_MACROS -DTARGET_POSIX -D_LINUX -fPIC -DPIC -D_REENTRANT -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -U_FORTIFY_SOURCE -DHAVE_LIBOPENMAX=2 -DOMX -DOMX_SKIP64BIT -ftree-vectorize -DUSE_EXTERNAL_OMX -DHAVE_LIBBCM_HOST -DUSE_EXTERNAL_LIBBCM_HOST -DUSE_VCHIQ_ARM -Wno-psabi
	else
		echo "Compiling for Desktop ..."
		gcc_flags="-DKOS_PLATFORM=KOS_PLATFORM_DESKTOP -lSDL2 -lGL"
	fi
	
	rm -f aqua
	gcc kos/glue.c -o aqua -std=gnu99 -no-pie -ldl $gcc_flags \
		-DKOS_DEVICES_PATH=\"devices/\" -DKOS_VSYNC=$vsync -DKOS_VIDEO_WIDTH=$width -DKOS_VIDEO_HEIGHT=$height -DKOS_MSAA=$msaa &
fi

if [ ! -d "devices" ] || [ "$update" = "update" ] || [ "$devices" = "devices" ]; then
	echo "Compiling devices ..."
	
	rm -rf devices
	mkdir -p devices
	
	( cd devices-source
	for path in `find . -maxdepth 1 -type d -not -name "*git*" | tail -n +2`; do
		(
			echo "Compiling $path device ..."
			cd $path
			sh build.sh $gcc_flags
			mv device ../../devices/$path
		) &
	done )
fi

wait # wait for everything to finish compiling

if [ "$execute" = "execute" ]; then
	echo "Executing KOS ..."
	./aqua --root $root --boot $boot
fi

echo "AQUA Linux builder terminated with no errors"
exit 0
