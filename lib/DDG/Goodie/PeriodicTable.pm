package DDG::Goodie::PeriodicTable;
# ABSTRACT: Chemical symbols, atomic masses and numbers for chemical elements

use strict;
use DDG::Goodie;
use YAML::XS qw(Load);
use List::Util qw(first);
use Text::Trim;

zci answer_type => 'periodic_table';
zci is_cached   => 1;

name 'Periodic Table';
description 'Chemical symbols, atomic masses and numbers for chemical elements';
primary_example_queries 'rubidium', 'chemical symbol for argon', 'atomic mass of nitrogen', 'atomic number of oxygen';
secondary_example_queries 'atomic weight of Na', 'what is the chemical symbol for argon', 'chemical name for He';
category 'physical_properties';
topics 'science';
code_url 'https://github.com/duckduckgo/zeroclickinfo-goodies/blob/master/lib/DDG/Goodie/PeriodicTable.pm';
attribution github => [ 'zblair', 'Zachary D Blair' ],
            github  => ['skywickenden', 'Sky Wickenden'];

my @elements = @{ Load( scalar share('elements.yml')->slurp ) };

# Triggers
my @element_triggers = [map { lc($_->[2]) } @elements];
triggers start => $element_triggers[0];
triggers any => 'atomic mass', 'atomic weight', 'atomic number', 'proton number', 'chemical symbol', 'chemical name for';


# Handle statement
handle query_lc => sub {

    my $query = $_;

    # Determine if this is a query for atomic mass or atomic number
    my $is_mass_query = $query =~ /atomic mass|atomic weight/;
    my $is_atomic_query = $query =~ /atomic number|proton number/;

    # Strip out irrelevant words in the query
    $query =~ s/(?:atomic (?:mass|weight|number)|proton number|of|the|for|element|elemental|chemical symbol|what is|chemical name)//g;
    $query = trim $query;
    return unless $query;

    # Look for a matching element or symbol in the table
    my $match = first { lc $_->[2] eq $query || lc $_->[3] eq $query } @elements or return;
    my ( $atomic_number, $atomic_mass, $element_name, $element_symbol, $element_type ) = @{$match};

    # Default to displaying chemical symbol info.
    my $title = $element_name;
    my $subtitle = "Chemical Element";
    my $raw = "$element_symbol, chemical symbol for " . lc($element_name);
    if ($is_mass_query) {
        $title = "$atomic_mass u";
        $subtitle = "$element_name - atomic mass";
        $raw = "$element_name ($element_symbol), atomic mass $atomic_mass u"
    }
    elsif ($is_atomic_query) {
        $title = "$atomic_number";
        $subtitle = "$element_name - atomic number";
        $raw = "$element_name ($element_symbol), atomic number $atomic_number"
    }    

    # The text size of the icon needs to change depending on the length of the chemical symbol.
    my $badge_class = "";
    my $symbol_length = length($element_symbol);
    if ($symbol_length == 1) { $badge_class = "tx--25" }
    elsif ($symbol_length == 3) { $badge_class = "tx--14" }

    return $raw, 
    structured_answer => {
        id => "periodic_table",
        name => "Periodic Table",
        data => {
            badge => $element_symbol,
            title => $title,
            subtitle => $subtitle,
            url => "https://en.wikipedia.org/wiki/$element_name",
        },
        meta => {
            sourceName => "Wikipedia",
            sourceUrl => "https://en.wikipedia.org/wiki/$element_name" 
        }, 
        templates => {
            group => "icon",
            elClass => {
                bgColor => get_badge_color($element_type),
                iconBadge => "tx-clr-white $badge_class",
                iconTitle => "tx--19",
                tileSubtitle => "tx--14"
            },
            variants => {
                iconBadge => "medium"
            },           
            options => {
                moreAt => 1
            }
        }
    };   
    
};

# Decide on a color to use when displaying the element badge based on its group.
sub get_badge_color {
	my ($element_type) = @_;

    # metmetal–metalloid–nonmetal etc is currently split into only 5 color groups.
    # https://github.com/duckduckgo/zeroclickinfo-goodies/issues/927
    my $badge_color = "bg-clr--red";
    if    ($element_type eq "Alkali metal") { $badge_color = "bg-clr--gold" }
    elsif ($element_type eq "Alkaline earth metal") { $badge_color = "bg-clr--gold" }
    elsif ($element_type eq "Lanthanide") { $badge_color = "bg-clr--red" }
    elsif ($element_type eq "Actinide") { $badge_color = "bg-clr--red" }
    elsif ($element_type eq "Transition metal") { $badge_color = "bg-clr--red" }
    elsif ($element_type eq "Post-transition metal") { $badge_color = "bg-clr--green" }
    elsif ($element_type eq "Metalloid") { $badge_color = "bg-clr--green" }
    elsif ($element_type eq "Polyatomic nonmetal") { $badge_color = "bg-clr--green" }
    elsif ($element_type eq "Diatomic nonmetal") { $badge_color = "bg-clr--green" }
    elsif ($element_type eq "Noble gas") { $badge_color = "bg-clr--blue-light" }
    elsif ($element_type eq "Unknown") { $badge_color = "bg-clr--red" }

	return $badge_color;
}

1;
