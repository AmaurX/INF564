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
	ln -sf main.native $@

doc: *.ml* cleandoc
	# ocamlbuild main.docdir/index.html
	# ocamldoc -html *.ml* -d doc -I _build
	ocamldoc -html *.ml* -d doc -I _build -inv-merge-ml-mli -verbose -m A -charset utf-8

.PHONY: clean cleandoc tests

t_typing: mini-c
	ln -sf mini-c tests/mini-c
	cd tests && ./run -v2 ../mini-c

t_rtl: mini-c
	cd tests && ./run -i ../mini-c --interp-rtl

t_ertl: mini-c
	cd tests && ./run -i ../mini-c --interp-ertl

cleanmini:
	$(RM) tests/mini-c
	$(RM) mini-c
	$(RM) main.native

cleandoc:
# 	$(RM) main.docdir
	$(RM) doc/*

clean: cleandoc cleanmini
	$(RM) -r _build

