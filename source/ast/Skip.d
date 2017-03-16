module ast.Skip;
import ast.Instruction;
import syntax.Word;
import std.string;
import std.stdio;

class Skip : Instruction {

    this (Word id) {
	super (id);
    }

    override void prettyPrint (int nb = 0) {
	writef ("%sskip", rightJustify ("", nb, ' '));
    }


    override void prettyPrint (OutBuffer buf, int nb = 0) {
	buf.writef ("%sskip", rightJustify ("", nb, ' '));
    }

    
}
