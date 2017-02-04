module ast.Function;
import std.container;
import ast.Instruction;
import ast.VarDecl;
import syntax.Word;
import std.stdio, std.string;

class Function {

    private Word _id;
    private Array!VarDecl _params;
    private VarDecl _ret;
    private Array!Instruction _insts;

    
    this (Word id, Array!VarDecl params, VarDecl ret, Array!Instruction insts) {
	this._id = id;
	this._params = params;
	this._ret = ret;
	this._insts = insts;				 
    }

    void print (int nb = 0) {
	writefln ("%s<Function> : %s(%d, %d) %s ", rightJustify ("", nb, ' '),
		  this._id.locus.file,
		  this._id.locus.line, 
		  this._id.locus.column,
		  this._id.str);
	
	foreach (it ; this._params)
	    it.print (nb + 4);
	
	this._ret.print (nb + 4);
	
	foreach (it ; this._insts)
	    it.print (nb + 4);
    }    
}
