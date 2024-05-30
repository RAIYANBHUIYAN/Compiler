#include <bits/stdc++.h>
using namespace std;
#define tab 57

class SymbolInfo
{

    string symb;
    string type;

public:
    SymbolInfo(string symb = "NULL", string type = "NULL") : symb(symb), type(type) {}

    void setSymbol(string symb)
    {
        this->symb = symb;
    }
    void setSymboltype(string type)
    {
        this->type = type;
    }
    string getSymbol()
    {
        return symb;
    }
    string getType()
    {
        return type;
    }
};

class SymbolTable
{

    vector<SymbolInfo> Table[tab];

public:
    int Hash(string symb)
    {
        return (int(symb[0]) * 52) % tab;
    }

    int Insert(string symb, string type)
    {

        SymbolInfo obj = SymbolInfo(symb, type);
        int index = Hash(symb);
        int pos = Table[index].size();
        for (auto i : Table[index])
        {
            if (i.getSymbol() == symb)
            {
                return 0;
            }
        }
        Table[index].push_back(obj);
        return 1;
    }

    void LookUp(string symb)
    {
        int index = Hash(symb);
        int col = 0;
        for (auto obj : Table[index])
        {
            if (obj.getSymbol() == symb)
            {
                cout << "Found at " << index << "," << col << endl;
                return;
            }
            col++;
        }
        cout << "Symbol is not there" << endl;
    }

    void Delete(string symb)
    {
        int index = Hash(symb);
        int col = 0;
        for (auto obj = Table[index].begin(); obj != Table[index].end(); obj++)
        {
            if (obj->getSymbol() == symb)
            {
                cout << "Deleted from " << index << " , " << col << endl;
                Table[index].erase(obj);
                return;
            }
        }
        cout << "Symbol is not present" << endl;
    }

    void Print(FILE *log)
    {
        for (int i = 0; i < tab; i++)
        {

            fprintf(log, "%d ->", i);
            for (int j = 0; j < Table[i].size(); j++)
            {

                fprintf(log, "<%s, %s> ", Table[i][j].getSymbol().c_str(), Table[i][j].getType().c_str());
            }

            fprintf(log, "\n");
        }
    }
};
