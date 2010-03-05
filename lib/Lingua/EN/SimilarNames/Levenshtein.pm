package Lingua::EN::SimilarNames::Levenshtein;

use MooseX::Declare;
use Text::LevenshteinXS qw(distance);
use Math::Combinatorics;
use strict;
use warnings;
use 5.010;

our $VERSION = '0.01';

=head1 Name
 
Lingua::EN::SimilarNames::Levenshtein - Compare people first and last names.

=head1 Synopsis

    my $first_person = Person->new(
        first_name => 'John',
        last_name => 'Wayne',
    );
    my $second_person = Person->new(
        first_name => 'Sundance',
        last_name => 'Kid',
    );
    my $third_person = Person->new(
        first_name => 'Jose',
        last_name => 'Wales',
    );
    my @list_of_people = ($first_person, $second_person, $third_person);
    my $similar_people = SimilarNames->new(list_of_people => \@list_of_people, maximum_distance => 12);
 
=head1 Description
 
Given a list of people names as an ArrayRef[ArrayRef[Str]],
then have access to the list of people name pairs that are 
within a certain 'edit distance' of on another.
 
=cut

class Person {
	has 'first_name' => ( isa => 'Str', is => 'ro', default => '' );
	has 'last_name'  => ( isa => 'Str', is => 'ro', default => '' );
	has 'full_name'  => (
		isa        => 'Str',
		is         => 'ro',
		lazy_build => 1,
	);
	
	method say_name() {
		say $self->full_name;
	} 
    
    method _build_full_name {
		return $self->first_name . ' ' . $self->last_name;
	}
}

class CompareTwoNames {
	has 'one_person'     => ( isa => 'Person', is => 'rw' );
	has 'another_person' => ( isa => 'Person', is => 'rw' );
	has 'distance_between' => (
		isa        => 'Int',
		is         => 'ro',
		lazy_build => 1,
	);

	method _build_distance_between() {
		return Text::LevenshteinXS::distance( $self->one_person->first_name,
			$self->another_person->first_name ) +
		  Text::LevenshteinXS::distance( $self->one_person->last_name,
			$self->another_person->last_name );
	}
}

class SimilarNames {
	has 'list_of_people' => ( 
	   isa => 'ArrayRef[Person]', 
	   is => 'ro', lazy_build => 1 
	);
	has 'minimum_distance' => ( isa => 'Int', is => 'rw', default => 1 );
	has 'maximum_distance' => ( isa => 'Int', is => 'rw', default => 3 );
	has 'list_of_similar_names' => ( 
	    isa => 'ArrayRef[ArrayRef[ArrayRef[Str]]]', 
        is => 'ro', 
        lazy_build => 1 
    );
    
    method _build_list_of_similar_names() {
        my $people_tuples = Math::Combinatorics->new(
            count => 2,  # This should be abstracted                               
            data  => $self->list_of_people,
        );
        my @list_of_similar_name_pairs;
        while ( my ( $first_person, $second_person ) = $people_tuples->next_combination() ) {
            my $name_comparison = CompareTwoNames->new(
                one_person     => $first_person,
                another_person => $second_person,
            );
            my $distance_between_names = $name_comparison->distance_between();
            if ( ($distance_between_names >= $self->minimum_distance) && ($distance_between_names <= $self->maximum_distance) ) {
                push @list_of_similar_name_pairs, 
                  [[$first_person->first_name, $first_person->last_name],
                  [$second_person->first_name, $second_person->last_name]];
            }
        }
       
        return \@list_of_similar_name_pairs
    }
}

__END__

=head1 Methods
 
=head2 list_of_similar names

This is called on a SimilarNames object
to return list of name pairs that are similar
using the Levenshtein edit distance.  This means 
they are close to one another in spelling.
 
=head1 Authors
 
Mateu X. Hunter C<hunter@missoula.org>
 
=head1 Copyright
 
Copyright 2010, Mateu X. Hunter
 
=head1 License
 
You may distribute this code under the same terms as Perl itself.

=cut

1
