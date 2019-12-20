:- use_module(library(clpfd)).

%teach(Type, StaffMember, Group, Tut, Major, FirstYear, Subject, Hall, Slot).
%staff(Name, OccSlots, DaysOff).
%Hall is 0 if the type not a lecture.

%ava(LargeHalls, smallHalls, Rooms, Labs).

ava(20,20,30,20).


staff('H',[1,2,3,4,5,6],[1,2]).
staff('Z',[1,2,3,4,5],[1,2]).
staff('F',[1,2,3,4,5],[1,2]).
staff('J',[1,2,3,4,5],[1,2]).

teach(3,'H',2,3,e,0,'math',0,0).
teach(0,'Z',2,3,e,0,'math',3,1).
teach(1,'H',2,3,e,0,'math',0,2).
teach(1,'J',2,6,e,0,'math',0,2).
teach(1,'Z',2,5,e,0,'math',0,2).
teach(2,'H',2,3,e,0,'math',0,3).
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
teach(3,'H',2,6,e,0,'math',0,14).


% [teach(3,'H',2,3,e,0,'math',0,0),teach(0,'Z',2,3,e,0,'math',3,0),teach(1,'F',2,3,e,0,'math',0,0),(2,'H',2,3,e,0,'math',0,0),teach(1,'H',2,5,e,0,'math',0,1),teach(1,'H',2,6,e,0,'math',0,1),teach(1,'H',2,6,e,0,'math',0,1),teach(3,'H',2,5,e,0,'math',0,2),teach(1,'H',2,5,e,0,'math',0,3),teach(3,'H',2,5,e,0,'math',0,4),teach(3,'H',2,5,e,0,'math',0,5),teach(3,'H',2,5,e,0,'math',0,6),teach(3,'H',2,5,e,0,'math',0,7),teach(3,'H',2,5,e,0,'math',0,8),teach(3,'H',2,5,e,0,'math',0,9),teach(2,'H',2,5,e,0,'math',0,10),teach(2,'H',2,5,e,0,'math',0,11),teach(2,'H',2,5,e,0,'math',0,12),teach(2,'H',2,5,e,0,'math',0,13),teach(3,'H',2,6,e,0,'math',0,14)]
    
%setof(teach(X,St,Group,Tut,Mj,Fy,Sb,Hall,Slots),teach(X,St,Group,Tut,Mj,Fy,Sb,Hall,Slots),Teach),
%bagof(staff(Name, OccSlots, DaysOff),staff(Name, OccSlots, DaysOff),S),
%getTutsAndGroups(TutsToComp, Groups, Tuts),

