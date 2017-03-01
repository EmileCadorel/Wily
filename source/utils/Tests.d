module utils.Tests;
import std.stdio;

unittest {
    import std.container;
    import tables.Expression;
    import syntax.Word;
    import ast.all;
    import utils.Colors;

    ExpressionTable table = ExpressionTable.instance;

    immutable string fail = Colors.RED.value ~ "Test Visitor fail" ~ Colors.RESET.value;    
    auto a = Word.eof, b = Word.eof, c = Word.eof;
    a.str = "a"; b.str = "b"; c.str = "c";
    auto varA = new Var (a), varB = new Var (b), varC = new Var (c);
    auto binT = Word (Location (0, 0, 1, "", false), "+");
    auto bin = new Binary (binT, varA, varB);
    auto bin2 = new Binary (binT, varB, varC);

    table.expr.insertBack (bin);
    table.expr.insertBack (bin2);

    Array!Expression killae = table.killAE (varA);
    assert (killae.length == 1, fail);
    Array!Expression genae = table.genAE (varA, varB);
    assert (genae.length == 1, fail);

    writeln (Colors.GREEN.value, "Test ExpressionTable pass", Colors.RESET.value);
}
