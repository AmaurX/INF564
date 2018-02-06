DOC_FILES=ptree.mli\
		ttree.mli\
		parser.mli\
		parser.ml

test: main.native mini-c
	./mini-c --debug test.c

main.native: *.ml*
	ocamlbuild $@

main.d.byte: *.ml*
	ocamlbuild $@

mini-c:
	ln -s main.native $@


doc: *.ml* cleandoc
	# ocamlbuild main.docdir/index.html
	# ocamldoc -html *.ml* -d doc -I _build
	ocamldoc -html *.ml* -d doc -I _build -inv-merge-ml-mli -verbose -m A

.PHONY: clean cleandoc
cleandoc:
# 	$(RM) main.docdir
	$(RM) doc/*

clean: cleandoc
	$(RM) mini
	$(RM) main.native
	$(RM) -r _build

