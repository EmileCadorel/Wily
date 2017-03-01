import std.stdio;
import syntax.Visitor;
import ast.Program;
import utils.WilyException;

void main(string[] args) {


    import std.stdio;
    import utils.Colors, syntax.Word;
    import ast.all;
    import parent = analyse.parent.Visitor;
    
    immutable string fail = Colors.RED.value ~ "Test Visitor fail" ~ Colors.RESET.value;
    auto a = Word (Location (0, 0, 1, "", false), "a");
    auto b = Word (Location (0, 0, 1, "", false), "b");
    
    auto varA = new Var (a), varB = new Var (b);
    assert (!parent.Visitor.equals (varA, varB), fail);
    
    // if (args.length < 2) {
    // 	writeln ("File name expected !");
    // 	return -1;
    // }

    // try {
    // 	Visitor visitor = new Visitor (args[1]);
    // 	Program program = visitor.visit ();
    // 	program.print ();
    // } catch (WilyException e) {
    // 	writeln (e);
    // }

    // return 0;
}
