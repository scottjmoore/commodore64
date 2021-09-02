helloworld.d64: helloworld.prg
	c1541 -format helloworld,0 d64 helloworld.d64
	c1541 -attach helloworld.d64 -write helloworld.prg
	c1541 -attach helloworld.d64 -list

helloworld.prg:	helloworld.asm
	vasm6502_oldstyle helloworld.asm -cbm-prg -chklabels -nocase -L helloworld.lst -Fbin -o helloworld.prg

clean:
	-@rm -f *.d64
	-@rm -f *.prg
	-@rm -f *.lst

run:
	make
	x64sc -model ntsc -autostart "helloworld.d64:helloworld.prg"

clean-run:
	make clean
	make run
