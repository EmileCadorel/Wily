all:
	dub build --parallel

test:
	dub test

install:
	dub build --parallel --build=release

clean:
	rm wily
	dub clean
