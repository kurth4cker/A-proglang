# programs
CC = cc
FLEX = flex
YACC = bison

# CFLAGS = -Wall -pedantic-errors -std=gnu99
CFLAGS += -D_POSIX_C_SOURCE=200809L -D_GNU_SOURCE
CFLAGS += -D_FILE_OFFSET_BITS=64 -Iinclude
CFLAGS += -lm 
LIBS = -lfl -lm
YACCFLAGS += -Wcounterexamples

# Variables
LEXER = Lexer/lexer.l
PARSER = Parser/parser.y
LEX_OUTPUT = Lexer/lex.yy.c
PARSER_OUTPUT = Parser/parser.tab.c
PARSER_HEADER = Parser/parser.tab.h
LEX_HEADER = Lexer/lex.yy.h
EXEC = parser
TEST_FILE = tests/test.alan

# Targets
all: $(EXEC)

# Generate lexer and parser files
$(LEX_OUTPUT): $(LEXER)
	$(FLEX) --header-file=$(LEX_HEADER) -o $(LEX_OUTPUT) $(LEXER)

$(PARSER_OUTPUT): $(PARSER)
	# $(YACC) -d -o $(PARSER_OUTPUT) $(PARSER)
	$(YACC) -d $(YACCFLAGS) -o $(PARSER_OUTPUT) $(PARSER)

# Compile all source files
$(EXEC): $(LEX_OUTPUT) $(PARSER_OUTPUT) $(PARSER_HEADER) $(LEX_HEADER) src/symbol_table.c src/variables.c src/utils.c src/logical.c
	$(CC) $(LEX_OUTPUT) $(PARSER_OUTPUT) src/symbol_table.c src/variables.c src/utils.c src/logical.c -o $(EXEC) $(CFLAGS) $(LIBS)

# Run the parser with test file
test: $(EXEC)
	./$(EXEC) $(TEST_FILE)

# Clean generated files
clean:
	rm -f $(LEX_OUTPUT) $(PARSER_OUTPUT) $(PARSER_HEADER) $(LEX_HEADER) Lexer/lex.yy.c Parser/parser.tab.* $(EXEC) *.o

# Run parser
run: $(EXEC)
	./$(EXEC)

# Valgrind memory check
memcheck: $(EXEC)
	valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes ./$(EXEC)

.PHONY: all clean run test memcheck
