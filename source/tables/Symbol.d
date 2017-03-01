module tables.Symbol;
import utils.Singleton;
import tables.FrameScope;
import syntax.Word;
import utils.Colors;
import std.stdio;

enum ubyte BOOL = 0;
enum ubyte INT = 1;
alias TYPE = ubyte;

/++
+ Cette classe contient tous les symboles déclarés dans le programme
+ Il que des scopes de fonction donc pas tres complique
+/
class SymbolTable {
    mixin Singleton!SymbolTable;

    private FrameScope _currentScope;

    private this () {
	_currentScope = new FrameScope ();
    }

    void enterScope () {
	FrameScope newScope = new FrameScope (_currentScope);
	_currentScope = newScope;
    }

    void exitScope () {
	if (_currentScope)
	    _currentScope = _currentScope.parent ();
    }

    void addSymbol (Symbol s) {
	_currentScope.addSymbol (s);
    }

    Symbol getSymbol (string name) {
	return _currentScope.getSymbol (name);
    }

}

class Symbol {
    private Word _word;
    private TYPE _type;

    this (Word word, TYPE type) {
	_word = word;
	_type = type;
    }

    Word word () { 
	return _word; 
    }

    TYPE type () {
	return _type;
    }
}

