package App::DeleteOldData;

use File::Path;
use Data::Dumper;

# use rmdir to clean up empty directories
# use rmtree to clean up files

=item
Constructor. Designed to process data in the following path format:
$base_path/$dataset_name/<year>/<month>/<day>/<hour>/<files> 

Requires the following 2 options:

older_than_days : integer : number of days which to delete data
base_path       : string  : as listed above in path format, required

and the following 2 are optional:

dryrun          : boolean : do not actually perform the deletes, but print them
dataset_name    : string  : as listed above in path format. if not supplied
                            all datasets will be processed
=cut

sub new {
    my ($class,%options) = @_;
    print Dumper(%options);

    my $self = {};
    bless $self, $class;
    # verify required args
    unless(defined $options{older_than_days} and
           defined $options{base_path}) {
        die "the options <older_than_days> and <base_path> are required";
    }
    $self->{older_than_days}= $options{older_than_days}; 
    $self->{base_path} =  $options{base_path}; 
    # set dryrun
    if($options{dryrun}) {
        $self->{dryrun} = 1;
    }
    # set dataset name if needed
    if(defined $options{dataset_name}) {
        $self->{dataset_name} = $options{dataset_name};
    }
    print Dumper($self);

    return $self;
}

1;
