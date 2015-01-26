# NAME

ARGV::Struct - Parse complex data structures passed in ARGV

# SYNOPSIS

    use ARGV::Struct;
    my $struct = ARGV::Struct->new->parse;

# DESCRIPTION

Have you ever felt that you need something different than Getopt?

Are you tired of shoehorning Getopt style arguments into your commandline scripts?

Are you trying to express complex datastructures via command line?

then ARGV::Struct is for you!

It's designed so the users of your command line utilities won't hate you when things
get complex.

# THE PAIN

I've had the "privilege" of finding some 

## Complex arguments codified as JSON

JSON is horrible for the command line having to escape quotes, is a nightmare. It's a pain.

    command --complex_arg "{\"key1\":\"value1\",\"key2\":\"value2\"}"

## Arguments encoded via some custom scheme

These schemes fail when you have to make values complex (lists, or other key/values(

    command --complex_arg key1,value1:key2,value2

## Repeating Getopt arguments

Getopt friendly, but too verbose

    command --key key1 --value value1 --key key1 --value value 2

# THE DESIGN

The design of this module is aimed at "playing well with the shell". The main purpose is
to let the user transmit complex data structures, while staying compact enough for command line
use.

## Key/Value sets (objects)

On the command line, the user can transmit sets of key/value pairs within curly brackets

    command { K_V_PAIR1 K_V_PAIR2 }

The shell is expected to do some work for us, so key/value pairs are separated by spaces

Each key/value pair is expressed as

    Key=Value

If the value contains spaces, the user can surround the pair with the shell metacharacters

    command { "Key= Value " }

Values can also be objects:

    command { Key={ Nested=Key } }

or lists

    command { Key=[ 1 2 3 ] }

## Lists

    command [ VALUE1 VALUE2 ]

Each value can be a simple scalar value, or an object or list

    command [ { Name=X } { Name=Y } ]
    command [ [ 1 2 3 ] [ 4 5 6 ] [ 7 8 9 ] ]
    command [ "First Value" "Second Value" ]

Values are never separated by commas to keep the syntax compact. 
The shell is expected to split the different elements into tokens, so
the user is expected to use shell quotes to keep values together

# METHODS

## new(\[argv => ArrayRef\])

Return an instance of the parser. If argv is not specified, @ARGV will be
used.

## parse

return the parsed data structure

# STATUS

This module is quite experimental. I developed it while developing Paws (a 
Perl AWS SDK). It has a commandline utility that needs to recollect all the
Attributes and Values for method calls. Since Getopt was ugly as hell, I 
decided that it would be better to do things in a different way, and eventually
thought it could be an independent module.

I'm publishing this module to get the idea out to the public so it can be worked
on.

Please bash the guts out of it. Break it and shake it till it falls apart. 

Contribute bugs and patches. All input is welcome.

# 

# TODO

Try to combine with Getopt/MooseX::Getopt, so some parameters could be an ARGV::Struct

# CONTRIBUTE

The source code and issues are on https://github.com/pplu/ARGV-Struct

# AUTHOR

    Jose Luis Martinez
    CPAN ID: JLMARTIN
    CAPSiDE
    jlmartinez@capside.com
    http://www.pplusdomain.net

# COPYRIGHT

Copyright (c) 2015 by Jose Luis Martinez Torres

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.
