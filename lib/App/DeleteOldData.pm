package App::DeleteOldData;

use strict;
use warnings;

use File::Path;
use Data::Dumper;
use Time::Piece;
use Time::Seconds;

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
    my ( $class, %options ) = @_;

    my $self = {};
    bless $self, $class;

    # verify required args
    unless (defined $options{older_than_days}
        and defined $options{base_path} ) {
        die "the options <older_than_days> and <base_path> are required";
    }
    $self->{older_than_days} = $options{older_than_days};
    $self->{base_path}       = $options{base_path};
    $self->{base_path} =~ s/\/$//;    # trim last slash

    # set dryrun
    if ( $options{dryrun} ) {
        $self->{dryrun} = 1;
    }

    # set dataset name if needed
    $self->{dataset_name} = $options{dataset_name};
    $self->{dataset_name} = "*" unless $self->{dataset_name};
    print Dumper($self);

    return $self;
}

sub get_existing_path_hash {
    my ($self) = @_;
    my $glob =
      join( "/", $self->{base_path}, $self->{dataset_name}, "*", "*", "*" );
    my $paths = {};
    foreach my $path ( glob $glob ) {
        $path =~ s/$self->{base_path}\///;
        my ( $dataset, $year, $month, $day ) = split /\//, $path;
        $paths->{$dataset} = {} unless $paths->{$dataset};
        $paths->{$dataset}->{$year} = {} unless $paths->{$dataset}->{$year};
        $paths->{$dataset}->{$year}->{$month} = ()
          unless $paths->{$dataset}->{$year}->{$month};
        push @{ $paths->{$dataset}->{$year}->{$month} }, $day;

    }
    return $paths;
}

=item

For a given date, discover the paths to delete based on what exists

=cut

sub build_paths {
    my ( $self, $date ) = @_;

}

sub process_deletes {
    my ($self) = @_;

    my $existing_paths = $self->get_existing_path_hash();

    print Dumper($existing_paths);

    my $time = localtime;
    my ( $min_year, $min_month, $min_day ) = $self->find_min_keep($time);

    #my $date_to_delete =

    #$self->delete_paths(@paths);

}

1;
