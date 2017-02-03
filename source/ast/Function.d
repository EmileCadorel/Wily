module ast.Function;
import std.container;
import ast.Instruction;
import ast.VarDecl;
import syntax.Word;

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
    
}
