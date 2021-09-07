scrolling.d64: scrolling.prg
	c1541 -format scrolling,0 d64 scrolling.d64
	c1541 -attach scrolling.d64 -write scrolling.prg
	c1541 -attach scrolling.d64 -list

scrolling.prg:	scrolling.asm
	vasm6502_oldstyle scrolling.asm -cbm-prg -chklabels -nocase -L scrolling.lst -Fbin -o scrolling.prg

clean:
	-@rm -f *.d64
	-@rm -f *.prg
	-@rm -f *.lst

run:
	make
	x64sc -model ntsc -autostart "scrolling.d64:scrolling.prg" &

run-retroarch:
	make
	retroarch -D -L /usr/lib64/libretro/vice_x64sc_libretro.so ./scrolling.d64

run-pal:
	make
	x64sc -model pal -autostart "scrolling.d64:scrolling.prg" &

run-retroarch:
	make
	retroarch -D -L /usr/lib64/libretro/vice_x64sc_libretro.so ./scrolling.d64

clean-run:
	make clean
	make run

clean-run-pal:
	make clean
	make run-pal

clean-run-retroarch:
	make clean
	retroarch -D -L /usr/lib64/libretro/vice_x64sc_libretro.so ./scrolling.d64

