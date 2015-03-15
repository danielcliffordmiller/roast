﻿use Test;

plan 107;

# Basic native int array tests.
{
    ok array[int] ~~ Positional, 'Native int array type is Positional';
    ok array[int] ~~ Positional[int], 'Native int array type is Positional[int]';
    ok array[int].of === int, 'Native int array type .of is int';
    ok array[int].new ~~ Positional, 'Native int array is Positional';
    ok array[int].new ~~ Positional[int], 'Native int array is Positional[int]';
    ok array[int].new.of === int, 'Native int array .of is int';

    my @arr := array[int].new;
    is @arr.elems, 0, 'New native int array has no elems';
    is @arr.end, -1, 'New native int array has end of -1';
    is @arr.Int, 0, 'New native int arrray Int-ifies to 0';
    is +@arr, 0, 'New native int arrray numifies to 0';
    nok @arr, 'New native int array is falsey';
    nok @arr.infinite, 'Empty native int array is not infinite';

    is @arr[5], 0, 'Accessing non-existing element gives 0';
    is @arr.elems, 0, 'The elems do not grow just from an access';

    lives_ok { @arr[0] = 42 }, 'Can store integer in an int array';
    is @arr[0], 42, 'Can get value from int array';
    is @arr.elems, 1, 'The elems grew as expected';
    ok @arr, 'Array becomes truthy when it has an element';

    lives_ok { @arr[1, 2] = 69, 70 }, 'Can slice-assign to an int array';
    is @arr[1], 69, 'Can get slice-assigned value from int array (1)';
    is @arr[2], 70, 'Can get slice-assigned value from int array (2)';
    is @arr.elems, 3, 'The elems grew as expected';
    is @arr.end, 2, 'The end value matches grown elems';
    is @arr.Int, 3, 'Int-ifies to grown number of elems';
    is +@arr, 3, 'Numifies to grown number of elems';
    nok @arr.infinite, 'Native int array with values is not infinite';

    lives_ok { @arr[10] = 100 }, 'Can assign non-contiguously';
    is @arr[9], 0, 'Elements behind non-contiguous assignment are 0';
    is @arr[10], 100, 'Non-contiguous assignment works';

    lives_ok { @arr = () }, 'Can clear array by assigning empty list';
    is @arr.elems, 0, 'Cleared native int array has no elems';
    is @arr.end, -1, 'Cleared native int array has end of -1';
    is @arr.Int, 0, 'Cleared native int arrray Int-ifies to 0';
    is +@arr, 0, 'Cleared native int arrray numifies to 0';
    nok @arr, 'Cleared native int array is falsey';

    lives_ok { @arr = 1..50 }, 'Can assign integer range to int array';
    is @arr.elems, 50, 'Got correct number of elems from range assign';
    is @arr[0], 1, 'Got a correct element from range assign (1)';
    is @arr[49], 50, 'Got a correct element from range assign (2)';

    ok @arr[0]:exists, ':exists works on native int array (1)';
    ok @arr[49]:exists, ':exists works on native int array (2)';
    nok @arr[50]:exists, ':exists works on native int array (3)';

    lives_ok { @arr := array[int].new(10, 15, 12) },
        'Can call native int array constructor with values';
    is @arr.elems, 3, 'Correct number of elements set in constructor';
    is @arr[0], 10, 'Correct element value set by constructor (1)';
    is @arr[1], 15, 'Correct element value set by constructor (2)';
    is @arr[2], 12, 'Correct element value set by constructor (3)';

    ok @arr.flat === @arr, 'Native int array .flat returns identity';
    ok @arr.list === @arr, 'Native int array .list returns identity';
    ok @arr.eager === @arr, 'Native int array .eager returns identity';

    my int $total;
    for @arr {
        $total += $_;
    }
    is $total, 37, 'Can iterate over native int array';

    $_++ for @arr;
    is @arr[0], 11, 'Mutating for loop on native int array works (1)';
    is @arr[1], 16, 'Mutating for loop on native int array works (2)';
    is @arr[2], 13, 'Mutating for loop on native int array works (3)';

    @arr.map(* *= 2);
    is @arr[0], 22, 'Mutating map on native int array works (1)';
    is @arr[1], 32, 'Mutating map on native int array works (2)';
    is @arr[2], 26, 'Mutating map on native int array works (3)';

    is @arr.grep(* < 30).elems, 2, 'Can grep a native int array';
    is ([+] @arr), 80, 'Can use reduce meta-op on a native int array';

    @arr = ();
    dies_ok { @arr.pop }, 'Trying to pop an empty native int array dies';
    dies_ok { @arr.shift }, 'Trying to shift an empty native int array dies';

    @arr.push(42);
    is @arr.elems, 1, 'push to native int array works (1)';
    is @arr[0], 42, 'push to native int array works (2)';
    dies_ok { @arr.push('it real good') },
        'Cannot push non-int/Int to int native array';

    @arr.push(101, 105);
    is @arr.elems, 3, 'push multiple to native int array works (1)';
    is @arr[1], 101, 'push multiple to native int array works (2)';
    is @arr[2], 105, 'push multiple to native int array works (3)';
    dies_ok { @arr.push('omg', 'wtf') },
        'Cannot push non-int/Int to int native array (multiple push)';

    is @arr.pop, 105, 'pop from native int array works (1)';
    is @arr.elems, 2, 'pop from native int array works (2)';

    @arr.unshift(-1);
    is @arr.elems, 3, 'unshift to native int array works (1)';
    is @arr[0], -1, 'unshift to native int array works (2)';
    is @arr[1], 42, 'unshift to native int array works (3)';
    dies_ok { @arr.unshift('the part of the day you are not working') },
        'Cannot unshift non-int/Int to int native array';

    @arr.unshift(-3, -2);
    is @arr.elems, 5, 'unshift multiple to native int array works (1)';
    is @arr[0], -3, 'unshift multiple to native int array works (2)';
    is @arr[1], -2, 'unshift multiple to native int array works (3)';
    is @arr[2], -1, 'unshift multiple to native int array works (4)';
    is @arr[3], 42, 'unshift multiple to native int array works (5)';
    dies_ok { @arr.unshift('wtf', 'bbq') },
        'Cannot unshift non-int/Int to int native array (multiple unshift)';

    is @arr.shift, -3, 'shift from native int array works (1)';
    is @arr.elems, 4, 'shift from native int array works (2)';

    @arr = 1..10;
    my @replaced = @arr.splice(3, 2, 98, 99, 100);
    is @arr.elems, 11, 'Correct number of elems after splice native int array';
    is @arr[2], 3, 'Splice did the right thing (1)';
    is @arr[3], 98, 'Splice did the right thing (2)';
    is @arr[4], 99, 'Splice did the right thing (3)';
    is @arr[5], 100, 'Splice did the right thing (4)';
    is @arr[6], 6, 'Splice did the right thing (5)';
    is @replaced.elems, 2, 'Correct number of returned spliced values';
    is @replaced[0], 4, 'Correct value in splice returned array (1)';
    is @replaced[1], 5, 'Correct value in splice returned array (2)';

    @arr = 1..5;
    is @arr.Str, '1 2 3 4 5', '.Str space-separates';
    is @arr.gist, '1 2 3 4 5', '.gist space-separates';
    is @arr.perl, 'array[int].new(1, 2, 3, 4, 5)', '.perl includes type and int values';

    sub ftest(int $a, $b) {
        $a + $b
    }
    @arr = 39, 3;
    is ftest(|@arr), 42, 'Flattening native int array in call works';
}

