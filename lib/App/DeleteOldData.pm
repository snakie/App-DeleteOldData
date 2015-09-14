package App::DeleteOldData;

use strict;
use warnings;

use File::Path qw(remove_tree);
use Time::Piece;
use Time::Seconds;

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

    return $self;
}

=item
removes the base path and splits dataset, year, month, and day into variables
=cut

sub clean_and_split_path {
    my ( $self, $path ) = @_;
    $path =~ s/$self->{base_path}\///;    # remove base path
    my ( $dataset, $year, $month, $day ) = split /\//, $path;
    return ( $dataset, $year, $month, $day );
}

=item
return the paths to delete, only looking as deep as needed into 
the file tree. This works by tightening up the glob on each loop
iteration
=cut

sub get_paths_to_delete {
    my ( $self, $keep_y, $keep_m, $keep_d ) = @_;
    my @paths_to_delete;
    my @base_glob = ( $self->{base_path}, $self->{dataset_name}, "*" );

    # find years to delete
    foreach my $path ( glob join "/", @base_glob ) {
        my ( $dataset, $year ) = $self->clean_and_split_path($path);
        push @paths_to_delete, "$dataset/$year" if $year < $keep_y;
    }

    # add the year and a new wildcard to the glob
    $base_glob[-1] = $keep_y;
    push @base_glob, "*";

    # find months in the keep year to delete
    foreach my $path ( glob join "/", @base_glob ) {
        my ( $dataset, $year, $month ) = $self->clean_and_split_path($path);
        push @paths_to_delete, "$dataset/$year/$month" if $month < $keep_m;
    }

    # add the month and a new wildcard to the glob
    $base_glob[-1] = $keep_m;
    push @base_glob, "*";

    # find days in the keep month to delete
    foreach my $path ( glob join "/", @base_glob ) {
        my ( $dataset, $year, $month, $day ) =
          $self->clean_and_split_path($path);
        push @paths_to_delete, "$dataset/$year/$month/$day" if $day < $keep_d;
    }

    return @paths_to_delete;
}

=item
for a given date, determine what is the minimum date to keep
=cut

sub find_min_keep {
    my ( $self, $now ) = @_;
    my $to_keep = localtime( $now - ONE_DAY * $self->{older_than_days} );
    return (
        $to_keep->year,
        sprintf( "%02d", $to_keep->mon ),
        sprintf( "%02d", $to_keep->mday )
    );
}

=item
pretty prints the paths to be deleted
=cut

sub print_dryrun {
    my ( $self, @paths ) = @_;
    my $c = @paths;
    print <<DRYRUN;
DRYRUN:
  <path>            : $self->{base_path}
  <older-than-days> : $self->{older_than_days}
  <dataset-name>    : $self->{dataset_name}

The contents of the following $c paths will be completely deleted:
DRYRUN
    foreach (@paths) {
        print "  $self->{base_path}/$_\n";
    }
}

=item
actually perform the deletion
=cut

sub remove_paths {
    my ( $self, @paths ) = @_;
    foreach my $path (@paths) {
        remove_tree( $self->{'base_path'} . "/" . $path,
            { error => \my $err } );
        if (@$err) {
            foreach my $e (@$err) {
                my ( $file, $message ) = %$e;
                print STDERR "Error: $message";
                print STDERR " for file [$file]" if $file eq '';
                print "\n";
            }
            return 0;    # failure
        }
    }
    return 1;            # success
}

=item

orchestrate the deletion by:

- figuring out which dates to keep
- building list of paths to delete
- deleting or printing them

=cut

sub process_deletes {
    my ($self) = @_;

    # determine how much to keep
    my $time = localtime(time);
    my ( $min_year, $min_month, $min_day ) = $self->find_min_keep($time);

    # build paths to delete
    my @to_delete =
      $self->get_paths_to_delete( $min_year, $min_month, $min_day );

    if ( $self->{dryrun} ) {
        $self->print_dryrun(@to_delete);
        return 1;
    }

    #remove_paths will signal success or not
    return $self->remove_paths(@to_delete);
}

1;
