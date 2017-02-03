module syntax.Keys;
import syntax.Tokens;
import std.typecons;

enum Keys : Token  {
    PROGRAM = Token ("program", 0),
    BEGIN = Token ("begin", 1),
    END = Token ("end", 2),
    PROC = Token ("proc", 3),
    RES = Token ("res", 4),
    INT = Token ("int", 5),
    BOOL = Token ("boolean", 6),
    SKIP = Token ("skip", 7),
    IF = Token ("if", 8),
    THEN = Token ("then", 9),
    ELSE = Token ("else", 10),
    WHILE = Token ("while", 11),
    DO = Token ("do", 12),
    CALL = Token ("call", 13),
    TRUE = Token ("true", 14),
    FALSE = Token ("false", 15),
    NOT = Token ("not", 16)
}
