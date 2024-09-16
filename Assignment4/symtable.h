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
    SymbolInfo(string symbol, string symbolType)
    {
        this->symbol = symbol;
        this->symbolType = symbolType;
    }
    string getSymbol()
    {
        return symbol;
    }
    string getSymbolType()
    {
        return symbolType;
    }
    void setSymbol(string symbol)
    {
        this->symbol = symbol;
    }
    void setSymbolType(string symbolType)
    {
        this->symbolType = symbolType;
    }
    void concatCode(string s, string s1)
    {
        code += s;
        code += s1;
        code += "\n";
    }
    void concatCode(string s, string s1, string s2)
    {
        code += s;
        code += s1;
        code += s2;
        code += "\n";
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


    void insert(SymbolInfo sf)
    {
        string symbol = sf.getSymbol();
        string symbolType = sf.getSymbolType();
        int idx = hashf(symbol);

        for (auto &x : symTable[idx])
        {
            if (x.getSymbol() == symbol)
            {
                fprintf(stderr, "%s already exists in the symbol table\n", symbol.c_str());
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
        return nullptr; // Return nullptr if symbol not found
    }

    void print()
    {
        for (int i = 0; i < MOD; i++)
        {
            cout << i << "-->";
            for (int j = 0; j < symTable[i].size(); j++)
            {
                cout << "<" << symTable[i][j].getSymbol() << "," << symTable[i][j].getSymbolType() << ">";
            }
            cout << endl;
        }
        cout << endl;
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
