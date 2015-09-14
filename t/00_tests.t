use strict;
use warnings;

use Test::More tests => 18;

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

# test how far back to delete
my $now = localtime(1438430400); # Aug 1st 2015 05:00:00 PDT
my ($min_year,$min_month,$min_day) = $deleter->find_min_keep($now);
is($min_year, "2015", "min year to keep: 2015");
is($min_month, "07", "min month to keep: 07");
is($min_day, "17", "min day to keep: 15");

my ($dataset,$year,$month,$day) = $deleter->clean_and_split_path("t/test_data/foo/2014/06/01");
is($dataset, "foo", "clean and split dataset: foo");
is($year, "2014", "clean and split year: 2014");
is($month, "06", "clean and split month: 06");
is($day, "01", "clean and split day: 01");

my @paths = $deleter->get_paths_to_delete($min_year,$min_month,$min_day);

# check path integrity
is(@paths, 34, "found 34 paths to delete");
is(grep(/^foo\/2015\/06$/, @paths),1, "contains foo/2015/06");
is(grep(/^bar\/2015\/07\/16$/, @paths),1, "contains bar/2015/07/16");
is(grep(/^bar\/2015\/07\/17$/, @paths),0, "does not contain bar/2015/07/17");

# try with only 1 dataset
$deleter = App::DeleteOldData->new( %base_options, dataset_name => "foo");
@paths = $deleter->get_paths_to_delete($min_year,$min_month,$min_day);
is(grep(/^bar\/2015\/07\/16$/, @paths),0, "does not contain bar/2015/07/16");

#lets do it for real
$deleter->remove_paths(@paths);
is(-d "t/test_data/foo/2015/06",undef,"foo/2015/06 deleted");
is(-d "t/test_data/bar/2015/06",1,"bar/2015/06 not deleted");
is(-d "t/test_data/foo/2015/07/16",undef,"foo/2015/07/16 deleted");
is(-d "t/test_data/foo/2015/07/17",1,"foo/2015/07/17 not deleted");


