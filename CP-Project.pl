:- use_module(library(clpfd)).

%teach(Type, StaffMember, Group, Tut, Major, FirstYear, Subject, Hall, Slot).
%staff(Name, OccSlots, DaysOff).
%Hall is 0 if the type not a lecture.
%ava(LargeHalls, smallHalls, Rooms, Labs).

ava(5,5,3,4).

staff('H',[1,2,3,4,5],[4,5]).
staff('Z',[1,2,3,4,5],[4,5]).
staff('F',[1,2,3,4,5],[4,5]).
staff('J',[1,2,3,4,5],[4,5]).

teach(3,'H',2,3,e,0,'math',0,14).
teach(0,'Z',2,3,e,0,'math',3,1).
teach(1,'H',2,3,e,0,'math',0,2).
teach(2,'Z',2,3,e,0,'math',0,10).

teach(1,'Z',2,5,e,0,'math',0,2).
teach(1,'H',2,5,e,0,'math',0,1).
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

teach(1,'H',2,6,e,0,'math',0,1).
teach(1,'J',2,6,e,0,'math',0,2).
teach(2,'J',2,6,e,0,'math',0,10).
teach(3,'H',2,6,e,0,'math',0,11).

% ==================================
compansate(DaysOff, FinalTeach):-
    findCompTeach(DaysOff, TutsToComp),
    setof(teach(X,St,Group,Tut,Mj,Fy,Sb,Hall,Slots),(teach(X,St,Group,Tut,Mj,Fy,Sb,Hall,Slots), day(Slots,DX), element(_,DaysOff, DO), DX #\= DO, X #\= 3 ),Teach),
    slotsDomains(TutsToComp, DaysOff, SlotsDomain),
    generateTeachFromLists(TutsToComp, SlotsDomain, NewTeach),
    checkTutSlotConstraint(NewTeach, DaysOff),
    append(Teach, NewTeach, AllTeach),
    roomConstraint(0,AllTeach),
    setof(teach(X,St,Group,Tut,Mj,Fy,Sb,Hall,Slots),(teach(X,St,Group,Tut,Mj,Fy,Sb,Hall,Slots), day(Slots,DX), element(_,DaysOff, DO), DX #\= DO, element(_,SlotsDomain,SD), DX #\= SD, X #= 3 ), FreeTeach),
    append(AllTeach, FreeTeach, FinalTeach),
    labeling([], SlotsDomain).

% ==================================
roomConstraint(30, _) :- !.
roomConstraint(Counter, AllTeach) :-
    checkSpace(0, AllTeach, Counter),
    checkSpace(1, AllTeach, Counter),
    checkSpace(2, AllTeach, Counter),
    NewCounter #= Counter + 1,
    roomConstraint(NewCounter, AllTeach).
% ==================================
findCompTeach(DaysOff, CompTeach) :-
    bagof(teach(X,St,Group,Tut,Mj,Fy,Sb,Hall,Slots),X^Slots^(teach(X,St,Group,Tut,Mj,Fy,Sb,Hall,Slots),element(_, DaysOff, DayOff), day(Slots, SlotDay), SlotDay #= DayOff, X #\= 3),CompTeach), !.
findCompTeach(_, []).

% ==================================
%Checks That All Slots For All Tutorials Are All_Different.
checkTutSlotConstraint([], _).
checkTutSlotConstraint([H|L], DaysOff) :-
    H = teach(Type, StaffMember, Group, Tut, Major, FirstYear, Subject, Hall, Slot),
    getTutorialGroupTuts(Group, Tut, Major, DaysOff, Tuts),
    addCompTuts(Group, Tut, [H|L], R),
    append(Tuts, R, AllTuts),
    tutSlotsConstraint(Group, Tut, Major, AllTuts),
    removeTuts(Group, Tut, [H|L], NewList),
    checkTutSlotConstraint(NewList, DaysOff).

% ==================================
%Gets The Compansated Tutorial For The Given Group & Tutorial.
addCompTuts(_,_,[],[]).
addCompTuts(Group, Tut, [teach(Type, StaffMember, Group, Tut, Major, FirstYear, Subject, Hall, Slot)|L], [teach(Type, StaffMember, Group, Tut, Major, FirstYear, Subject, Hall, Slot)|R]) :-
    !,
    addCompTuts(Group, Tut, L, R).
addCompTuts(Group, Tut, [_|L], R) :-
    addCompTuts(Group, Tut, L , R).

% ==================================
%Removes The Given Group & Tutorial From The Given List.
removeTuts(_, _, [], []).
removeTuts(Group, Tut, [teach(Type, StaffMember, Group, Tut, Major, FirstYear, Subject, Hall, Slot)|L], T) :-
    !,
    removeTuts(Group, Tut, L, T).
removeTuts(Group, Tut, [H|L], [H|T]):-
    removeTuts(Group, Tut, L, T).

% ==================================
%Applies The All_Different Constraint On The Given Group & Tutorial Slots.
tutSlotsConstraint(Group, Tut, Major, Teach) :-
    tutSlots(Group, Tut, Major, Teach, Slots),
    all_different(Slots).

% ==================================
%Gets The Slots For The Given Group & Tutorial.
tutSlots(_, _, _, [], []).
tutSlots(Group, Tut, Major, [teach(_, _, Group, Tut, Major, _, _, _, Slot)|L], [Slot|S]) :-
    !,
    tutSlots(Group, Tut, Major, L, S).
tutSlots(Group, Tut, Major, [_|L], S):-
    tutSlots(Group, Tut, Major, L, S).

% ==================================
%Sets The Possible Slot Domain For Any Tutorial Needs Compansation. 
slotsDomains([],_,[]).
slotsDomains([teach(Type, StaffMember, Group, Tut, Major, FirstYear, Subject, Hall, Slot)|T], DaysOff, [CommonSlots|R]):-
    getCommonFreeSlots(StaffMember, Group, Tut, Major, DaysOff, CommonSlots), 
    slotsDomains(T,DaysOff,R).

% ==================================
%Generates A List Of "teach(..,..,..)" & Adds A Slots Variable With Its Domain Already Set.
generateTeachFromLists([],_,[]).
generateTeachFromLists([teach(Type, StaffMember, Group, Tut, Major, FirstYear, Subject, Hall, _)|T],[NewSlot|S], [teach(Type, StaffMember, Group, Tut, Major, FirstYear, Subject, Hall, NewSlot)|L]) :-
    generateTeachFromLists(T,S,L).

%=====================================================================================
%Predicate to get number of Rooms, Labs, Large Halls and Small Halls in a given slot
getResources(Slot, Teach, LargeHalls, SmallHalls, Rooms, Labs) :-
    getLargeHalls(Slot, Teach, LH, LHV),
    sort(LH, Large),
    sort(LHV, LargeV),
    length(Large, LargeHallsCount),
    length(LargeV, LargeHallsV),
    LargeHalls #= LargeHallsCount + LargeHallsV,

    getSmallHalls(Slot, Teach, SH, SHV),
    sort(SH, Small),
    sort(SHV, SmallV),
    length(Small, SmallHallsCount),
    length(SmallV, SmallHallsV),
    SmallHalls #= SmallHallsCount + SmallHallsV,

    getRooms(Slot, Teach, R, RV),
    sort(R, Ro),
    sort(RV, RoV),
    length(Ro, RoomsCount),
    length(RoV, RoomsV),
    Rooms #= RoomsCount + RoomsV,

    getLabs(Slot, Teach, L, LV),
    sort(L, La),
    sort(LV, LaV),
    length(La, LabsCount),
    length(LaV, LabsV),
    Labs #= LabsCount + LabsV.

getLargeHalls(_, [], [],[]).
getLargeHalls(Slot, [teach(0,Staff,_,_,_,_,_,LargeHallNum,Var)|L], [Staff|T], V) :-
    nonvar(Var),
    LargeHallNum #> 10,
    !,
    getLargeHalls(Slot, L, T, V).
getLargeHalls(Slot, [teach(0,Staff,_,_,_,_,_,LargeHallNum,Var)|L], T, [Staff|V]) :-
    var(Var),
    fd_dom(Var,D),
    dom_integers(D, Dom),
    element(_,Dom,Slot),
    LargeHallNum #> 10,
    !,
    getLargeHalls(Slot, L, T, V).
getLargeHalls(Slot, [_|L], T, V) :-
    getLargeHalls(Slot, L, T, V).

getSmallHalls(_, [], [], []).
getSmallHalls(Slot, [teach(0,Staff,_,_,_,_,_,SmallHallNum,Var)|L], [Staff|T], V) :-
    nonvar(Var),
    SmallHallNum #< 11,
    !,
    getSmallHalls(Slot, L, T, V).
getSmallHalls(Slot, [teach(0,Staff,_,_,_,_,_,SmallHallNum,Var)|L], T, [Staff|V]) :-
    var(Var),
    fd_dom(Var,D),
    dom_integers(D, Dom),
    element(_,Dom,Slot),
    SmallHallNum #< 11,
    !,
    getSmallHalls(Slot, L, T, V).

getSmallHalls(Slot, [_|L], T, V) :-
    getSmallHalls(Slot, L, T, V).

getRooms(_, [], [], []).
getRooms(Slot, [teach(1,Staff,_,_,_,_,_,_,Var)|L], [Staff|T], V) :-
    nonvar(Var),
    !,
    getRooms(Slot, L, T, V).
getRooms(Slot, [teach(1,Staff,_,_,_,_,_,_,Var)|L], T, [Staff|V]) :-
    var(Var),
    fd_dom(Var,D),
    dom_integers(D, Dom),
    element(_,Dom,Slot),
    !,
    getRooms(Slot, L, T, V).
getRooms(Slot, [_|L], T, V) :-
    getRooms(Slot, L, T, V).

getLabs(_, [], [], []).
getLabs(Slot, [teach(2,Staff,_,_,_,_,_,_,Var)|L], [Staff|T], V) :-
    nonvar(Var),
    !,
    getLabs(Slot, L, T, V).
getLabs(Slot, [teach(2,Staff,_,_,_,_,_,_,Var)|L], T, [Staff|V]) :-
    var(Var),
    fd_dom(Var,D),
    dom_integers(D, Dom),
    element(_,Dom,Slot),
    !,
    getLabs(Slot, L, T, V).
getLabs(Slot, [_|L], T, V) :-
    getLabs(Slot, L, T, V).

%=====================================================================================
%Predicate to check if there is available space for the companseted teach activity
checkSpace(0, Teach, Slot) :-
    ava(_,SmallHalls,_,_),  
    getResources(Slot, Teach, _, SH, _, _), 
    SmallHalls #>= SH.
checkSpace(0, Teach, Slot) :-
    ava(LargeHalls,_,_,_),  
    getResources(Slot, Teach, LH, _, _, _), 
    LargeHalls #>= LH.
checkSpace(1, Teach, Slot) :-
    ava(_,_, Rooms,_),  
    getResources(Slot, Teach, _, _, R, _), 
    Rooms #>= R.
checkSpace(2, Teach, Slot) :-
    ava(_,_,_,Labs),  
    getResources(Slot, Teach, _, _, _, L),
    Labs #>= L.

% ==================================Group Predicates==================================

%Finds The Tutorials In Group In A List Of teach() L.
getTutsInGroup(Group, L, R):-
    getTutsInGroupHelper(Group, L, D), !,
    sort(D,R).

getTutsInGroupHelper(Group, [teach(_,_,Group,Tut,_,_,_,_)|T], [Tut|L]):-
    getTutsInGroupHelper(Group, T, L).
getTutsInGroupHelper(_, [], []).
getTutsInGroupHelper(Group, [_|T], L) :-
    getTutsInGroupHelper(Group, T, L).

% ==================================Tutorial Predicates==================================
getCommonFreeSlots(StaffMember, Group, Tut, Major, DaysOff, CommonSlots) :-
    staff(StaffMember,OccSlots,StaffDaysOff),
    findall(Slots,(teach(3,_,Group,Tut,Major,_,_,_,Slots)),FreeSlots),
    subtract(FreeSlots, OccSlots, CommonFree),
    element(_, CommonFree, CommonSlots).

    %findall(Slots,(teach(3,_,Group,Tut,Major,_,_,_,Slots), day(Slots, SlotDay), \+member(SlotsDay, DaysOff) ),FreeSlots),
    %getDaysOffTut(Group, Tut, Major, TutDaysOff),
    %findall(Slots,(teach(3,_,Group,Tut,Major,_,_,_,Slots), day(Slots, SlotDay), element(SlotDay,TutDaysOff, DO), DO #\= 1),FreeSlots),
    %removeDaysOffSlots(CommonFree, StaffDaysOff, TotalFree),
    %element(_, TotalFree, CommonSlots).

removeDaysOffSlots([], _, []).
removeDaysOffSlots([H|T], DaysOff, [H|R]) :-
    day(H, DayOff),
    \+ member(DayOff, DaysOff),
    removeDaysOffSlots(T, DaysOff, R).
removeDaysOffSlots([_|T], DaysOff, R) :-
    removeDaysOffSlots(T, DaysOff, R).

% ==================================
getTutorialGroupTuts(Group, Tut, Major, DaysOff, L):-
    findall(teach(X,St,Group,Tut,Major,Fy,Sb,Hall,Slots),(teach(X,St,Group,Tut,Major,Fy,Sb,Hall,Slots), day(Slots, SlotDay), element(_,DaysOff, DO), DO #\= SlotDay, X #\= 3),L).

% ==================================
getDaysOffTut(Group, Tut, Major, R) :-
    findall(Slots,teach(3,_,Group,Tut,Major,_,_,_,Slots),FreeSlots),
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

day(H, DH) :-
    DH #= div(H,5).

%Converts A Variable Domain To A List.
dom_integers(D, Is) :- phrase(dom_integers_(D), Is).

dom_integers_(I)      --> { integer(I) }, [I].
dom_integers_(L..U)   --> { numlist(L, U, Is) }, Is.
dom_integers_(D1\/D2) --> dom_integers_(D1), dom_integers_(D2).