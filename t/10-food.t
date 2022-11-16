#!perl
#
# Food::Ratio tests

use 5.26.0;
use Test2::V0;
use Food::Ratio;

my $fr = Food::Ratio->new;

like dies { $fr->add( undef, 'egg' ) },      qr/mass must be positive/;
like dies { $fr->add( 'li vo re', 'egg' ) }, qr/mass must be positive/;
like dies { $fr->add( -1, 'egg' ) },         qr/mass must be positive/;
like dies { $fr->add( 42, undef ) },         qr/things must be something/;
like dies { $fr->add( 42, '' ) },            qr/things must be something/;
like dies { $fr->add( 42, 'egg', undef ) },  qr/groups must be something/;
like dies { $fr->add( 42, 'egg', '' ) },     qr/groups must be something/;

# there are simpler ways to make cornmeal muffins, but the things we do
# for science...
for my $ref (
    [qw(160 cornmeal flour dry)],    # ~1 cup to grams
    [qw(150 flour flour dry)],       # ~1 cup
    [qw(11 bpowder dry)],            # 1 tablespoon
    [qw(3.5 salt dry)],
    [qw(30 sugar dry)],    # 1/4 cup loose packed
    [qw(250 milk wet)],    # 2% reduced fat, so oil percent is a bit higher
    [qw(70 oil fat wet)],
    [qw(58 egg wet)],      # 1x jumbo
) {
    $fr->add( $ref->@* );
}

like dies { $fr->ratio( id    => undef ) },       qr/id must be something/;
like dies { $fr->ratio( id    => '' ) },          qr/id must be something/;
like dies { $fr->ratio( id    => "'Iwghargh" ) }, qr/no such id/;
like dies { $fr->ratio( group => undef ) },       qr/group must be something/;
like dies { $fr->ratio( group => '' ) },          qr/group must be something/;
like dies { $fr->ratio( group => "'Iwghargh" ) }, qr/no such group/;

my $s = $fr->ratio->string;
# PORTABILITY may need to sprintf more things if that .5 is troublesome?
like $s, qr/732.5\t100%\t\*total/;

# SYNOPSIS code
my $bread = Food::Ratio->new;
$bread->add( 500,  'flour' );
$bread->add( 360,  'water' );
$bread->add( 11.5, 'salt' );
$bread->add( 2,    'yeast' );
like dies { $bread->string }, qr/ratio has not been called/;

$bread->ratio( id => 'flour' );
#diag $bread->string;
$s = $bread->string;
like $s, qr/2\t0.4%\tyeast/;

# double the yeast...
$bread->weigh( 4, id => 'yeast' );
$s = $bread->string;
like $s, qr/1000\t100%\tflour/;
#diag $bread->string;

# redo the ratio with a new key NOTE this breaks the expected ratios
# away from the Baker's Percentage
$bread->ratio;
$s = $bread->string;
like $s, qr/100%\t\*total/;

done_testing
