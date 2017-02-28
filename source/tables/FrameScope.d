module tables.FrameScope;
import std.algorithm;
import std.container, std.array;
import tables.Symbol;
import utils.SymbolException;

class FrameScope {
    private FrameScope _parent;
    private Array!Symbol _symbols;

    this () {
	_parent = null;
    }

    this (FrameScope parent) {
	_parent = parent;
    }

    FrameScope parent () {
	return _parent;
    }

    void addSymbol (Symbol s) {
	if (getSymbol (s.word.str) !is null)
	    throw new MultipleDefinitionException (s.word);
	_symbols.insertBack (s);
    }

    Symbol getSymbol (string name) {
	auto it = find! ("b == a.word.str") (_symbols[], name);
	if (it.empty) {
	    if (_parent is null)
		return null;
	    return _parent.getSymbol (name);
	}
	return it[0];
    }
}
