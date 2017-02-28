module tables.Symbol;
import utils.Singleton;
import tables.FrameScope;
import syntax.Word;

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

    unittest {
	SymbolTable table = SymbolTable.instance;
	Word w = Word (Location (0, 0, 1, "test", true), "a");
	Word w2 = Word (Location (0, 0, 1, "test", true), "b");
	Symbol s1 = new Symbol (w, BOOL);
	Symbol s2 = new Symbol (w2, INT);

	table.addSymbol (s1);
	Symbol s = table.getSymbol ("a");
	assert (s !is null);
	assert (s.word.str == s1.word.str);
	assert (table.getSymbol ("b") is null);
	table.addSymbol (s2);
	assert (table.getSymbol ("b") !is null);
	assert (table.getSymbol ("b").word.str == s2.word.str);

	table.enterScope ();
	assert (table.getSymbol ("b") !is null);
	assert (table.getSymbol ("b").word.str == s2.word.str);
	Word w3 = Word (Location (0, 0, 1, "test", true), "c");
	Symbol s3 = new Symbol (w3, BOOL);
	table.addSymbol (s3);
	assert (table.getSymbol ("c") !is null);
	assert (table.getSymbol ("c").word.str == s3.word.str);
	table.exitScope ();
	assert (table.getSymbol ("c") is null);
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

