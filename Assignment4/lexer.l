%option noyywrap
%{
    #include<bits/stdc++.h>
    #include<string.h>
    #include<stdio.h>
    #include<stdlib.h>
    #include "symtable.h"
    #define YYSTYPE SymbolInfo
    #include "bison.tab.h"
    void lextextCap()
    {
        for(int i=0;i<yyleng;i++)
        {
            yytext[i]=yytext[i]-32;
        }
    }
%}

digit         [0-9]
letter        [a-zA-Z]
alphanumeric  [a-zA-Z_]
delimeter     [ \t]+
newline       [\n]
keyword       "int"|"float"|"char"
addop         "+"
subop         "-"
mulop         "*"|"%"|"/"
incop         "++"|"--"
relop         "<"|"<="|">"|">="|"=="|"!="
not           "!"
assignop      "="
lparen        "("
rparen        ")"
lcurl         "{"
rcurl         "}"
lthird        "["
rthird        "]"
comma         ","
semicolon     ";"
identifier    [a-zA-Z_]+[a-zA-Z0-9_]*
const_int     {digit}+
const_float   ({digit}+)?(\.)?{digit}+[eE]?[+-]?{digit}+

%%

"main"            { return MAIN; }
"int"|"float"|"char" { return KEYWORD; }

{delimeter}       { /* Ignore whitespace */ }
{newline}         { return NEWLINE; }

{addop}           { return ADDOP; }
{subop}           { return SUBOP; }
{mulop}           { return MULOP; }
{incop}           { return INCOP; }
{relop}           { return RELOP; }    /* Added */
{not}             { return NOT; }      /* Added */
{assignop}        { return ASSIGNOP; }
{lparen}          { return LPAREN; }
{rparen}          { return RPAREN; }
{lcurl}           { return LCURL; }
{rcurl}           { return RCURL; }
{lthird}          { return LTHIRD; }
{rthird}          { return RTHIRD; }
{comma}           { return COMMA; }
{semicolon}       { return SEMICOLON; }


{const_int} {
    SymbolInfo ob(string(yytext), "CONST_INT");
    yylval = ob;
    return CONST_INT;
}

{const_float} {  /* Added for handling floating-point constants */
    SymbolInfo ob(string(yytext), "CONST_FLOAT");
    yylval = ob;
    return CONST_FLOAT;
}

{identifier} {
    SymbolInfo ob(string(yytext), "ID");
    yylval = ob;
    return ID;
}

. {
    fprintf(stderr, "Unrecognized character: %s\n", yytext);
    return ERROR;
}
%%

