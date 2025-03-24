the test file in the anoduck repo does not check compatibility with the installed version of biblatex.

openbsd does not permit upgrading latex (texlive) packages.

so you need to choose the correct biber version.

[this page of biber releases](https://github.com/plk/biber/releases) lists some of the relevant compatibility. in my case, on openbsd 7.6 in march 2025, i get this error:

```
menthe% biber ms
INFO - This is Biber 2.21 (beta)
INFO - Logfile is 'ms.blg'
INFO - Reading 'ms.bcf'
ERROR - Error: Found biblatex control file version 3.10, expected version 3.11.
This means that your biber (2.21) and biblatex (3.19) versions are incompatible.
See compat matrix in biblatex or biber PDF documentation.
INFO - ERRORS: 1
menthe%
```
anoduck's readme lead me to checkout from git, which is the development version. i don't ever want that. i only want releases. so instead i choose a tarball from that github page of biber tags.

i will try [biber v2.19](https://github.com/plk/biber/archive/refs/tags/v2.19.tar.gz).

do this before building biber:

cpm install -g LWP::Protocol::https

it won't install it as a dependency properly itself.

copy the stuff from https://github.com/anoduck/Biber-OpenBSD, dist and local, into your unpacked biber 2.19. build biber as anoduck instructs.

```
menthe% biber ms           
INFO - This is Biber 2.19
INFO - Logfile is 'ms.blg'
INFO - Reading 'ms.bcf'
INFO - Found 30 citekeys in bib section 0
INFO - Processing section 0
INFO - Looking for bibtex file '../bib.bib' for section 0
INFO - LaTeX decoding ...
INFO - Found BibTeX data source '../bib.bib'
INFO - Overriding locale 'en-US' defaults 'level = 4' with 'level = 2'
INFO - Overriding locale 'en-US' defaults 'normalization = NFD' with 'normalization = prenormalized'
INFO - Overriding locale 'en-US' defaults 'variable = shifted' with 'variable = non-ignorable'
INFO - Sorting list 'cms/global//global/global' of type 'entry' with template 'cms' and locale 'en-US'
INFO - No sort tailoring available for locale 'en-US'
INFO - Writing 'ms.bbl' with encoding 'UTF-8'
INFO - Output to ms.bbl
menthe%
```

it works!
