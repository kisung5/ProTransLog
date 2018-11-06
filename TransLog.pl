
:-include('DataBase.pl').



%traduccion de español a ingles


/*transLogEI:- write("traducir de español a ingles"), nl,
             read(X), nl,
             split_string(X, " ","",L), nl,
             oracion(L,O).
             %write(O).



print([]).
print([H|T]) :- write(H), write(' '), print(T).

*/

oracion(I,O):- sintagma_nominal(I,O),
               write(O).


sintagma_nominal([PE|I],O):- pronEs(G,N,P,PE),
                             pronEn(G,N,P,PI),
                             sintagma_verbal(G,N,P,I,OU),
                             append([PI], OU, O).



sintagma_nominal([ARTE|I],O):- artEs(G,N,DEF,ARTE),
                               artEn(N,DEF,ARTI),
                               sustantivo(G,N,I,OU),
                               append([ARTI],OU,O).


sustantivo(G,N,[SUSTE|I],O):- sust(G,N,(SUSTE,SUSTI)),
                              sintagma_verbal(G,N,_,I,OU),
                              append([SUSTI], OU, O).

sustantivo(G,N,[SUSTE|I],O):- sust(G,N,(SUSTE,SUSTI)),
                              append([SUSTI], [], O).



sintagma_verbal(G,N,P,[VE|I],O):- vrb(N,P,T,(VE,VI)),
                                  sintagma_nominal(I,OU),
                                  append([VI], OU, O).











