#!/usr/bin/env bash

# For some reason, PAR::Packer on linux is clever and when processing link lines
# resolves any symlinks but names the packed lib the same as the link name. This is
# a good thing.

# Have to explicitly include the Input* modules as the names of these are dynamically
# constructed in the code so Par::Packer can't auto-detect them

# -----------------------------------------------------------------------------

PAR_VERBATIM=1
export PAR_VERBATIM

PERL_ROOT="$Home/perl5/perlbrew/perls/perl-5.38.2/lib/site_perl/5.38.2"
PERLDOC_DIR="$Home/perl5/perlbrew/perls/perl-5.38.2/lib/5.38.2/Pod/Perldoc"
BIBER_BIN="$Home/perl5/perlbrew/perls/perl-5.38.2/bin/biber"
BIB_LIB="$PERL_ROOT/Biber"
PERL_LIB="$PERL_ROOT/OpenBSD.amd64-openbsd"

$Home/perl5/perlbrew/perls/perl-5.38.2/bin/pp -vv \
                                                        --module=deprecate \
                                                        --module=App::Packer::PAR \
                                                        --module=Biber::Input::file::bibtex \
                                                        --module=Biber::Input::file::biblatexml \
                                                        --module=Biber::Output::dot \
                                                        --module=Biber::Output::bbl \
                                                        --module=Biber::Output::bblxml \
                                                        --module=Biber::Output::bibtex \
                                                        --module=Biber::Output::biblatexml \
                                                        --module=HTTP::Status \
                                                        --module=HTTP::Date \
                                                        --module=Encode:: \
                                                        --module=Pod::Simple::TranscodeSmart \
                                                        --module=Pod::Simple::TranscodeDumb \
                                                        --module=Pod::Perldoc \
                                                        --module=List::MoreUtils::XS \
                                                        --module=List::SomeUtils::XS \
                                                        --module=List::MoreUtils::PP \
                                                        --module=Readonly::XS \
                                                        --module=IO::Socket::SSL \
                                                        --module=IO::String \
                                                        --module=PerlIO::utf8_strict \
                                                        --module=File::Find::Rule \
                                                        --module=Text::CSV_XS \
                                                        --module=DateTime \
                                                        --link="$Home/Sandbox/biber/blib/usrlib/libbtparse.so" \
                                                        --link=/usr/local/lib/libiconv.so.7.1 \
                                                        --link=/usr/local/lib/libxml2.so.19.0 \
                                                        --link=/usr/local/lib/libxslt.so.4.1 \
                                                        --link=/usr/local/lib/libexslt.so.9.8 \
                                                        --link=/usr/local/lib/libgdbm.so.7.0 \
                                                        --link=/usr/lib/libz.so.6.0 \
                                                        --link="$Home/Sandbox/biber/local/libcrypt.so.2" \
                                                        --link=/usr/lib/libutil.so.13.1 \
                                                        --link=/usr/local/lib/eopenssl31/libcrypto.so.15.1 \
                                                        --link=/usr/lib/libssl.so.47.4 \
                                                        --addlist=biber.files \
                                                        --cachedeps=scancache \
                                                        --output=biber-2.8.`uname -m`-openbsd`uname -r | sed 's/\..*//' | sed 's/8/8,9,10,11,12/'` \
                                                        "$BIBER_BIN"
