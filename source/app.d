import std.stdio;
import syntax.Visitor;
import ast.Program;
import utils.WilyException;

void main(string[] args) {
    try {
	if (args.length < 2) {
	    throw new Exception ("(usage) %file");
	}
    	Visitor visitor = new Visitor (args[1]);
    	Program program = visitor.visit ();
    	program.print ();
    } catch (WilyException e) {
    	writeln (e);
    } catch (Exception e) {
	writeln (e.msg);
    }
}
