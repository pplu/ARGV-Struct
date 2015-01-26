#!/usr/bin/env perl

use Test::More;
use ARGV::Struct;

my @tests = (
 { argv => [ qw/{ X=Y }/ ],
   struct => { X => 'Y' },
 },
 { argv => [ qw/{ X=Y Y={ A=X } }/ ],
   struct => { X => 'Y', Y => { A => 'X' } }
 },
 { argv => [ qw/{ X=Y Y=[ 1 2 3 ] Z=3 }/ ],
   struct => { X => 'Y', Y => [ 1, 2, 3 ], Z => 3 }
 },
 { argv => [ qw/[ ]/ ],
   struct => [ ],
 }, 
 { argv => [ qw/[ A B ] /],
   struct => [ 'A', 'B' ],
 }, 
 { argv => [ '{', 'X= Y ', '}' ],
   struct => { X => ' Y ' },
 },
 { argv => [ '{', 'X=Y=Y', '}' ],
   struct => { X => 'Y=Y' },
 },
);

foreach $test (@tests) {
  is_deeply(
    ARGV::Struct->new(argv => $test->{ argv })->parse,
    $test->{ struct },
    "Conformance of " . join ' ', @{ $test->{ argv } }
  );
}

done_testing;