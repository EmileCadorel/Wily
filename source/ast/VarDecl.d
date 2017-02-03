module ast.VarDecl;
import std.container;
import ast.Instruction;
import syntax.Word;

class VarDecl : Instruction {

    private Array!Word _names;
   
    this (Word type, Array!Word names) {
	super (type);
	this._names = names;
    }

}
