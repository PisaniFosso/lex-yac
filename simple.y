%token NOMBRE OPREL IF ELSE WHILE FOR ID
%token '+' '-' '*' '/' '=' ';' '{' '}' '(' ')'

%left '+' '-'
%left '*' '/'

%start programme

%{
#include <iostream>
#include <string>
#include <vector>
#include <utility>
#include <algorithm>
#include <cstdio>
#include <cstring>
#include <cstdlib>
using namespace std;

struct instruction_t;

struct noeud_t
{
	string valeur;
	instruction_t *gauche;
	instruction_t *droite;
};

struct affectation_t
{
	string identificateur;
	instruction_t *expression;
};

struct condition_t
{
	instruction_t *gauche;
	string operateur;
	instruction_t *droite;
};

struct ifelse_t 
{
	condition_t *condition;
	instruction_t *instructionsIf;
	instruction_t *instructionsElse;
};

class while_t
{
public:
	condition_t *condition;
	instruction_t *instructionsWhile;

};

class for_t 
{
public:

	affectation_t *champ1;
	condition_t *condition;
	affectation_t *champ3;
	instruction_t *instructionsFor;
	
};

struct instruction_t
{
	string valeur;
	noeud_t *expression;
	affectation_t *affectation;
	condition_t *condition;
	ifelse_t *ifelse;
	while_t *whouail;
	for_t *foor;
	
	instruction_t *suivante;
};



#define YYSTYPE instruction_t * // Type des $$, $1, $2, etc.

extern FILE *yyin;
extern char yytext[];
extern "C" int yylex();
int yyparse();
int yyerror(string);

vector<instruction_t *> programme;

void infixe(noeud_t *);

void affiche(vector<instruction_t *>);

instruction_t *booleenne;
instruction_t *assigne;
instruction_t *ssion;
instruction_t *tantq;
instruction_t *pourq;
void afficherAffectation(affectation_t *,int );
void afficherAffectationFor(affectation_t *);
void afficherWhile(while_t *,int);
void afficherFor(for_t *,int);
void afficherIf(ifelse_t *,int);

int indent;


%}

%% 

programme : instruction	{ programme.push_back($1); } programme
	  |
	  ;

instruction : affectation ';'	{ $$ = $1; }
	    | 	  ifelse		    { $$ = $1; }
		| 	  tantque 			{ $$ = $1; }
		| 	  pour	 			{ $$ = $1; }
	    ;

affectation : ID	{ assigne = new instruction_t;
	    		  assigne->valeur = "affectation"; 
			  assigne->affectation = new affectation_t;
			  assigne->affectation->identificateur = string(yytext);
			  assigne->suivante = nullptr; }
	      '=' expr 	{ assigne->affectation->expression = $4;
			  $$ = assigne; }
	    ;

ifelse : IF '(' condition ')' '{' instif '}'
	 ELSE '{' instelse '}'	{ ssion = new instruction_t;
				  ssion->valeur = "if/else";
				  ssion->ifelse = new ifelse_t;
				  ssion->ifelse->condition = new condition_t;
				  ssion->ifelse->condition->gauche = $3; 
				  ssion->ifelse->instructionsIf = $6;
				 ssion->ifelse->instructionsElse = $10;
						$$ = ssion;}
       ;

instif : instruction instif { $1->suivante = $2; }
       |
       ;

instelse : instruction instelse { $1->suivante = $2; }
	 |
         ;
		 
tantque : WHILE '(' condition ')' '{' instantque '}' 
	{tantq = new instruction_t;
				  tantq->valeur = "while";
				  tantq->whouail = new while_t;
				  tantq->whouail->condition = new condition_t;
				  tantq->whouail->condition->gauche = $3; 
				  tantq->whouail->instructionsWhile = $6;
				  $$ = tantq;
	};
	
instantque : instruction instantque {$1->suivante = $2;}
	  |
	  ;
	  
