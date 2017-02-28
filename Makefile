all:
	dub build --parallel

install:
	dub build --parallel --build=release
