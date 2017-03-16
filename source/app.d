import std.stdio;
import syntax.Visitor;
import ast.Program;
import utils.WilyException;
import dispo = analyse.disponible.Visitor;

void main(string[] args) {
    try {
	if (args.length < 2) {
	    throw new Exception ("(usage) %file");
	}
    	Visitor visitor = new Visitor (args[1]);
    	Program program = visitor.visit ();
    	program.prettyPrint ();

	auto dVisit = new dispo.Visitor ();
	auto res = dVisit (program);
	
    } catch (WilyException e) {
    	writeln (e);
    } catch (Exception e) {
	writeln (e.msg);
    }
}
