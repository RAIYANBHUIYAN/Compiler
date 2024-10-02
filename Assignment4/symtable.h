#include <bits/stdc++.h>
#include <cstring>
using namespace std;
#define MOD 57

class SymbolInfo
{
    string symbol, symbolType;

public:
   string code = "";
    SymbolInfo() {}
    SymbolInfo(string symbol, string symbolType) : symbol(symbol), symbolType(symbolType) {}

    string getSymbol() const {
        return symbol;
    }
    string getSymbolType() const {
        return symbolType;
    }
    void setSymbol(const string &symbol) {
        this->symbol = symbol;
    }
    void setSymbolType(const string &symbolType) {
        this->symbolType = symbolType;
    }
    void concatCode(const string &s, const string &s1) {
        code += s + s1 + "\n";
    }
    void concatCode(const string &s, const string &s1, const string &s2) {
        code += s + s1 + s2 + "\n";
    }
};

class SymbolTable
{
    vector<SymbolInfo> symTable[MOD];

public:
    int hashf(string symb)
    {
        return (int(symb[0]) * 52) % MOD;
    }


    void insert(SymbolInfo sf ,FILE *logFile)
    {
        string symbol = sf.getSymbol();
        string symbolType = sf.getSymbolType();
        int idx = hashf(symbol);

        for (auto &x : symTable[idx])
        {
            if (x.getSymbol() == symbol)
            {
                fprintf(logFile, "%s already exists in the symbol table\n", symbol.c_str());
                return;
            }
        }
        symTable[idx].push_back(sf);
    }

    SymbolInfo* lookup(string symbol)
    {
        int idx = hashf(symbol);
        for (auto &x : symTable[idx])
        {
            if (x.getSymbol() == symbol)
                return &x;
        }
        return nullptr; 
    }

    void print(FILE *yyout) const {
    for (int i = 0; i < MOD; i++) {
        fprintf(yyout, "%d -->", i);
        for (const auto &entry : symTable[i]) {
            fprintf(yyout, "<%s,%s>", entry.getSymbol().c_str(), entry.getSymbolType().c_str());
        }
        fprintf(yyout, "\n");
    }
    fprintf(yyout, "\n");
}


    void asmVariableInitializer(FILE *ASM)
    {
        for (int i = 0; i < MOD; i++)
        {
            for (int j = 0; j < symTable[i].size(); j++)
            {
                string type = symTable[i][j].getSymbolType();
                if (type == "int")
                    fprintf(ASM, "%s dw ?\n", symTable[i][j].getSymbol().c_str());
                else if (type == "float")
                    fprintf(ASM, "%s dd ?\n", symTable[i][j].getSymbol().c_str());
                else if (type == "char")
                    fprintf(ASM, "%s db ?\n", symTable[i][j].getSymbol().c_str());
            }
        }
        fprintf(ASM, "\n");
    }
};
