module tables.FrameScope;
import std.algorithm;
import std.container, std.array;
import tables.Symbol;
import utils.SymbolException;

class FrameScope {
    private Array!Symbol _symbols;

    void addSymbol (Symbol s) {
	if (getSymbol (s.word.str) !is null)
	    throw new MultipleDefinitionException (s.word);
	_symbols.insertBack (s);
    }

    Symbol getSymbol (string name) {
	auto it = find! ("b == a.word.str") (_symbols[], name);
	if (it.empty) {
	    return null;
	}
	return it[0];
    }
}