pour : FOR '(' affectation ';' condition ';' affectation ')'
     '{' instfor '}' 
		 {pourq = new instruction_t;
				  pourq->valeur = "pour";
				  pourq->foor = new for_t;
				  pourq->foor->condition = new condition_t;
				  pourq->foor->condition->gauche = $5;
				  pourq->foor->champ1 = $3->affectation; 
				  pourq->foor->champ3 = $7->affectation; 
				  pourq->foor->instructionsFor = $10;
				  $$ = pourq;
			 
		 };
		 
instfor : instruction instfor {$1->suivante = $2;}
	  |
	  ;
	  
condition : expr OPREL { booleenne = new instruction_t;
	  		 booleenne->valeur = "condition Instruction";
			 booleenne->condition = new condition_t;
	  	 	 booleenne->condition->operateur = string(yytext);
			 booleenne->suivante = nullptr; }
	    expr       { booleenne->condition->gauche = $1;
	            	 booleenne->condition->droite = $4;
			 $$ = booleenne; }
	  ;

expr : ID		{ $$ = new instruction_t;
     			  $$->valeur = "expression";
     			  $$->expression = new noeud_t;
                  $$->expression->valeur = string(yytext);
                  $$->expression->gauche = nullptr;
                  $$->expression->droite = nullptr;
     			  $$->suivante = nullptr; }
				  
     | NOMBRE		{ $$ = new instruction_t;
					  $$->valeur = "expression";
					  $$->expression = new noeud_t;
                      $$->expression->valeur = string(yytext);
                      $$->expression->gauche = nullptr;
                      $$->expression->droite = nullptr;
					  $$->suivante = nullptr; }
				  
    | '(' expr ')'	{ $$ = $2; }
    | expr '+' expr	{ $$ = new instruction_t;
					  $$->valeur = "expression";
					  $$->expression = new noeud_t;
					  $$->expression->valeur = string("+");
					  $$->expression->gauche = $1;
					  $$->expression->droite = $3;
					  $$->suivante = nullptr; }
				  
	| expr '-' expr	{ $$ = new instruction_t;
					  $$->valeur = "expression";
					  $$->expression = new noeud_t;
				      $$->expression->valeur = string("-");
					  $$->expression->gauche = $1;
					  $$->expression->droite = $3;
					  $$->suivante = nullptr; }		

	     | expr '/' expr	{ $$ = new instruction_t;
			  $$->valeur = "expression";
			  $$->expression = new noeud_t;
     			  $$->expression->valeur = string("-");
			  $$->expression->gauche = $1;
			  $$->expression->droite = $3;
     			  $$->suivante = nullptr; }	
				  
				  
     | expr '*' expr	{ $$ = new instruction_t;
			  $$->valeur = "expression";
			  $$->expression = new noeud_t;
     			  $$->expression->valeur = string("*");
			  $$->expression->gauche = $1;
			  $$->expression->droite = $3;
     			  $$->suivante = nullptr; }
     ;


%% 

int main(int argc, char **argv)
{
  ++argv, --argc;

  if(argc > 0)
    yyin = fopen(argv[0], "r");
  else
    yyin = stdin;
    
  yyparse(); // Analyse syntaxique

  affiche(programme);

  return 0;
} // main()

int yyerror(string msg)
{
  cerr << msg << endl;

  return 0;
} // yyerror()