# Interaction of native int arrays and untyped arrays.
{
    my @native := array[int].new(1..10);

    my @untyped = @native;
    is @untyped.elems, 10, 'List-assigning native int array to untyped works (1)';
    is @untyped[0], 1, 'List-assigning native int array to untyped works (2)';
    is @untyped[9], 10, 'List-assigning native int array to untyped works (3)';

    @untyped = 0, @native, 11;
    is @untyped.elems, 12, 'List-assigning native int array surrounded by literals works (1)';
    is @untyped[0], 0, 'List-assigning native int array surrounded by literals works (2)';
    is @untyped[5], 5, 'List-assigning native int array surrounded by literals works (3)';
    is @untyped[10], 10, 'List-assigning native int array surrounded by literals works (4)';
    is @untyped[11], 11, 'List-assigning native int array surrounded by literals works (5)';

    my @untyped2 = 21..30;
    my @native2 := array[int].new;
    @native2 = @untyped2;
    is @native2.elems, 10, 'List-assigning untyped array of Int to native int array works (1)';
    is @native2[0], 21, 'List-assigning untyped array of Int to native int array works (2)';
    is @native2[9], 30, 'List-assigning untyped array of Int to native int array works (3)';

    @untyped2.push('C-C-C-C-Combo Breaker!');
    dies_ok { @native2 = @untyped2 },
        'List-assigning incompatible untyped array to native int array dies';
}