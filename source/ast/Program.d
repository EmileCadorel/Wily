module ast.Program;
import std.container;
import ast.Function;
import ast.Instruction;
import syntax.Word;

class Program {

    private Word _id;
    private Array!Function _decls;
    private Array!Instruction _vars;
    private Array!Instruction _begins;

    
    this (Word id, Array!Function decls, Array!Instruction vars, Array!Instruction begins) {
	this._id = id;
	this._decls = decls;
	this._vars = vars;
	this._begins = begins;

    }

    
}
