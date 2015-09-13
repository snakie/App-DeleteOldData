package App::DeleteOldData;

use File::Path;
use Data::Dumper;

# use rmdir to clean up empty directories
# use rmtree to clean up files

=item

Constructor. Requires the following 3 arguments:

dryrun          : boolean : do not actually perform the deletes
older_than_days : integer :


And one optional argument:

verbose : boolean : options

=cut

sub new {
    my ($class,%options) = @_;
    print Dumper(%options);

    my $self = {};
    bless $self, $class;

    # verify options here

    return $self;
}

1;
