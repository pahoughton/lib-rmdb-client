#!/Support/bin/perl -w
#  AddTestRecs.pl
#  SMKDB
#
#  Created by Paul Houghton on 2/2/12 1:19 PM.
#  Copyright (c) 2012 Secure Media Keepers. All rights reserved.

eval 'exec /opt/local/bin/perl -w -S $0 ${1+"$@"}'
    if 0; # not running under some shell

use SMK::Config;
use DBI;

my $smk_config = new SMK::Config;

my $dbh = DBI->connect($smk_config->digit_db_dsn,
                       "paul",
                       "2sql",
                       { RaiseError => 1, AutoCommit => 1 } );

while(<>) {
    chop;
    $dbh->do( "insert into test.test ( test_vchar, ".
        "test_date, test_timestamp ) values ".
        "( '$_', now(), now() )" )
        || die "insert";
}
