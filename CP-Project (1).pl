:- use_module(library(clpfd)).

%teach(Type, StaffMember, Group, Tut, Major, FirstYear, Subject, Hall, Slot).
%Hall is 0 if the type not a lecture.
%let's assume that the Halls from 1 to 10 are small halls, and from 11 to 16 are large halls.
%staff(Name, OccSlots, DaysOff).

%ava(LargeHalls, smallHalls, Rooms, Labs,Slot).

 ava(0, 0, 0,0,0).
 ava(10, 5, 10,5,1).
 ava(10, 5, 10,5,2).
 ava(10, 5, 10,5,3).
 ava(10, 5, 10,5,4).
 ava(10, 5, 10,5,5).
 ava(10, 5, 10,5,6).
 ava(10, 5, 10,5,7).
 ava(10, 5, 10,5,8).
 ava(10, 5, 10,5,9).
 ava(10, 5, 10,5,10).
 ava(10, 5, 10,5,11).
 ava(10, 5, 10,5,12).
 ava(10, 5, 10,5,13).
 ava(10, 5, 10,5,14).





teach(0,'H',2,3,e,0,'math',1,0).
teach(0,'Z',2,3,e,0,'math',3,0).
teach(1,'H',2,3,e,0,'math',0,0).
teach(2,'H',2,3,e,0,'math',0,0).
teach(1,'H',2,5,e,0,'math',0,1).
teach(1,'H',2,6,e,0,'math',0,1).
teach(1,'H',2,6,e,0,'math',0,1).
teach(3,'H',2,5,e,0,'math',0,2).
teach(1,'H',2,5,e,0,'math',0,3).
teach(3,'H',2,5,e,0,'math',0,4).
teach(3,'H',2,5,e,0,'math',0,5).
teach(3,'H',2,5,e,0,'math',0,6).
teach(3,'H',2,5,e,0,'math',0,7).
teach(3,'H',2,5,e,0,'math',0,8).
teach(3,'H',2,5,e,0,'math',0,9).
teach(2,'H',2,5,e,0,'math',0,10).
teach(2,'H',2,5,e,0,'math',0,11).
teach(2,'H',2,5,e,0,'math',0,12).
teach(2,'H',2,5,e,0,'math',0,13).
teach(2,'H',2,6,e,0,'math',0,14).



getCommonFreeSlots(staff(_,OccSlots,_), Group, Tut, L) :-
    findall(Slots,teach(3,_,Group,Tut,_,_,_,Slots),FreeSlots),
     % getFreeSlotsTut(Group,Tut, Schedule, FreeSlots),
    bagof(Slot,Slot^(member(Slot,FreeSlots), \+ member(Slot,OccSlots)),CS),
    sort(CS,L).

% ==================================Group Predicates==================================
getTutsInGroup(Group, L, R):-
    getTutsInGroupHelper(Group, L, D), !,
    sort(D,R).

getTutsInGroupHelper(_, [], []).
getTutsInGroupHelper(Group, [teach(_,_,Group,Tut,_,_,_,_)|T], [Tut|L]):-
    getTutsInGroupHelper(Group, T, L).
getTutsInGroupHelper(Group, [_|T], L) :-
    getTutsInGroupHelper(Group, T, L).



% ==================================Tutorial Predicates==================================

getTutorialGroupTuts(Group, Tut, L):-
    bagof(teach(X,St,Group,Tut,Mj,Fy,Sb,Slots),X^(teach(X,St,Group,Tut,Mj,Fy,Sb,Slots)),L).

getTutorialGroupWorkSlots(_,_,[],[]).
getTutorialGroupWorkSlots(Group, Tut, [teach(X,_,Group,Tut,_,_,_,Slot)|T], [Slot|L]):-
    X #< 3,
    getTutorialGroupWorkSlots(Group, Tut, T, L).
getTutorialGroupWorkSlots(Group, Tut, [_|T], L):-
    getTutorialGroupWorkSlots(Group, Tut, T, L).


getDaysOffTut(Group, Tut, R) :-
    findall(Slots,teach(3,_,Group,Tut,_,_,_,Slots),FreeSlots),
    % getFreeSlotsTut(Group,Tut, Schedule, FreeSlots),
    sort(FreeSlots, SortedSlots),
    getDaysOff(SortedSlots, R).

