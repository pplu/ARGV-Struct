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
    
    while (my $token = shift @args) {
      if ($token eq '[') {
        $actual_struct = [];
        $context = 'list';
      } elsif($token eq '{') {
        $actual_struct = {};
        $context = 'hash';
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
