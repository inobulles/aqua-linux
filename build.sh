
#!/bin/sh
set -e;

echo "AQUA Linux builder"
echo "Parsing arguments ..."

kos=""
update=""
execute=""
code=""
example=""

while test $# -gt 0; do
	if   [ "$1" = "kos"     ]; then kos="kos"
	elif [ "$1" = "update"  ]; then update="update"
	elif [ "$1" = "execute" ]; then execute="execute"
	elif [ "$1" = "code"    ]; then code="$2";    shift
	elif [ "$1" = "example" ]; then example="$2"; shift
	elif [ "$1" = "help"    ]; then cat README.md
	else echo "WARNING Unknown argument '$1' (pass 'help' as an argument to get a list of all arguments)";
	fi
	
	shift
done

echo "Creating code/ ..."
mkdir -p code

echo "Downloading potential missing folders ..."

if [ ! -d "kos" ]; then
	git clone https://github.com/inobulles/aqua-kos --depth 1 -b master
	mv aqua-kos kos
fi

if [ ! -d "kos/zvm" ]; then
	git clone https://github.com/inobulles/aqua-zvm --depth 1 -b master
	mv aqua-zvm kos/zvm
fi

if [ ! -d "root" ]; then
	git clone https://github.com/inobulles/aqua-root --depth 1 -b master
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
		git clone https://github.com/inobulles/aqua-examples --depth 1 -b master
		mv aqua-examples examples
	else
		echo "Updating examples repository ..."
		cd examples
		git pull origin master
		cd ..
	fi
fi

if [ "$code" != "" ]; then
	if [ ! -d "compiler" ]; then
		echo "Installing compiler extension ..."
		git clone https://github.com/inobulles/aqua-compiler --depth 1 -b master
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
		cp -r code/* compiler/code
	fi
	
	echo "Compiling code with universal compiler ..."
	cd compiler
	sh build.sh $update code $code
	cd ..
	mv compiler/rom.zed rom.zed
else
	if [ "$example" != "" ]; then
		echo "Getting example ROM to execute ..."
		cp examples/$example/rom.zed rom.zed
	fi
fi

if [ ! -f "aqua" ] || [ "$kos" = "kos" ]; then
	echo "Compiling KOS ..."
	
	curl_args=""
	audio_args=""
	discord_args=""
	
	curl_link="-lcurl"
	audio_link="-lmad -lpulse -lpulse-simple"
	discord_link="-L. -l:extensions/libdiscord-rpc.so"
	
	set +e
	
	ld $curl_link    && curl_args="-D__HAS_CURL $curl_link"
	ld $audio_link   && audio_args="-D__HAS_AUDIO $audio_link"
	ld $discord_link && discord_args="-D__HAS_DISCORD $discord_link"
	
	set -e
	
	rm -f aqua
	gcc kos/glue.c -o aqua -std=gnu99 -O -Wall \
		-DKOS_CURRENT=KOS_DESKTOP \
		-Wno-maybe-uninitialized -Wno-unused-result -Wno-unused-variable -Wno-unused-but-set-variable -Wno-main \
		-lSDL2 -lGL -lGLU -lm -lpthread \
		$curl_args $audio_args $discord_args \
		-lfreetype -Ikos/src/external/freetype2 # fonts are a fucking pain in the ass, pls fix
fi

if [ "$execute" = "execute" ]; then
	echo "Executing KOS ..."
	./aqua
fi

echo "AQUA Linux builder terminated with no errors"
exit 0
