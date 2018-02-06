DOC_FILES=ptree.mli\
		ttree.mli\
		parser.mli\
		parser.ml

test: main.native mini-c
	./mini-c --debug test.c

main.native: *.ml*
	ocamlbuild $@

mini-c:
	ln -s main.native $@


doc: *.ml* cleandoc
	ocamlbuild main.docdir/index.html

.PHONY: clean cleandoc
cleandoc:
	$(RM) main.docdir

clean: cleandoc
	$(RM) mini
	$(RM) main.native
	$(RM) -r _build

