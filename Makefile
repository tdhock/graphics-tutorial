README.html: README.org HOCKING-graphics-tutorial.pdf
	emacs README.org --batch -f org-export-as-html

HOCKING-graphics-tutorial.pdf: HOCKING-graphics-tutorial.tex figure-SegCost.tex figure-TestError.png figure-CompareAUC.pdf
	R --no-save < knit.R
	pdflatex HOCKING-graphics-tutorial

figure-SegCost.tex: figure-SegCost.R SegCost.csv 
	R --no-save < $<
figure-TestError.png: figure-TestError.R TestError.csv 
	R --no-save < $<
figure-CompareAUC.pdf: figure-CompareAUC.R CompareAUC.csv
	R --no-save < $<
