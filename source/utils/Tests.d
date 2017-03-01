module utils.Tests;

unittest {
    import std.stdio;
    import tables.Symbol;
    import utils.Colors;
    import syntax.Word;
    
    immutable string fail = Colors.RED.value ~ "Test Symbol fail" ~ Colors.RESET.value;
	
    SymbolTable table = SymbolTable.instance;
    Word w = Word (Location (0, 0, 1, "test", true), "a");
    Word w2 = Word (Location (0, 0, 1, "test", true), "b");
    Symbol s1 = new Symbol (w, BOOL);
    Symbol s2 = new Symbol (w2, INT);

    table.addSymbol (s1);
    Symbol s = table.getSymbol ("a");
    assert (s !is null);
    assert (s.word.str == s1.word.str);
    assert (table.getSymbol ("b") is null, fail);
    table.addSymbol (s2);
    assert (table.getSymbol ("b") !is null, fail);
    assert (table.getSymbol ("b").word.str == s2.word.str, fail);

    table.enterScope ();
    assert (table.getSymbol ("b") !is null, fail);
    assert (table.getSymbol ("b").word.str == s2.word.str, fail);
    Word w3 = Word (Location (0, 0, 1, "test", true), "c");
    Symbol s3 = new Symbol (w3, BOOL);
    table.addSymbol (s3);
    assert (table.getSymbol ("c") !is null, fail);
    assert (table.getSymbol ("c").word.str == s3.word.str, fail);
    table.exitScope ();
    assert (table.getSymbol ("c") is null, fail);
    writeln (Colors.GREEN.value, "Test Symbol table pass", Colors.RESET.value);
}

unittest {
    import std.stdio;
    import utils.Colors, syntax.Word;
    import ast.all;
    import analyse.parent.Visitor;
    
    immutable string fail = Colors.RED.value ~ "Test Visitor fail" ~ Colors.RESET.value;
    auto a = Word.eof, b = Word.eof;
    a.str = "a"; b.str = "b";
    
    auto varA = new Var (a), varB = new Var (b);
    assert (!Visitor.equals (varA, varB), fail);
    assert (Visitor.equals (varA, varA), fail);

    
    auto aff = new Affect (Word.eof, varA, varB);
    assert (Visitor.contain (aff, varA), fail);

    auto binT = Word (Location (0, 0, 1, "", false), "+");
    auto dec = Word (Location (0, 0, 3, "", false), "123");
    auto bin = new Binary (binT, varA, varB);
    
    auto bin2 = new Binary (binT, bin, new Int (dec));
    assert (Visitor.contain (bin2, varB), fail);

    writeln (Colors.GREEN.value, "Test Visitor pass", Colors.RESET.value);
}

