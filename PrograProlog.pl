:-include('DataBase.pl').

oracion(S, T):-oracion(S, [], T, []). %Intenta traducir con sentido en los sintagmas
%oracion(S, T):-por_palabra(S, T). %Traduce palabra a palabra si falla el sentido en los sintagmas

oracion(S0,S, T0, T):- interjeccion(Palabrainter, Traduccioninter),
    crear(Palabrainter, S0, S1),
    crear(Traduccioninter, T0, T1),
    sintagma_nominal(N, S1, S2, T1, T2, P1, D1),
    sintagma_proposicional(S2, S3, T2, T3, 0),
    persona(P1, N, D1, Per),
    sintagma_verbal(N, S3, S, T3, T, Per).

o_pregunta(S, T):-o_pregunta(S, [], T, []).
o_pregunta(S0,S,T0,T):- preg(Palabrapreg, Traduccionpreg), crear(Palabrapreg,S0,S1), crear(Traduccionpreg,T0,T1),
						sintagma_nominal_p(S1, S, T1, T).

por_palabra([SH|SC], [TH|TC]):-determinante(_,_,SH, TH), por_palabra(SC, TC).
por_palabra([SH|SC], [TH|TC]):-sust(_,_,SH, TH),  por_palabra(SC, TC).
por_palabra([SH|SC], [TH|TC]):-verbo(_,_,SH, TH), por_palabra(SC, TC).
por_palabra([SH|SC], [TH|TC]):-adjetivo(_,_,SH, TH),  por_palabra(SC, TC).
por_palabra([SH|SC], [SH|TH]):-por_palabra(SC, TH).
por_palabra([], []).

sintagma_nominal(N, S0, S, T0, T, Palabranom, Palabradet):-  sust(G, N, Palabranom, Traduccionnom),
    determinante(G, N, Palabradet, Traducciondet),
    adjetivo(G, N, Palabraadj, Traduccionadj),
    crear(Palabradet, S0, S1), crear(Traducciondet, T0, T1),
    crear(Palabranom, S1, S2), crear(Traduccionnom, T2, T),
    crear(Palabraadj, S2, S), crear(Traduccionadj, T1, T2).
    %Cambia el orden para poder usar en español sustantivo-adjetivo y en inglés adjetivo-sustantivo

sintagma_verbal(N, S0, S, T0, T, Per):- verbo(N, Per, Palabraver, Traduccionver),
					crear(Palabraver, S0, S1), crear(Traduccionver, T0, T1),
					sintagma_proposicional(S1, S, T1, T, 0).

sintagma_proposicional(S0, S, T0, T, X):- X < 5, preposicion(Palabraprep, Traduccionprep),
    sust(G, N, Palabranom, Traduccionnom),
    determinante(G, N, Palabradet, Traducciondet), adjetivo(G, N, Palabraadj, Traduccionadj),
    crear(Palabraprep, S0, S1), crear(Traduccionprep, T0, T1),
    crear(Palabradet, S1, S2), crear(Traducciondet, T1, T2),
    crear(Palabranom, S2, S3), crear(Traduccionnom, T3, T4),
    crear(Palabraadj, S3, S4), crear(Traduccionadj, T2, T3),
    X1 is X+1,
    sintagma_proposicional(S4, S, T4, T, X1).

sintagma_proposicional(S,S,T,T,_).

/*Adverbios modifican verbal antes o después*/
/*Faltan las disyunciones con y e o*/

persona(_, _, Determinante, tercera):- Determinante \== [].
persona(Palabra, N, _, Per):- pronom_per(Per, N, Palabra).
persona(_, _, _, _).
crear(X, [X|S], S):- X \== [].
crear([], S, S).

vocabularioI(S):-sust(_, _, _, S); verbo(_,_,_,S); determinante(_,_,_,S); adjetivo(_,_,_,S); interjeccion(_,S).
vocabularioE(S):-sust(_, _, S,_); verbo(_, _,S,_); determinante(_, _, S,_); adjetivo(_, _, S,_); interjeccion(S,_).

lista_traduccion_oracionI(I, L):- splitS(I, LR), analizar_lista_oracionI(LR, L).
lista_traduccion_oracionE(I, L):- splitS(I, LR), analizar_lista_oracionE(LR, L).

analizar_lista_oracionI([H1, H2|C1], [S|CR]):- nonvar(H2), string_concat(H1, " ", S0),
    string_concat(S0, H2, S), vocabularioI(S), analizar_lista_oracionI(C1, CR), !.
    %Si H2 existe, es decir si no es una variable.
