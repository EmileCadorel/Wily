module tables.Symbol;
import utils.Singleton;
import tables.FrameScope;
import syntax.Word;
import utils.Colors;
import std.container;
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

    private SList!FrameScope _currentScope;

    private this () {
	_currentScope.insertFront(new FrameScope ());
    }

    void enterScope () {
	this._currentScope.insertFront (new FrameScope);
    }

    void exitScope () {
	if (!_currentScope.empty)
	    _currentScope.removeFront ();
    }

    void addSymbol (Symbol s) {
	_currentScope.front.addSymbol (s);
    }

    Symbol getSymbol (string name) {
	return _currentScope.front.getSymbol (name);
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