void affiche(vector<instruction_t *> programme)
{
	for(auto it = programme.begin(); it != programme.end(); it++)
	{
		

		if((*it)->valeur == "affectation") // ID = (Expression arithmétique).
		{
			afficherAffectation((*it)->affectation,0);
		}
		
		if((*it)->valeur == "pour") // ID = (Boucle For).
		{
			cout <<"for(";  afficherAffectationFor((*it)->foor->champ1);cout << " ; ";infixe((*it)->foor->condition->gauche->condition->gauche->expression) ;cout <<" "<<(*it)->foor->condition->gauche->condition->operateur;cout << " " ;infixe((*it)->foor->condition->gauche->condition->droite->expression);cout << " ; " ;afficherAffectationFor((*it)->foor->champ3) ;cout << ")" <<endl;
			cout << "{" <<endl;
			while((*it)->foor->instructionsFor != nullptr)
			{

				if((*it)->foor->instructionsFor->valeur == "affectation")
				{
					afficherAffectation((*it)->foor->instructionsFor->affectation,indent+1);
				}
				
				if((*it)->foor->instructionsFor->valeur == "while")
				{
					afficherWhile((*it)->foor->instructionsFor->whouail,indent+1);
				}
				
								
				if((*it)->foor->instructionsFor->valeur == "if/else")
				{
					afficherIf((*it)->foor->instructionsFor->ifelse,indent+1);
				}
				
				if((*it)->foor->instructionsFor->valeur == "pour")
				{
					afficherFor((*it)->foor->instructionsFor->foor,indent+1);
				}

				
				if((*it)->foor->instructionsFor->suivante == nullptr)
					break;
				
				(*it)->foor->instructionsFor = (*it)->foor->instructionsFor->suivante;
				
			}
			cout << "}" <<endl;	
		}
		
		if ((*it)->valeur == "while") // ID = (Boucle While).
		{
			cout <<"while(";  infixe((*it)->whouail->condition->gauche->condition->gauche->expression);cout << " " <<(*it)->whouail->condition->gauche->condition->operateur;cout << " " ;infixe((*it)->whouail->condition->gauche->condition->droite->expression); cout << ")" <<endl;
			cout << "{" <<endl;
			while((*it)->whouail->instructionsWhile != nullptr)
			{

				if((*it)->whouail->instructionsWhile->valeur == "affectation")
				{
					afficherAffectation((*it)->whouail->instructionsWhile->affectation,indent+1);
				}
				
								
				if((*it)->whouail->instructionsWhile->valeur == "while")
				{
					afficherWhile((*it)->whouail->instructionsWhile->whouail,indent+1);
				}

				if((*it)->whouail->instructionsWhile->valeur == "pour")
				{
					afficherFor((*it)->whouail->instructionsWhile->foor,indent+1);
				}
				
				if((*it)->whouail->instructionsWhile->valeur == "if/else")
				{
					afficherIf((*it)->whouail->instructionsWhile->ifelse,indent+1);
				}
				
				if((*it)->whouail->instructionsWhile->suivante == nullptr)
					break;
				
				(*it)->whouail->instructionsWhile = (*it)->whouail->instructionsWhile->suivante;
				
			}
			cout << "}" <<endl;			
		}

		if((*it)->valeur == "if/else") // ID = (Boucle if/else).
		{
 
			cout <<"if(";  infixe((*it)->ifelse->condition->gauche->condition->gauche->expression);cout << " " <<(*it)->ifelse->condition->gauche->condition->operateur;cout << " " ;infixe((*it)->ifelse->condition->gauche->condition->droite->expression); cout << ")" <<endl;
			cout << "{" <<endl;
			while((*it)->ifelse->instructionsIf != nullptr)
			{

				if((*it)->ifelse->instructionsIf->valeur == "affectation")
				{
					afficherAffectation((*it)->ifelse->instructionsIf->affectation,indent+1);
				}
				
				if((*it)->ifelse->instructionsIf->valeur == "while")
				{
					afficherWhile((*it)->ifelse->instructionsIf->whouail,indent+1);
				}

				if((*it)->ifelse->instructionsIf->valeur == "pour")
				{
					afficherFor((*it)->ifelse->instructionsIf->foor,indent+1);
				}
				
				if((*it)->ifelse->instructionsIf->valeur == "if/else")
				{
					afficherIf((*it)->ifelse->instructionsIf->ifelse,indent+1);
				}
				
				if((*it)->ifelse->instructionsIf->suivante == nullptr)
					break;
				
				(*it)->ifelse->instructionsIf = (*it)->ifelse->instructionsIf->suivante;
				
			}
			cout << "}" <<endl;
			cout <<"else" <<endl;
			cout << "{" <<endl;
			while((*it)->ifelse->instructionsElse != nullptr)
			{

				if((*it)->ifelse->instructionsElse->valeur == "affectation")
				{
					afficherAffectation((*it)->ifelse->instructionsElse->affectation,indent+1);
				}
				
				if((*it)->ifelse->instructionsElse->valeur == "while")
				{
					afficherWhile((*it)->ifelse->instructionsElse->whouail,indent+1);
				}

				if((*it)->ifelse->instructionsElse->valeur == "pour")
				{
					afficherFor((*it)->ifelse->instructionsElse->foor,indent+1);
				}
				
				if((*it)->ifelse->instructionsElse->valeur == "if/else")
				{
					afficherIf((*it)->ifelse->instructionsElse->ifelse,indent+1);
				}
				
				if((*it)->ifelse->instructionsElse->suivante == nullptr)
					break;
				
				(*it)->ifelse->instructionsElse = (*it)->ifelse->instructionsElse->suivante;
				
			}
			cout << "}" <<endl;
		}
		
		cout << endl;
	}
} // affiche()

