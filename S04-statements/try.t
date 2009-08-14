use v6;

use Test;

# L<S04/"Statement parsing"/"or try {...}">

plan 28;

{
    # simple try
    my $lived = undef;
    try { die "foo" };
    is($!, "foo", "error var was set");
};

# try should work when returning an array or hash
{
    my @array = try { 42 };
    is +@array,    1, '@array = try {...} worked (1)';
    is ~@array, "42", '@array = try {...} worked (2)';
}

{
    my @array = try { (42,) };
    is +@array,    1, '@array = try {...} worked (3)';
    is ~@array, "42", '@array = try {...} worked (4)';
}

{
    my %hash = try { 'a', 1 };
    is +%hash,        1, '%hash = try {...} worked (1)';
    is ~%hash.keys, "a", '%hash = try {...} worked (2)';
}

{
    my %hash = try { hash("a", 1) };
    is +%hash,        1, '%hash = try {...} worked (5)';
    is ~%hash.keys, "a", '%hash = try {...} worked (6)';
}

#?pugs todo 'bug'
{
    my %hash;
    # Extra try necessary because current Pugs dies without it.
    try { %hash = try { a => 3 } };
    is +%hash,        1, '%hash = try {...} worked (7)';
    is ~%hash.keys, "a", '%hash = try {...} worked (8)';
    is ~%hash<a>,     3, '%hash = try {...} worked (9)';
}

#?pugs todo
{
    # try with a catch
    my $caught;
    try {
        die "blah";

        CATCH { $caught = 1 }
    };

    ok($caught, "exception caught");
};

# return inside try{}-blocks
# PIL2JS *seems* to work, but it does not, actually:
# The "return 42" works without problems, and the caller actually sees the
# return value 42. But when the end of the test is reached, &try will
# **resume after the return**, effectively running the tests twice.
# (Therefore I moved the tests to the end, so not all tests are rerun).

#?rakudo todo "try catches return exception"
{
    my $was_in_foo = 0;
    sub foo {
        $was_in_foo++;
        try { return 42 };
        $was_in_foo++;
        return 23;
    }
    is foo(), 42,      'return() inside try{}-blocks works (1)';
    is $was_in_foo, 1, 'return() inside try{}-blocks works (2)';
}

{
    sub test1 {
        try { return 42 };
        return 23;
    }

    sub test2 {
        test1();
        die 42;
    }

    dies_ok { test2() },
        "return() inside a try{}-block should cause following exceptions to really die";
}

#unless eval 'Exception.new' {
#    skip_rest "No Exception objects"; exit;
#}

{
    # exception classes
    class Naughty is Exception {};

    my ($not_died, $caught);
    try {
        die Naughty("error");

        $not_died = 1;

        CATCH {
            when Naughty {
                $caught = 1;
            }
        }
    };

    ok(!$not_died, "did not live after death");
    #?pugs 1 todo
    #?rakudo todo 'smart matching against exception'
    ok($caught, "caught exception of class Naughty");
};

{
    # exception superclass
    class Naughty::Specific is Naughty {};
    class Naughty::Other is Naughty {};

    my ($other, $naughty);
    try {
        die Naughty::Specific("error");

        CATCH {
            when Naughty::Other {
                $other = 1;
            }
            when Naughty {
                $naughty = 1;
            }
        }
    };

    ok(!$other, "did not catch sibling error class");
    #?pugs 1 todo
    #?rakudo todo 'smart matching against exception'
    ok($naughty, "caught superclass");
};

{
    # uncaught class
    class Dandy is Exception {};

    my ($naughty, $lived);
    eval '
        try {
            die Dandy("error");

            CATCH {
                when Naughty {
                    $naughty = 1;
                }
            }
        };
        $lived = 1;
    ';

    #?rakudo todo 'try/CATCH'
    ok(!$lived, "did not live past uncaught throw in try");
    ok(~WHAT($!), '$! is an object');
    ok(!$naughty, "did not get caught by wrong handler");
    #?pugs skip 'bug'
    #?rakudo todo 'Exception types'
    is(WHAT($!), Dandy, ".. of the right class");
};

#?rakudo todo 'CATCH block catching its own exceptions (RT #64262)'
{
    my $catches = 0;
    try {
        try {
            die 'catch!';
            CATCH {
                die 'caught' if ! $catches++;
            }
        }
    }
    is $catches, 1, 'CATCH does not catch exceptions thrown within it';
}

{
    my $catches = 0;
    sub rt63430 {
        try {
            return 63430;
            CATCH { return 73313 if ! $catches++; }
        }
    }

    #?rakudo skip 'Null PMC access'
    is rt63430().perl, 63430.perl, 'can call rt63430() and examine the result';
    #?rakudo skip 'Null PMC access in type()'
    is rt63430(), 63430, 'CATCH does not intercept return from try block';
    #?rakudo todo 'RT #63430'
    is $catches, 0, 'CATCH block never invoked';
}

# vim: ft=perl6
