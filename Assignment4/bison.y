%{
#include <bits/stdc++.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "symtable.h"

SymbolTable t;
int yylex();

#define YYSTYPE SymbolInfo
extern FILE *yyin, *yyout;
FILE* ASM;
ofstream of("code.ir");
SymbolInfo si;

void yyerror(const char* s) { printf("%s\n", s); }

int t_count = 1; // Temp variable counter
std::string new_Temp() {
    return "t" + std::to_string(t_count++);
}

FILE *lg;
%}

/* Precedence and associativity declarations */
%token NEWLINE ID LTHIRD RTHIRD COMMA KEYWORD SEMICOLON CONST_INT FLOAT LPAREN RPAREN LCURL RCURL MAIN RELOP NOT CONST_FLOAT ERROR ASSIGNOP IF ELSE
%error-verbose

%right ASSIGNOP
%left ADDOP SUBOP
%left MULOP DIVOP
%left INCOP
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

prog:
    MAIN LPAREN RPAREN LCURL stmt_list RCURL {
        fprintf(ASM, ".MODEL SMALL\n.STACK 100H\n.DATA\n");
        t.asmVariableInitializer(ASM);
        fprintf(ASM, ".CODE\nMAIN PROC\nMOV AX,@DATA\nMOV DS,AX\n\n");
        fprintf(ASM, "%s\n", si.code.c_str());
        fprintf(ASM, "MOV AH,4CH\nINT 21H\nMAIN ENDP\nEND MAIN\n");
    }
;

stmt_list:
    stmt stmt_list
    |
;

stmt:
    var_decl SEMICOLON
    | expr_decl SEMICOLON
    | expr SEMICOLON
    | if_stmt
    | NEWLINE
;

var_decl:
    type_spec decl_list
;

type_spec:
    KEYWORD
;

decl_list:
    term
    | term ASSIGNOP expr
    | term COMMA decl_list
;

expr:
    CONST_INT { $$ = yylval; }
    | CONST_FLOAT { $$ = yylval; }
    | expr ADDOP expr {
        std::string temp = new_Temp();
        $$ = SymbolInfo(temp, "");
        of << $$.getSymbol() << " = " << $1.getSymbol() << " + " << $3.getSymbol() << endl;
        si.concatCode("MOV ", "AL", $1.getSymbol());
        si.concatCode("MOV", "BL", $3.getSymbol());
        si.concatCode("ADD", "AL", "BL");
        si.concatCode("MOV", $$.getSymbol(), "AL");
    }
    | expr SUBOP expr {
        std::string temp = new_Temp();
        $$ = SymbolInfo(temp, "");
        of << $$.getSymbol() << " = " << $1.getSymbol() << " - " << $3.getSymbol() << endl;
        si.concatCode("MOV", "AL", $1.getSymbol());
        si.concatCode("MOV", "BL", $3.getSymbol());
        si.concatCode("SUB", "AL", "BL");
        si.concatCode("MOV", $$.getSymbol(), "AL");
    }
    | expr MULOP expr {
        std::string temp = new_Temp();
        $$ = SymbolInfo(temp, "");
        of << $$.getSymbol() << " = " << $1.getSymbol() << " * " << $3.getSymbol() << endl;
        si.concatCode("MOV", "AL", $1.getSymbol());
        si.concatCode("MOV", "BL", $3.getSymbol());
        si.concatCode("MUL", "BL");
        si.concatCode("MOV", $$.getSymbol(), "AL");
    }
    | expr DIVOP expr {
        std::string temp = new_Temp();
        $$ = SymbolInfo(temp, "");
        of << $$.getSymbol() << " = " << $1.getSymbol() << " / " << $3.getSymbol() << endl;
        si.concatCode("MOV", "AL", $1.getSymbol());
        si.concatCode("MOV", "BL", $3.getSymbol());
        si.concatCode("DIV", "BL");
        si.concatCode("MOV", $$.getSymbol(), "AL");
    }
    | LPAREN expr RPAREN {
        $$ = $2;
    }
    | term
;

term:
    ID {
        $$ = SymbolInfo($1.getSymbol(), "ID");
        t.insert($$);
    }
;

expr_decl:
    term ASSIGNOP expr {
        of << $1.getSymbol() << " = " << $3.getSymbol() << endl;
        si.concatCode("MOV", "AL", $3.getSymbol());
        si.concatCode("MOV", $1.getSymbol(), ", AL");
    }
;

if_stmt:
    IF LPAREN expr RPAREN stmt %prec LOWER_THAN_ELSE
    | IF LPAREN expr RPAREN stmt ELSE stmt
;

%%

int main() {
    ASM = fopen("code.asm", "w");
    if (!ASM) {
        perror("Failed to open code.asm");
        return 1;
    }
    yyin = fopen("input.txt", "r");
    if (!yyin) {
        perror("Failed to open input.txt");
        return 1;
    }
    yyout = fopen("log_error.txt", "w");
    if (!yyout) {
        perror("Failed to open log_error.txt");
        return 1;
    }
    lg = fopen("log.txt", "w");
    if (!lg) {
        perror("Failed to open log.txt");
        return 1;
    }
    yyparse();
    fclose(yyin);
    fclose(yyout);
    fclose(lg);
    fclose(ASM);
}