void afficherAffectation(affectation_t *aff,int indent = 0)
{
	for(int i = 0;i<indent;i++){cout << "    ";}cout << aff->identificateur << " = ";
	infixe(aff->expression->expression);
	cout << " ;" << endl;	
}

void afficherWhile(while_t *whilee,int indent = 0) //Fonction affichage While recccursive.
{
	for(int i = 0;i<indent;i++){cout << "    ";}cout <<"while(";  infixe(whilee->condition->gauche->condition->gauche->expression);cout << " " <<whilee->condition->gauche->condition->operateur;cout << " " ;infixe(whilee->condition->gauche->condition->droite->expression); cout << ")" <<endl;
	for(int i = 0;i<indent;i++){cout << "    ";}cout << "{" <<endl;
	while(whilee->instructionsWhile != nullptr)
	{

		if(whilee->instructionsWhile->valeur == "affectation")
		{
			afficherAffectation(whilee->instructionsWhile->affectation,indent+1);
		}
					
		if(whilee->instructionsWhile->valeur == "while")
		{
			afficherWhile(whilee->instructionsWhile->whouail,indent+1);
		}
					
		if(whilee->instructionsWhile->valeur == "pour")
		{
			afficherFor(whilee->instructionsWhile->foor,indent+1);
		}	
					
		if(whilee->instructionsWhile->valeur == "if/else")
		{
			afficherIf(whilee->instructionsWhile->ifelse,indent+1);
		}
					
		if(whilee->instructionsWhile->suivante == nullptr)
			break;
					
		whilee->instructionsWhile = whilee->instructionsWhile->suivante;
				
	}
	for(int i = 0;i<indent;i++){cout << "    ";}cout << "}" <<endl;				
}

void afficherFor(for_t *pour,int indent = 0) //Fonction affichage for recccursive.
	{
		for(int i = 0;i<indent;i++){cout << "    ";}cout <<"for(";  afficherAffectationFor(pour->champ1);cout << " ; ";infixe(pour->condition->gauche->condition->gauche->expression) ;cout <<" "<<pour->condition->gauche->condition->operateur;cout << " " ;infixe(pour->condition->gauche->condition->droite->expression);cout << " ; " ;afficherAffectationFor(pour->champ3) ;cout << ")" <<endl;
		for(int i = 0;i<indent;i++){cout << "    ";}cout << "{" <<endl;
		while(pour->instructionsFor != nullptr)
			{

				if(pour->instructionsFor->valeur == "affectation")
				{
					afficherAffectation(pour->instructionsFor->affectation,indent+1);
				}

				if(pour->instructionsFor->valeur == "pour")
				{
					afficherFor(pour->instructionsFor->foor,indent+1);
				}
							
				if(pour->instructionsFor->valeur == "while")
				{
					afficherWhile(pour->instructionsFor->whouail,indent+1);
				}
						
				if(pour->instructionsFor->valeur == "if/else")
				{
					afficherIf(pour->instructionsFor->ifelse,indent+1);
				}
		
				if(pour->instructionsFor->suivante == nullptr)
					break;
						
				pour->instructionsFor = pour->instructionsFor->suivante;
					
			}
			for(int i = 0;i<indent;i++){cout << "    ";}cout << "}" <<endl;	
			}
			
