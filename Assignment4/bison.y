%{
#include <bits/stdc++.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "symtable.h"

FILE *logFile;
SymbolTable t;
int yylex();

#define YYSTYPE SymbolInfo
extern FILE *yyin, *yyout;
FILE* ASM;
ofstream of("code.ir");
SymbolInfo si;

void yyerror(const char* s) { printf("%s\n", s); }

int t_count = 1;
int label_count = 1;
std::string new_Temp() {
    return "t" + std::to_string(t_count++);
}

std::string new_Label() {
    return "L" + std::to_string(label_count++);
}

FILE *lg;
%}

%token NEWLINE ID LTHIRD RTHIRD COMMA KEYWORD SEMICOLON CONST_INT FLOAT LPAREN RPAREN LCURL RCURL MAIN RELOP NOT CONST_FLOAT ERROR ASSIGNOP IF ELSE
%error-verbose

%right ASSIGNOP
%left ADDOP SUBOP
%left MULOP DIVOP
%left INCOP
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%nonassoc RELOP

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
    expr ADDOP term {
        std::string temp = new_Temp();
        $$ = SymbolInfo(temp, "");
        of << $$.getSymbol() << " = " << $1.getSymbol() << " + " << $3.getSymbol() << endl;
        si.concatCode("MOV ", " AX, ", $1.getSymbol());
        si.concatCode("MOV ", " BX, ", $3.getSymbol());
        si.concatCode("ADD ", " AX, ", " BX ");
        si.concatCode("MOV ", $$.getSymbol(), " , AX");
    }
    | expr SUBOP term {
        std::string temp = new_Temp();
        $$ = SymbolInfo(temp, "");
        of << $$.getSymbol() << " = " << $1.getSymbol() << " - " << $3.getSymbol() << endl;
        si.concatCode("MOV ", " AX, ", $1.getSymbol());
        si.concatCode("MOV ", " BX, ", $3.getSymbol());
        si.concatCode("SUB ", " AX, ", " BX ");
        si.concatCode("MOV ", $$.getSymbol(), " , AX");
    }
    | expr RELOP expr {
        std::string temp = new_Temp();
        $$ = SymbolInfo(temp, "");
        of << $$.getSymbol() << " = " << $1.getSymbol() << " " << $2.getSymbol() << " " << $3.getSymbol() << endl;
        si.concatCode("CMP ", $1.getSymbol(), $3.getSymbol());
        if (strcmp($2.getSymbol().c_str(), "==") == 0) si.concatCode("JE ", temp);
        else if (strcmp($2.getSymbol().c_str(), "!=") == 0) si.concatCode("JNE ", temp);
        else if (strcmp($2.getSymbol().c_str(), ">") == 0) si.concatCode("JG ", temp);
        else if (strcmp($2.getSymbol().c_str(), "<") == 0) si.concatCode("JL ", temp);
        else if (strcmp($2.getSymbol().c_str(), ">=") == 0) si.concatCode("JGE ", temp);
        else if (strcmp($2.getSymbol().c_str(), "<=") == 0) si.concatCode("JLE ", temp);
    }
    | term
;

term:
    term MULOP factor {
        std::string temp = new_Temp();
        $$ = SymbolInfo(temp, "");
        of << $$.getSymbol() << " = " << $1.getSymbol() << " * " << $3.getSymbol() << endl;
        si.concatCode("MOV ", " AX, ", $1.getSymbol());
        si.concatCode("MOV ", " BX, ", $3.getSymbol());
        si.concatCode("MUL ", " BX ");
        si.concatCode("MOV ", $$.getSymbol(), " , AX ");
    }
    | term DIVOP factor {
        std::string temp = new_Temp();
        $$ = SymbolInfo(temp, "");
        of << $$.getSymbol() << " = " << $1.getSymbol() << " / " << $3.getSymbol() << endl;
        si.concatCode("MOV ", " AX, ", $1.getSymbol());
        si.concatCode("MOV ", " BX, ", $3.getSymbol());
        si.concatCode("DIV ", " BX ");
        si.concatCode("MOV ", $$.getSymbol(), " , AX");
    }
    | factor
;

factor:
    CONST_INT { $$ = yylval; }
    | CONST_FLOAT { $$ = yylval; }
    | LPAREN expr RPAREN {
        $$ = $2;
    }
    | ID {
        $$ = SymbolInfo($1.getSymbol(), "ID");
        t.insert($$, logFile);  
    }
;

expr_decl:
    ID ASSIGNOP expr {
        of << $1.getSymbol() << " = " << $3.getSymbol() << endl;
        si.concatCode("MOV ", " AX, ", $3.getSymbol());
        si.concatCode("MOV ", $1.getSymbol(), " , AX");
    }
;

if_stmt:
    IF LPAREN expr RPAREN stmt %prec LOWER_THAN_ELSE {
        std::string label = new_Label();
        of << "IF " << $3.getSymbol() << " == 0 GOTO " << label << endl;
        si.concatCode("CMP ", $3.getSymbol(), " 0");
        si.concatCode("JE ", label);
        of << label << ":\n";
        fprintf(ASM, "%s:\n", label.c_str());
    }
    | IF LPAREN expr RPAREN stmt ELSE stmt {
        std::string label1 = new_Label();
        std::string label2 = new_Label();
        of << "IF " << $3.getSymbol() << " == 0 GOTO " << label1 << endl;
        si.concatCode("CMP ", $3.getSymbol(), " 0");
        si.concatCode("JE ", label1);
        of << "GOTO " << label2 << endl;
        si.concatCode("JMP ", label2);
        of << label1 << ":\n";
        fprintf(ASM, "%s:\n", label1.c_str());
        of << label2 << ":\n";
        fprintf(ASM, "%s:\n", label2.c_str());
    }
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

    yyout = fopen("table.txt", "w");
    if (!yyout) {
        perror("Failed to open table.txt");
        return 1;
    }

    logFile = fopen("log.txt", "w");
    if (!logFile) {
        perror("Failed to open log.txt");
        return 1;
    }

    yyparse(); 
    t. print(yyout);

    fclose(yyin);
    fclose(yyout);
    fclose(ASM);
    fclose(logFile);  
    of.close();  

    return 0;
}
