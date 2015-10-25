#!perl -w
use strict;
use Test::More;
use File::Find;

my @modules;

find( sub {
          return unless /\.pm$/; local $_ = $File::Find::name;
          s!^lib/!!; s!/!::!g; s/\.pm$//;
          push @modules, $_;
      }, 'lib/Act' );

plan tests => scalar(@modules);

# Apache2::Const only works under mod_perl
package Apache2::Const;
use constant OK       =>  0;
use constant DECLINED => -1;
use constant DONE     => -2;

package main;
require_ok($_) for @modules;
