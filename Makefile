DOC_FILES=ptree.mli\
		ttree.mli\
		parser.mli\
		parser.ml

test: main.native mini-c
	./mini-c --debug test.c


ltl: main.native mini-c
	./mini-c --debug --interp-ltl test.c

main.native: *.ml*
	ocamlbuild $@

main.d.byte: *.ml*
	ocamlbuild $@

mini-c: main.native
	ln -sf main.native $@

doc: *.ml* cleandoc
	mkdir -p doc
	# ocamlbuild main.docdir/index.html
	# ocamldoc -html *.ml* -d doc -I _build
	ocamldoc -html *.ml* -d doc -I _build -inv-merge-ml-mli -verbose -m A -charset utf-8

.PHONY: clean cleandoc tests

t_typing: mini-c
	ln -sf mini-c tests/mini-c
	cd tests && ./run -v2 ../mini-c

t_rtl: mini-c
	cd tests && ./run -i "../mini-c --interp-rtl"

t_ertl: mini-c
	cd tests && ./run -i "../mini-c --interp-ertl"

t_ltl: mini-c
	cd tests && ./run -i "../mini-c --interp-ltl"

t_compil: mini-c
	cd tests && ./run -3 "../mini-c --debug"

t_final: mini-c
	cd tests && ./run -all "../mini-c --debug"

cleanmini:
	$(RM) tests/mini-c
	$(RM) mini-c
	$(RM) main.native

cleandoc:
# 	$(RM) main.docdir
	$(RM) doc/*

clean: cleandoc cleanmini
	$(RM) -r _build

