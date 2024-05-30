%option noyywrap
%{
#include<string.h>
#include "table.h"
int line=1;
SymbolTable t;
FILE *tokenfile;
FILE *logfile;
void lextextCap()
    {
        for(int i=0;i<yyleng;i++)
        {
            yytext[i]=yytext[i]-32;
        }
    }
void tokenOut(string tokenName)
    {
        fprintf(tokenfile,"<%s>",tokenName.c_str());
    }
void tokenOut(string tokenName,char tokenType)
    {
        fprintf(tokenfile,"<%s, %c>",tokenName.c_str(),tokenType);
    }
void tokenOut(string tokenName,string tokenType)
    {
        fprintf(tokenfile,"<%s, %s>",tokenName.c_str(),tokenType.c_str());
    }	
%}
digit   [0-9]
letter  [a-zA-Z]
alphanumeric  [a-zA-Z_]
delimeter     [ \t]+
newline       [\n]
keyword       "if"|"for"|"do"|"int"|"float"|"void"|"switch"|"default"|"else"|"while"|"break"|"char"|"double"|"return"|"case"|"continue"
addop         "+"|"-"
mulop         "*"|"%"|"/"
incop         "++"|"--"
relop         "<"|"<="|">"|">="|"=="|"!="
not           "!"
assignop      "="
logicop       "&&"|"||"
lparen        "("
rparen        ")"
lcurl         "{"
rcurl         "}"
lthird        "["
rthird        "]"
comma         ","
semicolon     ";"
identifier    [a-zA-Z_]+[a-zA-Z0-9_]*
strings       \"(.*(\\{newline})*.*)*\"
const_int     {digit}+
const_float   ({digit}+)?(\.)?{digit}+[eE]?[+-]?{digit}+
const_char    \'[a-zA-Z]?\'


%%
{keyword} {
    char str2[1000];
    strcpy(str2,yytext);
    lextextCap();
    tokenOut(yytext);
    fprintf(logfile,"Line No: %d Token <%s> Lexeme %s found\n",line,yytext,str2);
}
\'.{2,}\' {fprintf(logfile,"Error at Line No: %d Multi character constant error %s\n",line,yytext);}
{digit}+{alphanumeric}+ {fprintf(logfile,"Error at Line No: %d Invalid prefix on ID or invalid suffix on Number %s\n",line,yytext);}
{identifier} {
    int res=t.Insert(yytext,"ID");
    fprintf(logfile,"Line No: %d Token <ID> Lexeme %s found\n",line,yytext);
    tokenOut("ID",yytext);
    if(res==0)
    {
        fprintf(logfile,"%s variable already exists in the SymbolTable\n",yytext);
    }
    else
    {
        t.Print(logfile);
    }
    
}
({digit}+\.)+{digit}+ {fprintf(logfile,"Error at Line No: %d Too many decimal points %s\n",line,yytext);}

"/*"([^*]|(\*+[^*/]))*\*+\/ {
    fprintf(logfile,"Line No: %d Token <COMMENT> Lexeme %s found\n",line,yytext);
};
"//".* {
    fprintf(logfile,"Line No: %d Token <COMMENT> Lexeme %s found\n",line,yytext);
}
{delimeter} {}
{addop} {
    tokenOut("ADDOP","+");
    fprintf(logfile,"Line No: %d Token <ADDOP> Lexeme %s found\n",line,yytext);
}
{mulop} {
    tokenOut("MULOP",yytext);
    fprintf(logfile,"Line No: %d Token <MULOP> Lexeme %s found\n",line,yytext);
}
{incop} {
    tokenOut("INCOP",yytext);
    fprintf(logfile,"Line No: %d Token <INCOP> Lexeme %s found\n",line,yytext);
}
{relop} {
    tokenOut("RELOP",yytext);
    fprintf(logfile,"Line No: %d Token <RELOP> Lexeme %s found\n",line,yytext);
}

{comma} {
    tokenOut("COMMA",yytext);
    fprintf(logfile,"Line No: %d Token <COMMA> Lexeme %s found\n",line,yytext);
}
{assignop} {
    tokenOut("ASSIGNOP",yytext);
    fprintf(logfile,"Line No: %d Token <ASSIGNOP> Lexeme %s found\n",line,yytext);
}
{logicop} {
    tokenOut("LOGICOP",yytext);
    fprintf(logfile,"Line No: %d Token <LOGICOP> Lexeme %s found\n",line,yytext);
}
{not} {
    tokenOut("NOT",yytext);
    fprintf(logfile,"Line No: %d Token <NOT> Lexeme %s found\n",line,yytext);
}
{lparen} {
    tokenOut("LPAREN",yytext);
    fprintf(logfile,"Line No: %d Token <LPAREN> Lexeme %s found\n",line,yytext);
}
{rparen} {
    tokenOut("RPAREN",yytext);
    fprintf(logfile,"Line No: %d Token <RPAREN> Lexeme %s found\n",line,yytext);
}
{lcurl} {
    tokenOut("LCURL",yytext);
    fprintf(logfile,"Line No: %d Token <LCURL> Lexeme %s found\n",line,yytext);
}
{rcurl} {
    tokenOut("RCURL",yytext);
    fprintf(logfile,"Line No: %d Token <RCURL> Lexeme %s found\n",line,yytext);
}
{lthird} {
    tokenOut("LTHIRD",yytext);
    fprintf(logfile,"Line No: %d Token <LTHIRD> Lexeme %s found\n",line,yytext);
}
{rthird} {
    tokenOut("RTHIRD",yytext);
    fprintf(logfile,"Line No: %d Token <RTHIRD> Lexeme %s found\n",line,yytext);
}
{semicolon} {
    tokenOut("SEMICOLON",yytext);
    fprintf(logfile,"Line No: %d Token <SEMICOLON> Lexeme %s found\n",line,yytext);
}
{newline} {
    line++;
}
{const_int} {
    tokenOut("CONST_INT",yytext);
    fprintf(logfile,"Line No: %d Token <CONST_INT> Lexeme %s found\n",line,yytext);
    t.Insert("CONST_INT",yytext);
}
{const_float} {
    tokenOut("CONST_FLOAT",yytext);    
    fprintf(logfile,"Line No: %d Token <CONST_FLOAT> Lexeme %s found\n",line,yytext);
}
{const_char} {
    tokenOut("CONST_CHAR",yytext[1]);    
    fprintf(logfile,"Line No: %d Token <CONST_CHAR> Lexeme %c found\n",line,yytext[1]);
}
. {}

%%

int main()
{
	tokenfile=fopen("202114052_token.txt","w");
    logfile=fopen("202114052_log.txt","w");
    yyin=fopen("sample_input3.txt","r");
    yylex();
    fclose(yyin);
    fclose(tokenfile);
    fclose(logfile);

	
	return 0;
}