% ==================================
compansate(TutsToComp, SlotsDomain):-
    setof(teach(X,St,Group,Tut,Mj,Fy,Sb,Hall,Slots),(teach(X,St,Group,Tut,Mj,Fy,Sb,Hall,Slots), X #= 3 ),Teach),
    slotsDomains(TutsToComp, _, SlotsDomain),
    generateTeachFromLists(TutsToComp, SlotsDomain, NewTeach),
    checkTutSlotConstraint(NewTeach),
    append(Teach, NewTeach, AllTeach),
    roomConstraint(0,AllTeach).

% ==================================
roomConstraint(30, _) :- !.
roomConstraint(Counter, AllTeach) :-
    checkSpace(0, AllTeach, Counter, _),
    checkSpace(1, AllTeach, Counter, _),
    checkSpace(2, AllTeach, Counter, _),
    NewCounter #= Counter + 1,
    roomConstraint(NewCounter, AllTeach).

% ==================================
% Checks That All Slots For All Tutorials Are All_Different.
checkTutSlotConstraint([]).
checkTutSlotConstraint([H|L]) :-
    H = teach(Type, StaffMember, Group, Tut, Major, FirstYear, Subject, Hall, Slot),
    getTutorialGroupTuts(Group, Tut, Tuts),
    addCompTuts(Group, Tut, [H|L], R),
    append(Tuts, R, AllTuts),
    tutSlotsConstraint(Group, Tut, AllTuts),
    removeTuts(Group, Tut, [H|L], NewList),
    checkTutSlotConstraint(NewList).

% ==================================
% Gets The Compansated Tutorial For The Given Group & Tutorial.
addCompTuts(_,_,[],[]).
addCompTuts(Group, Tut, [teach(Type, StaffMember, Group, Tut, Major, FirstYear, Subject, Hall, Slot)|L], [teach(Type, StaffMember, Group, Tut, Major, FirstYear, Subject, Hall, Slot)|R]) :-
    !,
    addCompTuts(Group, Tut, L, R).
addCompTuts(Group, Tut, [_|L], R) :-
    addCompTuts(Group, Tut, L , R).

% ==================================
% Removes The Given Group & Tutorial From The Given List.
removeTuts(_, _, [], []).
removeTuts(Group, Tut, [teach(Type, StaffMember, Group, Tut, Major, FirstYear, Subject, Hall, Slot)|L], T) :-
    !,
    removeTuts(Group, Tut, L, T).
removeTuts(Group, Tut, [H|L], [H|T]):-
    removeTuts(Group, Tut, L, T).

% ==================================
% Applies The All_Different Constraint On The Given Group & Tutorial Slots.
tutSlotsConstraint(Group, Tut, Teach) :-
    tutSlots(Group, Tut, Teach, Slots),
    all_different(Slots).

% ==================================
% Gets The Slots For The Given Group & Tutorial.
tutSlots(_, _, [], []).
tutSlots(Group, Tut, [teach(_, _, Group, Tut, _, _, _, _, Slot)|L], [Slot|S]) :-
    !,
    tutSlots(Group, Tut, L, S).

tutSlots(Group, Tut, [_|L], S):-
    tutSlots(Group, Tut, L, S).

% ==================================
% Sets The Possible Slot Domain For Any Tutorial Needs Compansation. 
slotsDomains([],_,[]).
slotsDomains([teach(Type, StaffMember, Group, Tut, Major, FirstYear, Subject, Hall, Slot)|T], DaysOff, [CommonSlots|R]):-
    getCommonFreeSlots(StaffMember, Group, Tut, CommonSlots), 
    slotsDomains(T,DaysOff,R).

% ==================================
% Generates A List Of "teach(..,..,..)" & Adds A Slots Variable With Its Domain Already Set.
generateTeachFromLists([],_,[]).
generateTeachFromLists([teach(Type, StaffMember, Group, Tut, Major, FirstYear, Subject, Hall, Slot)|T],[NewSlot|S], [teach(Type, StaffMember, Group, Tut, Major, FirstYear, Subject, Hall, NewSlot)|L]) :-
    generateTeachFromLists(T,S,L).

% ==================================Group Predicates==================================

% Finds The Tutorials In Group In A List Of teach() L.
getTutsInGroup(Group, L, R):-
    getTutsInGroupHelper(Group, L, D), !,
    sort(D,R).

getTutsInGroupHelper(_, [], []).
getTutsInGroupHelper(Group, [teach(_,_,Group,Tut,_,_,_,_)|T], [Tut|L]):-
    getTutsInGroupHelper(Group, T, L).
getTutsInGroupHelper(Group, [_|T], L) :-
    getTutsInGroupHelper(Group, T, L).

% ==================================Tutorial Predicates==================================
getCommonFreeSlots(StaffMember, Group, Tut, CommonSlots) :-
    staff(StaffMember,OccSlots,_),
    findall(Slots,teach(3,_,Group,Tut,_,_,_,_,Slots),FreeSlots),
    subtract(FreeSlots, OccSlots, CommonFree),
    element(_,CommonFree,CommonSlots).

    %getFreeSlotsTut(Group,Tut, Schedule, FreeSlots),
    %getUncommonElements(FreeSlots, OccSlots, CommonSlots),
    %bagof(Slots, Slots^(element(_,FreeSlots,Slots), element(_,OccSlots,X), Slots#=X), CommonSlots),
    %sort(CommonSlots, L).

% ==================================
getTutorialGroupTuts(Group, Tut, L):-
    bagof(teach(X,St,Group,Tut,Mj,Fy,Sb,Hall,Slots),X^(teach(X,St,Group,Tut,Mj,Fy,Sb,Hall,Slots), X #\= 3),L).

% ==================================
getTutorialGroupWorkSlots(_,_,[],[]).
getTutorialGroupWorkSlots(Group, Tut, [teach(X,_,Group,Tut,_,_,_,Slot)|T], [Slot|L]):-
    X #< 3,
    getTutorialGroupWorkSlots(Group, Tut, T, L).
getTutorialGroupWorkSlots(Group, Tut, [_|T], L):-
    getTutorialGroupWorkSlots(Group, Tut, T, L).

% ==================================
getDaysOffTut(Group, Tut, R) :-
    findall(Slots,teach(3,_,Group,Tut,_,_,_,Slots),FreeSlots),
    % getFreeSlotsTut(Group,Tut, Schedule, FreeSlots),
    sort(FreeSlots, SortedSlots),
    getDaysOff(SortedSlots, R).

% ==================================
getDaysOff(Slots, L) :-
    days(Slots, DysOf),
    daysOffHelper(DysOf,NL), !,
    length(NL,6),
    fillListWithZeros(NL,L).

% ==================================
daysOffHelper([],_).
daysOffHelper([H|T], L) :-
    countOcc(H, T, 1, Count, Rest),
    Count #= 5,
    nth0(H,L,1),
    daysOffHelper(Rest,L).
daysOffHelper([H|T],L) :-
    countOcc(H, T, 1, _, Rest),
    daysOffHelper(Rest,L).

% ==================================
fillListWithZeros([],[]).
fillListWithZeros([H|T], [1|NL]):-
    nonvar(H),
    fillListWithZeros(T,NL).
fillListWithZeros([H|T], [0|NL]):-
    var(H),
    fillListWithZeros(T,NL).

% ==================================
countOcc(_, [], C, C, []).
countOcc(X, [X|T], C, R, FilteredList) :-
    !,
    Count #= C + 1,
    countOcc(X, T, Count, R, FilteredList).
countOcc(_, [H|T], C, C, [H|T]).

% ==================================
days([],[]).
days([H|T],[DH|DT]) :-  
    DH #= div(H,5),
        days(T,DT).

%=====================================================================================
% Predicate to get number of Rooms, Labs, Large Halls and Small Halls in a givin slot
getResources(Slot, Teach, LargeHalls, SmallHalls, Rooms, Labs) :-
                    getLargeHalls(Slot, Teach, LH),
                    getSmallHalls(Slot, Teach, SH),
                    getRooms(Slot, Teach, R),
                    getLabs(Slot, Teach, L),
                    sort(LH, Large),
                    sort(SH, Small),
                    sort(R, Ro),
                    sort(L, La),
                    length(Large, LargeHalls),
                    length(Small, SmallHalls),
                    length(Ro, Rooms),
                    length(La, Labs).




 %V = [teach(2,'H',2,3,e,0,'math',0,0),teach(2,'F',2,3,e,0,'math',0,B),teach(2,'S',2,3,e,0,'math',0,C)] , B in 0 .. 1, C in 0 .. 1,


getLargeHalls(_, [], []).
getLargeHalls(Slot, [teach(0,Staff,_,_,_,_,_,LargeHallNum,Slot)|L], [Staff|T]) :-
    LargeHallNum #> 10,
    !,
    getLargeHalls(Slot, L, T).
getLargeHalls(Slot, [_|L], T) :-
    getLargeHalls(Slot, L, T).

getSmallHalls(_, [], []).
getSmallHalls(Slot, [teach(0,Staff,_,_,_,_,_,SmallHallNum,Slot)|L], [Staff|T]) :-
    SmallHallNum #< 11,
    !,
    getSmallHalls(Slot, L, T).
getSmallHalls(Slot, [_|L], T) :-
    getSmallHalls(Slot, L, T).

getRooms(_, [], []).
getRooms(Slot, [teach(1,Staff,_,_,_,_,_,_,Slot)|L], [Staff|T]) :-
    !,
    getRooms(Slot, L, T).
getRooms(Slot, [_|L], T) :-
    getRooms(Slot, L, T).

getLabs(_, [], []).
getLabs(Slot, [teach(2,Staff,_,_,_,_,_,_,Slot)|L], [Staff|T]) :-
    !,
    getLabs(Slot, L, T).
getLabs(Slot, [_|L], T) :-
    getLabs(Slot, L, T).



%=====================================================================================
%Predicate to check if there is available space for the companseted teach activity
%teach(Type, StaffMember, Group, Tut, Major, FirstYear, Subject, Hall, Slot).
%ava(LargeHalls, SmallHalls, Rooms, Labs,Slot).

checkSpace(Type, Teach, Slot, SmallorLarge):-
                      Type = 0, SmallorLarge = 0, ava(_,SmallHalls,_,_),  getResources(Slot, Teach, _, SH, _, _),SmallHalls #>= SH ;
                      Type = 0, SmallorLarge = 1, ava(LargeHalls,_,_,_),  getResources(Slot, Teach, LH, _, _, _),LargeHalls #>= LH ;
                      Type = 1, ava(_,_, Rooms,_),  getResources(Slot, Teach, _, _, R, _), Rooms #>= R  ;
                      Type = 2, ava(_,_,_,Labs),  getResources(Slot, Teach, _, _, _, L),Labs #>= L.


rooms(Vs, Bs) :-

        maplist(eq_b, Vs, Bs).

eq_b(X,B) :- 
            write(X),
            checkSpace(1,X,_),
            !, 
            B #= 1 .
eq_b(_,B) :-
            B #= 0.







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

getTutsAndGroups(Teach, Groups, Tuts) :-
    fetchTutNums(Teach, Groups, Tuts).

fetchTutNums([],[],[]).
fetchTutNums([teach(_, _, Group, Tut, _, _, _, _, _)|L], [Group|G], [Tut|T]) :-
    fetchTutNums(L,G,T).