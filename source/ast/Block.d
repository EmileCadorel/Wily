module ast.Block;
import ast.Instruction;
import std.container, syntax.Word;

class Block : Instruction {
    
    Array!Instruction _insts;
    
    this (Word token, Array!Instruction insts) {
	super (token);
	this._insts = insts;
    }
    
}
