module utils.SymbolException;
import utils.WilyException;
import utils.Colors;
import syntax.Word;
import std.outbuffer, std.conv;

class MultipleDefinitionException : WilyException {

    this (Word word) {
	OutBuffer buf = new OutBuffer ();
	buf.write (Colors.RED.value);
	buf.write ("Multiple definition " ~ Colors.RESET.value ~ ":");
	buf.write (word.locus.file);
	buf.write (":(" ~ to!string(word.locus.line) ~ ", " ~ to!string(word.locus.column) ~ ") : ");
	buf.write ("'" ~ word.str ~ "'\n");
	super.addLine (buf, word.locus);
	msg = buf.toString ();
    }

}
