<h1 align="center">Welcome to Biber-OpenBSD 👋</h1>
<p>
  <img alt="Version" src="https://img.shields.io/badge/version-0.0.1-blue.svg?cacheSeconds=2592000" />
  <a href="https://anoduck.mit-license.org" target="_blank">
    <img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-yellow.svg" />
  </a>
</p>

> Needed files for building Biber on OpenBSD

## Installing Biber on OpenBSD

As you perform this install, keep in mind, you do not want to use `sudo` or `doas` for any of the
following commands, nor do you want to perform these steps as root. Doing so *will result in the
corruption of your system's perl distribution*.

### Install Perlbrew

To install Biber on OpenBSD, Perlbrew is required. The installation script for perlbrew is below.

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

Go ahead and clone the repository with the source code for biber where ever you normally put such
things. After witnessing another user on github use the folder `~/Sandbox`, I have followed suit,
but this is just a suggestion.

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
cpm install -g bibtex Readonly::XS Pod::Simple Pod::Simple::TranscodeSmart \
Pod::Simple::TranscodeDumb pod::PerlDoc Text::BibTex Text::CSV
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

3 directories, 5 files
```

#### Clone this repository and copy it’s files into the Biber Repository

So, let’s change directory to whereever you usually put such things, and clone this repository. For
this tutorial, we will assume that place will be the parent folder of the current one, which means
it is `../` relative to your `$PWD`.

``` sh
cd .. && git clone https://github.com/anoduck/Biber-OpenBSD && cd Biber-OpenBSD
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
time. This is because developers often provide and sometimes even required to provide users with
different ways to install their software. With biber, this is not the case, and perl provides all
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
it.

``` sh
wget wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/libtext-bibtex-perl/0.88-3build3/libtext-bibtex-perl_0.88.orig.tar.gz
```

Extract it, cd into it, and run the build script.

``` sh
tar zxvf libtext-bibtex-perl_0.88.org.tar.gz && cd Text-BibTeX-0.88 && perl Build.pl && ./Build
```

Once successfully built, you will need to move/merge parts of this directory into the biber repo. Specifically, you
will need to merge the `blib` folder from this directory with the `blib` folder in the biber
repository.

``` sh
cp -r blib/* ../../blib/
```

#### Finally, build and package biber

Now biber is ready to be built, and it’s about damn time. You will need to change directory into
OpenBSD’s distribution specific folder and run the build from there.

``` sh
cd dist/openbsd_amd64
./build.sh
```

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

When this completes without an error, you have successfully built biber.

### Caveats

The drawback to this approach of building biber, is biber must remain in the user’s home folder in
order to locate it’s required libraries. 

## Author

👤 **Anoduck**

* Website: http://anoduck.github.io
* Github: [@anoduck](https://github.com/anoduck)

## Show your support

Give a ⭐️ if this project helped you!

## 📝 License

Copyright © 2024 [Anoduck](https://github.com/anoduck).<br />
This project is [MIT](https://anoduck.mit-license.org) licensed.

***
_This README was generated with ❤️ by [readme-md-generator](https://github.com/kefranabg/readme-md-generator)_