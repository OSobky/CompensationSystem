:- use_module(library(clpfd)).

ava(5).
slot(1, 4).
slot(2,3).

vs_n_num(Vs, N, Num) :-
        maplist(eq_b(N), Vs, Bs),
        sum(Bs, #=, Num).

eq_b(X, Y, B) :- checkSpace(Type,X,SmallorLarge), 
                B #= 1 .

%:- dynamic ResourcesinSlots.
%ResourcesinSlots = [10,10,10,10].


rooms(Vs, Bs):-
        % ava(Y),
        V = [10,10,10,10],
        maplist(check, Vs, Bs).
        %sum(Bs, #=<, Y).


check(X,B) :- indomain(X) ,X = B.