module ast.Skip;
import ast.Instruction;
import syntax.Word;

class Skip : Instruction {

    this (Word id) {
	super (id);
    }

}
