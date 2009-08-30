########################################################################
# SGML spell-check filter
#
# Copyright 2002 by Peter Eisentraut <peter_e@gmx.net>
########################################################################

use SGMLS;			# Use the SGMLS package.
use SGMLS::Output;		# Use stack-based output.

if ($ARGV[0]) {
    open(INFILE, $ARGV[0]) or die;
    @elements_skip = <INFILE>;
    chomp @elements_skip;
    close(INFILE);
}

#
# Element handler
#

sgml('start_element', sub {
    my ($element,$event) = @_;

    if (grep { uc($_) eq uc($element->name) } @elements_skip) {
        push_output('nul');
    } else {
        output(' ');
    }
});

sgml('end_element', sub {
    my ($element,$event) = @_;

    if (grep { uc($_) eq uc($element->name) } @elements_skip) {
        pop_output();
    } else {
        output(' ');
    }
});


#
# SDATA Handler
#

sgml('sdata', "");


#
# CDATA handler
#

sgml('cdata',sub {
    my ($data,$event) = @_;

    if (defined $event->file && defined $event->line
        && ($current_file ne $event->file || $current_line ne $event->line)) {
        $current_file = $event->file;
        $current_line = $event->line;
        output "\n# $current_file:$current_line\n";
    }

    $data =~ tr/\r\n//d;
    output "\n^$data";
});


1;
