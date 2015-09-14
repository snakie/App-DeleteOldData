use strict;
use warnings;

use Test::More tests => 10;
use Data::Dumper;

# check compile
require_ok('App::DeleteOldData');
use App::DeleteOldData;
use Time::Piece;

my %base_options = ( 
        older_than_days => 15,
        base_path       => "t/test_data",
    );

my $deleter = App::DeleteOldData->new( %base_options );
isa_ok($deleter,"App::DeleteOldData");
my $path_hash = $deleter->get_existing_path_hash();
isa_ok($path_hash,"HASH");

# check hash integrity
is(scalar(keys %$path_hash), 2, "2 datasets when no dataset specified");
is(scalar(keys %{$path_hash->{foo}->{2015}}), 3, "3 months in foo dataset");
is(@{$path_hash->{foo}->{2015}->{"06"}}, 30, "30 days in foo/2015/06");

# try with only 1 dataset
$deleter = App::DeleteOldData->new( %base_options, dataset_name => "foo");
$path_hash = $deleter->get_existing_path_hash();
is(scalar(keys %$path_hash), 1, "1 dataset when foo dataset specified");

# test how far back to delete
my $now = localtime(1438430400); # Aug 1st 2015 05:00:00 PDT
my ($min_year,$min_month,$min_day) = $deleter->find_min_keep($now);
is($min_year, "2015", "min year to keep: 2015");
is($min_month, "07", "min month to keep: 07");
is($min_day, "17", "min day to keep: 15");

