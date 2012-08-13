
all: testfont

testfont: testfont.cpp tom-thumb-tall.h
	gcc -o testfont testfont.cpp

tom-thumb-tall.h: tom-thumb-tall.bdf convertbdf.py
	python convertbdf.py >tom-thumb-tall.h