void afficherIf(ifelse_t * ifelse,int indent = 0) //Fonction affichage If/Else recccursive.
	{
 
		for(int i = 0;i<indent;i++){cout << "    ";}cout <<"if(";  infixe(ifelse->condition->gauche->condition->gauche->expression);cout << " " <<ifelse->condition->gauche->condition->operateur;cout << " " ;infixe(ifelse->condition->gauche->condition->droite->expression); cout << ")" <<endl;
		for(int i = 0;i<indent;i++){cout << "    ";}cout << "{" <<endl;
		while(ifelse->instructionsIf != nullptr)
		{

			if(ifelse->instructionsIf->valeur == "affectation")
			{
				afficherAffectation(ifelse->instructionsIf->affectation,indent+1);
			}
				
			if(ifelse->instructionsIf->valeur == "if/else")
			{
				afficherIf(ifelse->instructionsIf->ifelse,indent+1);
			}
				
			if(ifelse->instructionsIf->valeur == "pour")
			{
				afficherFor(ifelse->instructionsIf->foor,indent+1);
			}
						
			if(ifelse->instructionsIf->valeur == "while")
			{
				afficherWhile(ifelse->instructionsIf->whouail,indent+1);
			}
				
			if(ifelse->instructionsIf->suivante == nullptr)
				break;
				
			ifelse->instructionsIf = ifelse->instructionsIf->suivante;
				
			}
			for(int i = 0;i<indent;i++){cout << "    ";}cout << "}" <<endl;
			for(int i = 0;i<indent;i++){cout << "    ";}cout <<"else" <<endl;
			for(int i = 0;i<indent;i++){cout << "    ";}cout << "{" <<endl;
			
			while(ifelse->instructionsElse != nullptr)
			{

				if(ifelse->instructionsElse->valeur == "affectation")
				{
					afficherAffectation(ifelse->instructionsElse->affectation,indent+1);
				}
				
				if(ifelse->instructionsElse->valeur == "if/else")
				{
					afficherIf(ifelse->instructionsElse->ifelse,indent+1);
				}
				
				if(ifelse->instructionsElse->valeur == "pour")
				{
					afficherFor(ifelse->instructionsElse->foor,indent+1);
				}
						
				if(ifelse->instructionsElse->valeur == "while")
				{
					afficherWhile(ifelse->instructionsElse->whouail,indent+1);
				}
				
				if(ifelse->instructionsElse->suivante == nullptr)
					break;
				
				ifelse->instructionsElse = ifelse->instructionsElse->suivante;
				
			}
			for(int i = 0;i<indent;i++){cout << "    ";}cout << "}" <<endl;
		}
		

void afficherAffectationFor(affectation_t *aff) //Fonction affichage affectation pour fonction for recccursive.
{
			for(int i = 0;i<indent;i++){cout << "    ";}cout << aff->identificateur << " = ";
			infixe(aff->expression->expression);
}

void infixe(noeud_t *b)
{
	if(b == nullptr)
		return;

	if(b->valeur[0] == '+' || b->valeur[0] == '-' ||
	   b->valeur[0] == '*' || b->valeur[0] == '/')
		cout << "(";

	if(b->gauche != nullptr)
		infixe(b->gauche->expression);

	if(b->valeur[0] == '+' || b->valeur[0] == '-' ||
	   b->valeur[0] == '*' || b->valeur[0] == '/')
		cout << ' ' << b->valeur << ' ';
	else
		cout << b->valeur;

	if(b->droite != nullptr)
		infixe(b->droite->expression);

	if(b->valeur[0] == '+' || b->valeur[0] == '-' ||
	   b->valeur[0] == '*' || b->valeur[0] == '/')
		cout << ")";
} // infixe()