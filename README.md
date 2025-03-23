<h1 align="center">Welcome to Biber-OpenBSD 👋</h1>
<p>
  <img alt="Version" src="https://img.shields.io/badge/version-0.0.5-blue.svg?cacheSeconds=2592000" />
  <a href="https://anoduck.mit-license.org" target="_blank">
    <img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-yellow.svg" />
  </a>
</p>

> Needed files for building Biber on OpenBSD

## Biber OpenBSD

### Notations on working directory

*Some people* do not like to clutter up their home directory (I am poking fun @madaalch), where some people
are of the exact opposite affinity. This is more or less simply differences in philosophical perspectives of
Unix. This being said, the work directory for this installation can be where ever and whatever you want it to
be, `~/Sandbox` is used to conserve the effort of the Author, as at the time of writing `~/Sandbox/`
was already referenced by the build files. In retrospect, a more traditional working directory would have been
`/opt` or `/usr/src`.

If you decide to use another working directory other than `~/Sandbox/` then you will need to edit the build
files to reflect this change. To make things painfully obvious, the "build files" are the files located in
`dist/OpenBSD` of this repository.

#### BibLaTeX by @madaalch

In order for biber to work, it needs a compatible version of BibLaTeX.
Once you have verified that biber is functioning and have copied it to the bin directory of your choice run `biber --version` and make note.

