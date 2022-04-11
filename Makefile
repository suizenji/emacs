all: clean init.elc

%.elc:
	emacs --batch -f batch-byte-compile init.el

clean:
	-rm *.elc
