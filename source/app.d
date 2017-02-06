import std.stdio;
import syntax.Visitor;
import ast.Program;
import utils.WilyException;

int main(string[] args)
{

    if (args.length < 2) {
	writeln ("File name expected !");
	return -1;
    }

    try {
	Visitor visitor = new Visitor (args[1]);
	Program program = visitor.visit ();
	program.print ();
    } catch (WilyException e) {
	writeln (e);
    }

    return 0;
}
