module utils.WilyException;
import utils.Colors;
import std.outbuffer, syntax.Word;
import std.stdio, std.string;

/**
 Ancêtre des erreurs de compilation.
*/
class WilyException : Exception {       
 
    this () {
	super ("");
    }

    /**
     Params:
     msg = Le message de l'erreur
     */
    this (string msg) {
	super (msg);
	this.msg = msg;
    }

    /**
     Params:
     locus = l'emplacement de la ligne
     Returns retourne la ligne x d'un fichier
     */
    private string getLine (Location locus) {
	auto file = File (locus.file, "r");
	string cline = null;
	foreach (it ; 0 .. locus.line)
	    cline = file.readln ();
	return cline;
    }

    /**
     Ajoute une ligne dans un buffer avec l'erreur en Jaune.
     Params:
     buf = le buffer a remplir
     locus = l'emplacement
     */
    protected void addLine (ref OutBuffer buf, Location locus) {
	auto line = getLine (locus);
	if (line.length > 0) {
	    auto j = 0;
	    buf.writef ("%s%s%s%s%s", line[0 .. locus.column - 1],
			Colors.YELLOW.value,
			line[locus.column - 1 .. locus.column + locus.length - 1],
			Colors.RESET.value,
			line[locus.column + locus.length - 1 .. $]);
	    if (line[$-1] != '\n') buf.write ("\n");
	    foreach (it ; 0 .. locus.column - 1) {
		if (line[it] == '\t') buf.write ('\t');
		else buf.write (' ');
	    }
	    buf.writefln ("%s", rightJustify ("", locus.length, '^'));
	} else {
	    buf.writeln ("Fin de fichier inattendue");
	}
    } 


    /**
     Ajoute une ligne dans un buffer avec l'erreur en Jaune.
     Params:
     buf = le buffer a remplir
     locus = le debut de l'emplacement
     locus2 = le deuxième emplacement
     */
    protected void addLine (ref OutBuffer buf, Location locus, Location locus2) {
	auto line = getLine (locus);
	if (line.length > 0) {
	    auto j = 0;
	    buf.writef ("%s%s%s%s%s%s%s%s%s", line[0 .. locus.column - 1],
			Colors.YELLOW.value,
			line[locus.column - 1 .. locus.column + locus.length - 1],
			Colors.RESET.value,
			line[locus.column + locus.length - 1 .. locus2.column - 1],
			Colors.YELLOW.value,
			line [locus2.column - 1 .. locus2.column + locus2.length - 1],
			Colors.RESET.value,
			line [locus2.column + locus2.length - 1 .. $]);
	    
	    if (line[$-1] != '\n') buf.write ("\n");
	    foreach (it ; 0 .. locus.column - 1) {
		if (line[it] == '\t') buf.write ('\t');
		else buf.write (' ');
	    }
	    buf.writef ("%s", rightJustify ("", locus.length, '^'));
	    foreach (it ; locus.column + locus.length - 1 .. locus2.column - 1) {
		if (line[it] == '\t') buf.write ('\t');
		else buf.write (' ');
	    }
	    buf.writefln ("%s", rightJustify ("", locus2.length, '^'));
	} else {
	    buf.writeln ("Fin de fichier inattendue");
	}
    } 

    /**
     Ajoute une ligne dans un buffer avec l'erreur en Jaune.
     Params:
     buf = le buffer a remplir
     locus = le debut de l'emplacement
     index = le decalage par rapport à l'emplacement
     lenght = la longueur de l'erreur
     */
    protected void addLine (ref OutBuffer buf, Location locus, ulong index, ulong length) {
	auto line = getLine (locus);
	if (line.length > 0) {
	    auto j = 0;
	    buf.writef ("%s%s%s%s%s", line[0 .. locus.column + index],
			Colors.YELLOW.value,
			line[locus.column + index .. locus.column + index + length],
			Colors.RESET.value,
			line[locus.column + index + length .. $]);
	    if (line[$-1] != '\n') buf.write ("\n");
	    foreach (it ; 0 .. locus.column + index) {
		if (line[it] == '\t') buf.write ('\t');
		else buf.write (' ');
	    }
	    buf.writefln ("%s", rightJustify ("", length, '^'));
	} else {
	    buf.writeln ("Fin de fichier inattendue");
	}
    } 

    /**
     Affiche le message d'erreur
     */
    void print () {
	writeln (this.msg);
    }
    

}