analizar_lista_oracionI([H1|C1], [H1|CR]):- analizar_lista_oracionI(C1, CR), !.
analizar_lista_oracionI([], []):- !.

analizar_lista_oracionE([H1, H2|C1], [S|CR]):- nonvar(H2), string_concat(H1, " ", S0),
    string_concat(S0, H2, S), vocabularioE(S), analizar_lista_oracionE(C1, CR), !.
    %Si H2 existe, es decir si no es una variable.
analizar_lista_oracionE([H1|C1], [H1|CR]):- analizar_lista_oracionE(C1, CR), !.
analizar_lista_oracionE([], []):- !.

splitS(S, L):- split_string(S, " ", " ", L).





lista_string([], "", _):-!.
lista_string([H1|C1], S, U):-string_concat(H1, U, R1), lista_string(C1, R, U), string_concat(R1, R, S).

%pregunta(S0,S,T0,T):-

sintagma_nominal_p(S0, S, T0, T):-  verbo(N, Per, Palabraver, Traduccionver), Per == primera, auxq(N,Per,Auxiliar),
				crear(Palabraver, S0, S1), crear(Traduccionver, T1, T2),
				crear(Auxiliar,T0,Ta),
				pronom_per(Per, N, EspPron),
				sust(neutro, N, EspPron, EngPron), crear(EngPron, Ta, T1),
				oracion(S1, S, T2, T).

sintagma_nominal_p(S0, S, T0, T):-  verbo(N, Per, Palabraver, Traduccionver), auxq(N,Per,Auxiliar),
				crear(Palabraver, S0, S1), crear(Traduccionver, T3, T4),
				sust(G, N, Palabranom, Traduccionnom), determinante(G, N, Palabradet, Traducciondet),
				adjetivo(G, N, Palabraadj, Traduccionadj),
				crear(Auxiliar,T0,Ta),
				crear(Palabradet, S1, S2), crear(Traducciondet, Ta, T1),
				crear(Palabranom, S2, S3), crear(Traduccionnom, T2, T3),
				crear(Palabraadj, S3, S4), crear(Traduccionadj, T1, T2),
				sintagma_proposicional(S4, S, T4, T, 0).

is_question(S):-substring("?",S).

substring(X,S):- string_chars(X,X2),string_chars(S,S2),substring_aux(X2,S2).
substring_aux(X,S) :-append(_,T,S) ,append(X,_,T) ,X \= [].

pegar_dos(S1, "", _, S1):- !.
pegar_dos(S1, S2, U, S):-string_concat(S1, U, ST), string_concat(ST, S2, S).

concatenar_traduccionE([], "", _).
concatenar_traduccionE([P1|R1], R, U):- concatenar_traduccionE(R1, RT, U), traducir0(P1, I1), pegar_dos(I1, RT, U, R).
concatenar_traduccionI([], "", _).
concatenar_traduccionI([P1|R1], R, U):- concatenar_traduccionI(R1, RT, U), traducir0(E1, P1), pegar_dos(E1, RT, U, R).

traducir0(E, I):- var(E), is_question(I), sub_string(I,0,_,1,I0), string_lower(I0, Il),
    lista_traduccion_oracionI(Il, L), o_pregunta(E_lista, L),
    lista_string(E_lista, E1, " "), string_concat(E1, "?", E).
traducir0(E, I):- var(I), is_question(E), sub_string(E,0,_,1,E0), string_lower(E0, El),
    lista_traduccion_oracionE(El, L), o_pregunta(L, I_lista),
    lista_string(I_lista, I1, " "), string_concat(I1, "?", I).
traducir0(E, I):- var(E), string_lower(I, Il), lista_traduccion_oracionI(Il, L),
    oracion(E_lista, L), lista_string(E_lista, E, " "). %Si se desconoce la parte del espanol
traducir0(E, I):- var(I), string_lower(E, El), lista_traduccion_oracionE(El, L),
    oracion(L, I_lista), lista_string(I_lista, I, " "). %Si se desconoce la parte del ingles

traducir(E, I):- var(I), split_string(E, ",", "", L), concatenar_traduccionE(L, I, ",").
traducir(E, I):- var(E), split_string(I, ",", "", L), concatenar_traduccionI(L, E, ",").

translog():- write("Por favor ingrese una oracion: \n"), read(X),
    ((X = "$",despedida(K),write(K),write("\n"),!);(((traducir(X, O), !);
     (traducir(O, X), !));
    mapearS(O)), write("Traduccion: "),
    write(O), write("\n"), translog()).
mapearS("No se pudo traducir").
despedida("Gracias por usar nuestro traductor").
