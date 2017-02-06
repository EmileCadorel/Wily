module syntax.Tokens;
import std.typecons;

alias Token = Tuple!(string, "descr", ulong, "id");

enum Tokens : Token {
    SPACE = Token (" ", 0),
    RETOUR = Token ("\n", 1),
    RRETOUR = Token ("\r", 2),
    TAB = Token ("\t", 3),
    LCRO = Token ("[", 4),
    RCRO = Token ("]", 5),
    MINUS = Token ("-", 6),
    PLUS = Token ("+", 7),
    STAR = Token ("*", 8),
    DIV = Token ("/", 9),
    LPAR = Token ("(", 10),
    RPAR = Token (")", 11),
    INF = Token ("<", 12),
    INF_EQ = Token ("<=", 13),
    SUP = Token (">", 14),
    SUP_EQ = Token (">=", 15),
    EQUALS = Token ("=", 16),
    DIFF = Token ("<>", 17),
    AFFECT = Token (":=", 18),
    SEMI_COLON = Token (";", 19),
    COMA = Token (",", 20)
}    