To find the compatible version, visit the [biber documentation page](https://sourceforge.net/projects/biblatex-biber/files/biblatex-biber/development/documentation) and in biber.pdf look at compatibility matrix.
Download the corresponding version of BibLaTeX from [sourceforge](https://sourceforge.net/projects/biblatex)

Run `kpsewhich -var-value=TEXHOME` and make note of directory;
(it should be `~/texmf`; if this doesn't exist then create it).
`cd` to directory which contains the downloaded `biblatex-*.tgz`.
`tar -zxvf biblatex-*.tgz -C ~/texmf` where * is the version you have just downloaded.
`texhash ~/texmf`

*NOTE* after running the above command, `kpsewhich -var-value=TEXHOME` will no longer print anything.

Now go back to the `~/Sandbox/biber/testfiles` directory and `pdflatex test ; biber test ; pdflatex test`.
Open the test.pdf; if you have no errors then your test.pdf will list a single successful reference.

Back up the document that you wish to run biber with.
Run `pdflatex yourdocumentname ; biber yourdocumentname` and check for errors.
Note that if your .bib file's name contains 12 or more characters you will get an error,
(example bibliography.bib will be truncated to bibliograph.bib, which biber will not be able to find.)
if needs be rename it to biblio.bib or something similarly short.
Now recompile your document and you should have all your beautiful references sorted.

## Installing Biber on OpenBSD

It's time to play everyone's favorite game, "Do as I say, not as I do."

As you perform this install, keep in mind, you do not want to use `sudo` or `doas` for any of the
following commands, nor do you want to perform these steps as root. Doing so **will result in the
corruption of your system's perl distribution**.

### Install Perlbrew

To install Biber on OpenBSD, Perlbrew is required. The installation script for perlbrew is below.

You can spend time trying to get the perlbrew installation script working in an alternate shell (e.g., ksh, zsh), but it's easier to just install bash.


```bash
curl -L https://install.perlbrew.pl | bash
```

Once complete, open your shell's rc file and ensure the following lines are in it.

```bash
source ~/perl5/perlbrew/etc/bashrc
```

This can be done with a quick grep, `cat ~/.bashrc | grep perlbrew`, and if you do not see it you can use
echo to add it, `echo "source ~/perl5/perlbrew/etc/bashrc" >> ~/.bashrc`.

#### Setup Perlbrew

You will need to use perlbrew to build and install the latest stable perl release. This will take
several minutes to compile.

```bash
perlbrew install perl-stable > /dev/null 2>&1 | tail -f ~/perl5/perlbrew/build.perl-*.log
```

Next install cpm, the perl package manager. If your not familiar with cpm, it is a little different from cpan,
but it is much faster. Cpm by defaults install packages by creating a local folder for perl
libraries, and places the installed packages there, this is not what we want. What we want is for
cpm to install packages in perlbew’s path where perlbrew can find it. This is done with use of the
`-g` flag. Everytime you run cpm, you will need to use the `-g` flag, which tells cpm the packages
are to be installed for global use, just like you would with npm. 

```bash
perlbrew install-cpm
```

Now that perlbrew and cpm are setup, it is best to open up a new shell to prevent any of the
environment variables we are about to setup from bleading over into other actions you might do later
on.

Once a new shell is open, inform perlbrew you want to use the perl release you just installed.

```bash
perlbrew use $(perlbrew list)
```

This will setup all of those environmental variables we talked about, and should complete the setup
of perlbrew for the install.

### Create a work directory

For this build to work and have all the preconfigured paths worked properly, a work directory named
"Sandbox" will need to be used to contain all the folders and files. If you do not already have a
sandbox, go ahead and create that directory.

``` sh
mkdir -p $HOME/Sandbox && cd $_
```

### Acquire dependencies and source

Go ahead and clone the repository with the source code for biber inside your sandbox.

```bash
git clone https://github.com/plk/biber
```

It is time to install the required perl dependencies for the build, which will be done with
cpm. This will be done in two steps as to avoid cpm from returning an error message stating you are
missing a required perl library.

```bash
# First install the build module to avoid the error.
cpm install -g Module::Build
# Then install the remainder of the dependencies needed for the build.
cpm install -g Readonly::XS Pod::Simple Pod::Simple::TranscodeSmart \
Pod::Simple::TranscodeDumb Pod::Perldoc Text::BibTeX Text::CSV IO::Socket::SSL DateTime DateTime::Format::Builder DateTime::Calendar::Julian XML::LibXML::Simple XML::LibXSLT
```

### Install Perl Packer

*OK, I admit it. I screwed up and forgot to mention this the first time I wrote this file.*

Before going any further, take the time to install `pp` the perl packer. Later on, the distribution build
script will use `pp` to package the biber binary you are diligently working to build.

``` sh
cpm install -g pp
```

### Setting up the repository for a successful build 

This is where the other files in this repository play an important role. Take a moment to examine
this repository’s tree structure. You will want to follow the same structure when you copy the files
from this repository into the root folder of the biber repository you just cloned.

``` sh
.
|-- README.md
|-- dist
|   `-- openbsd_amd64
|       |-- biber.files
|       `-- build.sh
`-- local
    `-- libcrypt.so.2
```

#### Clone this repository and copy it’s files into the Biber Repository

You should still be in the root of your sandbox; if not, `cd ~/Sandbox`. Clone this repository. In other words,
`cd..`.

``` sh
git clone https://github.com/anoduck/Biber-OpenBSD && cd Biber-OpenBSD
```

Now copy the contents of this repository into your biber repository, ensuring to maintain the same folder
structure.

``` sh
cp -r dist/openbsd_amd64 ../biber/dist/
# AND
cp -r local ../biber/
```

This should setup the biber repository for a successful build.

### Build biber

Having to rarely compile perl binaries from source, the next few steps threw me for a loop the first
time. This is because developers often provide, and sometimes are required to provide, users with
different means to install their software. With biber, this is not the case, and perl provides all
the flexibility for different platforms one might need. 

Change Directory into the biber repository.

``` sh
cd ../biber
```

#### Execute the perl build script

Running `perl Build.PL`, will generate a script file confusingly labeled "Build". This script will
be used to ensure we have satisfied all the required dependencies, build all of biber’s libraries,
and prepare the "dist" file for compilation. 


``` sh
# Generate the "Build" script
perl Build.PL
# Use "Build" to confirm the dependencies
./Build installdeps
# Then use "Build" to build biber's libraries
./Build
# Finally install those libraries locally
./Build install
```

### Install btparse

Btparse is "the C component of btOOL, a pair of libraries for parsing and 
 processing BibTeX files."

In order to install the bparse package for perl, you will need to manually install it
yourself. This involves downloading the library, compiling it, and installing it in your perlbrew
library path. Perlbrew makes doing all of this fairly straight forward.

At the time of writing, the current stable perl release is `5.38.2`. This is important, because you
need to make sure the downloaded library is compatible with the version of perl you installed. The
source code for this package can be found on
[launchpad](https://launchpad.net/ubuntu/+source/libtext-bibtex-perl). The url for the
source archive used to successfully build biber is included in the command below. So, let’s download
it (using `ftp` as it is native to OpenBSD).

``` sh
ftp https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/libtext-bibtex-perl/0.88-3build3/libtext-bibtex-perl_0.88.orig.tar.gz
```

Extract it, cd into it, and run the build script.

``` sh
tar -zxvf libtext-bibtex-perl_0.88.orig.tar.gz && cd Text-BibTeX-0.88 && perl Build.PL && ./Build
```

Once successfully built, you will need to move/merge parts of this directory into the biber repo. Specifically, you
will need to merge the `blib` folder from this directory with the `blib` folder in the biber
repository.

``` sh
# If you use the standard cp
cp -R blib/* ../../blib/
# If you use gnu cp
cp -r blib/* ../../blib/
```

#### Finally, build and package biber

Now biber is ready to be built, and it’s about damn time. You will need to change directory into
OpenBSD’s distribution specific folder and run the build from there.

``` sh
cd dist/openbsd_amd64
./build.sh
```

You might need to update the version number of libraries in `build.sh`. You may also need to install some (e.g., `doas pkg_add gdbm openssl-3.3.2p0v0`).

### Run the test to ensure it works

Being brutally honest, it took four tries before a functioning biber executable was built. Every one
of those four builds completed, but failed to run during testing. So testing your build is
important.

To test your newly created binary, you will want to change directories to the "testfiles" directory
located in the root of the biber repository. From there, test with the following command.

``` sh
# Change Dir
cd ../../testfiles
# Now run the test
../dist/openbsd_amd64/biber-2.8.amd64-openbsd7 --validate-control --convert-control test
```

If the test checks out, you now have a working biber binary.

### Wrapping it up

Since the binary we just built is a self extracting archive, containing within itself all the needed
libraries to function, it can safely be placed in your path at `/usr/local/bin/biber`. Which is where Emacs
will look for it, in case you are wondering. 

As for Perlbrew, you can purge it from your system if desired, but it is recommended to keep Perlbrew
installed for future builds of biber. Instead just remove the currently installed perl build and disable perlbrew.
This will reduce the overall consumption of disk space greatly.

```bash
# See what version of perl you installed
perlbrew list
# And then remove that version. Ex. 5.38.2
perlbrew uninstall perl-5.38.2
# Then disable perlbrew for this shell
perlbrew off
```

And, with that your done!

### Caveats

- Just be aware the executable is built from perl libraries that may not be native to your system. More
  than likely, this never should be the cause of any issues, but is healthy to keep a mental note of it.

## Author

👤 **Anoduck**

* Website: http://anoduck.github.io
* Github: [@anoduck](https://github.com/anoduck)

## Show your support

Give a ⭐️ if this project helped you!

## 📝 License

Copyright © 2024 [Anoduck](https://github.com/anoduck).<br />
This project is [MIT](https://anoduck.mit-license.org) licensed. Why this link does not include my username is
unknown.

***
_This README was generated with ❤️ by [readme-md-generator](https://github.com/kefranabg/readme-md-generator)_
