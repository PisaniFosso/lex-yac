%{
  // Projet automne 2017
  #include <iostream>
  #include "y.tab.h"
  using namespace std;
  extern "C" int yylex();
%}

LETTRE	[a-zA-Z]
CHIFFRE	[0-9]
ENTIER	{CHIFFRE}+
REEL	({CHIFFRE}+"."{CHIFFRE}*)|({CHIFFRE}*"."{CHIFFRE}+)
ID	{LETTRE}({CHIFFRE}|{LETTRE})*
OPREL	(<|<=|>|>=|==|!=)

%% 

{ENTIER}	{ return NOMBRE;	}
{REEL}		{ return NOMBRE;	}
{OPREL}		{ return OPREL;		}
"if"		{ return IF;		}
"else"		{ return ELSE;		}
"while"		{ return WHILE;		}
"for"		{ return FOR;		}
{ID}		{ return ID;		}
"+"		{ return '+';		}
"-"		{ return '-';		}
"*"		{ return '*';		}
"/"		{ return '/';		}
"="		{ return '=';		}
";"		{ return ';';		}
"{"		{ return '{';		}
"}"		{ return '}';		}
"("		{ return '(';		}
")"		{ return ')';		}
"\n"		{ ;			}
[\t ]+		{ ;			}
.		{ cout << "Autre ?\n";	}

%%

int yywrap(void){
	return 1;
}
