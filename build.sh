
#!/bin/sh
set -e;

echo "AQUA Linux builder"
echo "Parsing arguments ..."

kos=""
update=""
execute=""
code=""
code_path="code"
example=""
git_prefix="https://github.com"

while test $# -gt 0; do
	if   [ "$1" = "kos"       ]; then kos="kos"
	elif [ "$1" = "update"    ]; then update="update"
	elif [ "$1" = "execute"   ]; then execute="execute"
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
ld -lcurl >/dev/null 2>&1 || {
	echo "Installing CURL ..."
	
	if [ "`command -v apt`" != "" ]; then
		sudo apt-get install -y libcurl4-openssl-dev
	elif [ "`command -v yum`" != "" ]; then
		sudo yum install -y libcurl-devel
	else
		rm -rf install-dump
		mkdir -p install-dump
		cd install-dump
		
		wget https://curl.haxx.se/download/curl-7.65.3.tar.gz
		tar -xvf curl-7.65.3.tar.gz
		cd curl-7.65.3.tar.gz
		
		./configure --with-ssl
		make
		sudo make install
		
		cd ../..
		rm -rf install-dump
	fi
}
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
	echo "Installing MESA (GL and GLU) ..."
	
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
ld -lmad >/dev/null 2>&1 || {
	echo "Installing MAD ..."
	
	if [ "`command -v apt`" != "" ]; then
		sudo apt-get install -y libmad0
		sudo apt-get install -y libmad0-dev
	elif [ "`command -v yum`" != "" ]; then
		sudo yum install -y libmad
		sudo yum install -y libmad-devel
	else
		echo "WARNING Platform not supported for installing the MAD library"
	fi
}
ld -lpulse -lpulse-simple >/dev/null 2>&1 || {
	echo "Installing PulseAudio ..."
	
	if [ "`command -v apt`" != "" ]; then
		sudo apt-get install -y libpulse0
		sudo apt-get install -y libpulse-dev
	elif [ "`command -v yum`" != "" ]; then
		sudo yum install -y pulseaudio-libs
		sudo yum install -y pulseaudio-libs-devel
	else
		echo "WARNING Platform not supported for installing the PulseAudio library"
	fi
}

echo "Installing potential missing extensions ..."
mkdir -p extensions

ld -L. -l:extensions/libdiscord-rpc.so >/dev/null 2>&1 || {
	echo "Installing Discord RPC ..."
	mkdir -p extensions/discord-rpc
	
	rm -rf install-dump
	mkdir -p install-dump
	cd install-dump
	
	wget https://github.com/discordapp/discord-rpc/releases/download/v3.4.0/discord-rpc-linux.zip
	unzip discord-rpc-linux.zip
	mv discord-rpc/linux-dynamic/lib/libdiscord-rpc.so ../extensions/libdiscord-rpc.so
	
	cd ..
	rm -rf install-dump
}

rm a.out

set -e
echo "Downloading potential missing folders ..."

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

if [ "$update" = "update" ]; then
	echo "Updating components ..."
	
	cd kos
	git pull origin master
	cd zvm
	git pull origin master
	cd ../../root
	git pull origin master
	cd ..
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
	
	if [ -f "compiler/code/perm" ]; then
		echo "Moving perm/ from compiler to root/perm/development/ ..."
		rm -rf root/perm/development
		mv compiler/code/perm root/perm/development
	fi
	
	echo "Compiling code with universal compiler ..."
	cd compiler
	sh build.sh git-prefix $git_prefix $update code $code
	cd ..
	mv compiler/rom.zed rom.zed
	
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
	echo "Compiling KOS ..."
	
	curl_args=""
	audio_args=""
	discord_args=""
	
	curl_link="-lcurl"
	audio_link="-lmad -lpulse -lpulse-simple"
	discord_link="-L. -l:extensions/libdiscord-rpc.so"
	
	set +e
	
	ld $curl_link    >/dev/null 2>&1 && curl_args="-D__HAS_CURL $curl_link"
	ld $audio_link   >/dev/null 2>&1 && audio_args="-D__HAS_AUDIO $audio_link"
	ld $discord_link >/dev/null 2>&1 && discord_args="-D__HAS_DISCORD $discord_link"
	
	set -e
	
	rm -f aqua
	gcc kos/glue.c -o aqua -std=gnu99 -O -Wall -no-pie \
		-DKOS_CURRENT=KOS_DESKTOP \
		-Wno-maybe-uninitialized -Wno-unused-result -Wno-unused-variable -Wno-unused-but-set-variable -Wno-main \
		-lSDL2 -lGL -lGLU -lm -lpthread \
		$curl_args $audio_args $discord_args
	rm a.out
fi

if [ "$execute" = "execute" ]; then
	echo "Executing KOS ..."
	./aqua
fi

echo "AQUA Linux builder terminated with no errors"
exit 0