getDaysOff(Slots, L) :-
    days(Slots, DysOf),
    daysOffHelper(DysOf,NL), !,
    length(NL,6),
    fillListWithZeros(NL,L).

daysOffHelper([],_).
daysOffHelper([H|T], L) :-
    countOcc(H, T, 1, Count, Rest),
    Count #= 5,
    nth0(H,L,1),
    daysOffHelper(Rest,L).
daysOffHelper([H|T],L) :-
    countOcc(H, T, 1, _, Rest),
    daysOffHelper(Rest,L).

fillListWithZeros([],[]).
fillListWithZeros([H|T], [1|NL]):-
    nonvar(H),
    fillListWithZeros(T,NL).
fillListWithZeros([H|T], [0|NL]):-
    var(H),
    fillListWithZeros(T,NL).


countOcc(_, [], C, C, []).
countOcc(X, [X|T], C, R, FilteredList) :-
    !,
    Count #= C + 1,
    countOcc(X, T, Count, R, FilteredList).
countOcc(_, [H|T], C, C, [H|T]).
days([],[]).
days([H|T],[DH|DT]) :-  
    DH #= div(H,5),
        days(T,DT).



%=====================================================================================
% Predicate to get number of Rooms, Labs, Large Halls and Small Halls in a givin slot
getResources(Slot, LargeHalls, SmallHalls, Rooms, Labs) :-
                   Slot in 0 .. 29,
                   SmallHallNum in 1..10,
                   LargeHallNum in 11..16,
                   findall(Staff , teach(0,Staff,_,_,_,_,_,LargeHallNum,Slot), LLResults),
                   distinct(LLResults,X), length(X, LargeHalls),
                   findall(Staff , teach(0,Staff,_,_,_,_,_,SmallHallNum,Slot), LSResults),
                   distinct(LSResults,Z), length(Z, SmallHalls),
                   findall(Staff , teach(1,Staff,_,_,_,_,_,_,Slot), TutResults),
                   distinct(TutResults,Y), length(Y, Rooms),
                   findall(Staff , teach(2,Staff,_,_,_,_,_,_,Slot), LabsResults),
                   distinct(LabsResults,W), length(W, Labs).

%=====================================================================================
%Predicate to check if there is available space for the companseted teach activity
%teach(Type, StaffMember, Group, Tut, Major, FirstYear, Subject, Hall, Slot).
%ava(LargeHalls, SmallHalls, Rooms, Labs,Slot).

checkSpace(Type,Slot,SmallorLarge):-
                      Type = 0, SmallorLarge = 0, ava(_,SmallHalls,_,_,Slot),  getResources(Slot, LH, SH, R, L),SmallHalls #> SH ;
                      Type = 0, SmallorLarge = 1, ava(LargeHalls,_,_,_,Slot),  getResources(Slot, LH, SH, R, L),LargeHalls #> LH ;
                      Type = 1, ava(_,_, Rooms,_,Slot),  getResources(Slot, LH, SH, R, L), Rooms #> R  ;
                      Type = 2, ava(_,_,_,Labs,Slot),  getResources(Slot, LH, SH, R, L),Labs #> L.


%=====================================================================================
% Predicates that might be useful.

% Gets a list with the number of reps of every elements in a sorted list.
countReps([],[]).
countReps([H|T], [C|L]):-
    countRepsHelper(H, 1, T, C, NL),
    countReps(NL,L).

countRepsHelper(_, Count, [], Count, []).
countRepsHelper(X, Count, [X|T], Final, FilteredList):-
    !,
    NewCount #= Count + 1,
    countRepsHelper(X, NewCount, T, Final, FilteredList).
countRepsHelper(_, Count, [H|T], Count, [H|T]).

getFreeSlotsTut(_,_,[],[]).
getFreeSlotsTut(Group, Tut, [teach(3,_,Group,Tut,_,0,_,Slot)|T], [Slot|L]):-
    !,
    getFreeSlotsTut(Group, Tut, T, L).
getFreeSlotsTut(Group, Tut, [_|T], L) :-
    getFreeSlotsTut(Group, Tut, T, L).
    
    
member1(X,[H|_]) :- X==H,!.
member1(X,[_|T]) :- member1(X,T).

distinct([],[]).
distinct([H|T],C) :- member1(H,T),!, distinct(T,C).
distinct([H|T],[H|C]) :- distinct(T,C).
