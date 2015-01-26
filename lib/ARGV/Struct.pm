package ARGV::Struct {
  use Moose;

  has argv => (
    is => 'ro', 
    isa => 'ArrayRef', 
    default => sub { [ @ARGV ] }, 
    traits => [ 'Array' ],
    handles => {
      argcount => 'count',
      arg => 'get',
      args => 'elements',
    }
  );

  sub parse {
    my ($self) = @_;
    my $substruct = $self->_parse_argv($self->args);
    die "Unclosed structure" if (scalar(@{ $substruct->{ leftover } }));
    return $substruct->{ struct };
  }

  sub _parse_argv {
    my ($self, @args) = @_;
    my $context;
    my $actual_struct;

    my $token = shift @args;
    if ($token eq '[') {
      $actual_struct = [];
      $context = 'list';
    } elsif($token eq '{') {
      $actual_struct = {};
      $context = 'hash';
    }

    while (my $token = shift @args) {
#use Data::Dumper;
#print Dumper(\@args, $actual_struct);
      if ($token eq '[') {
        # A new struct is coming!
        my $substruct = $self->_parse_argv($token, @args);
        push @$actual_struct, $substruct->{ struct };
        @args = @{ $substruct->{ leftover } };
      } elsif($token eq '{') {
        my $substruct = $self->_parse_argv($token, @args);
        push @$actual_struct, $substruct->{ struct };
        @args = @{ $substruct->{ leftover } };
      } elsif ($token eq ']') {
        return { struct => $actual_struct, leftover => [ @args ] };
      } elsif ($token eq '}') {
        return { struct => $actual_struct, leftover => [ @args ] };
      } elsif ($context eq 'list') {
        push @$actual_struct, $token;
      } elsif ($context eq 'hash') {
        my ($k, $v) = split /=/, $token, 2;
 
        if ($v ne '{' and $v ne '[') {
          die "Repeated $k in hash" if (exists $actual_struct->{ $k });
          $actual_struct->{ $k } = $v;
        } else {
          my $substruct = $self->_parse_argv($v, @args);
          $actual_struct->{ $k } = $substruct->{ struct };
          @args = @{ $substruct->{ leftover } };
        }
      }
    }
    die "No end token in $context context";
  }
}

1;
#################### main pod documentation begin ###################

=head1 NAME

ARGV::Struct - Parse complex data structures passed in ARGV

=head1 SYNOPSIS

  use ARGV::Struct;
  my $struct = ARGV::Struct->new->parse;

=head1 DESCRIPTION

Have you ever felt that you need something different than Getopt?

Are you tired of shoehorning Getopt style arguments into your commandline scripts?

Are you trying to express complex datastructures via command line?

then ARGV::Struct is for you!

It's designed so the users of your command line utilities won't hate you when things
get complex.

=head1 THE PAIN

I've had the "privilege" of finding some 

=head2 Complex arguments codified as JSON

JSON is horrible for the command line having to escape quotes, is a nightmare. It's a pain.

  command --complex_arg "{\"key1\":\"value1\",\"key2\":\"value2\"}"

=head2 Arguments encoded via some custom scheme

These schemes fail when you have to make values complex (lists, or other key/values(

  command --complex_arg key1,value1:key2,value2

=head2 Repeating Getopt arguments

Getopt friendly, but too verbose

  command --key key1 --value value1 --key key1 --value value 2

=head1 THE DESIGN

The design of this module is aimed at "playing well with the shell". The main purpose is
to let the user transmit complex data structures, while staying compact enough for command line
use.

=head2 Key/Value sets (objects)

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

=head2 Lists

  command [ VALUE1 VALUE2 ]

Each value can be a simple scalar value, or an object or list

  command [ { Name=X } { Name=Y } ]
  command [ [ 1 2 3 ] [ 4 5 6 ] [ 7 8 9 ] ]
  command [ "First Value" "Second Value" ]

Values are never separated by commas to keep the syntax compact. 
The shell is expected to split the different elements into tokens, so
the user is expected to use shell quotes to keep values together

=head1 METHODS

=head2 new([argv => ArrayRef])

Return an instance of the parser. If argv is not specified, @ARGV will be
used.

=head2 parse

return the parsed data structure

=head1 STATUS

This module is quite experimental. I developed it while developing Paws (a 
Perl AWS SDK). It has a commandline utility that needs to recollect all the
Attributes and Values for method calls. Since Getopt was ugly as hell, I 
decided that it would be better to do things in a different way, and eventually
thought it could be an independent module.

I'm publishing this module to get the idea out to the public so it can be worked
on.

Please bash the guts out of it. Break it and shake it till it falls apart. 

Contribute bugs and patches. All input is welcome.

=head1 

=head1 TODO

Try to combine with Getopt/MooseX::Getopt, so some parameters could be an ARGV::Struct

=head1 CONTRIBUTE

The source code and issues are on https://github.com/pplu/ARGV-Struct

=head1 AUTHOR

    Jose Luis Martinez
    CPAN ID: JLMARTIN
    CAPSiDE
    jlmartinez@capside.com
    http://www.pplusdomain.net

=head1 COPYRIGHT

Copyright (c) 2015 by Jose Luis Martinez Torres

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut
