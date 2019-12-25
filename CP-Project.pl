:- include("./Local Tests.pl").
:- use_module(library(clpfd)).

%teach(Type, StaffMember, Group, Tut, Major, FirstYear, Subject, Hall, Slot).
%staff(Name, OccSlots, DaysOff, Preference).
%Hall is 0 if the type not a lecture.
%ava(LargeHalls, smallHalls, Rooms, Labs).

% ==================================
compansate(DaysOff, SlotsDomain):-
    findCompTeach(DaysOff, TutsToComp),
    findall(Staff,staff(Staff,_,_,_), StaffMembers),
    findall(Preference,staff(_,_,_,Preference), Preferences),
    findall(teach(X,St,Group,Tut,Mj,Fy,Sb,Hall,Slots),(teach(X,St,Group,Tut,Mj,Fy,Sb,Hall,Slots), day(Slots,DX), element(_,DaysOff, DO), DX #\= DO, X #\= 3 ),Teach),

    slotsDomains(TutsToComp, DaysOff, SlotsDomain),
    generateTeachFromLists(TutsToComp, SlotsDomain, NewTeach),
    
    append(Teach, NewTeach, AllTeach),
    checkTutSlotConstraint(NewTeach, DaysOff),
    roomConstraint(AllTeach),
    staffConstraint(StaffMembers, AllTeach),
    findTotalStaffCost(StaffMembers, Preferences, TutsToComp, StaffCost), 
    findTotalTutCost(NewTeach, TutsToComp, TutGroupCost),
    Cost #= StaffCost + TutGroupCost,

    %setof(teach(X,St,Group,Tut,Mj,Fy,Sb,Hall,Slots),(teach(X,St,Group,Tut,Mj,Fy,Sb,Hall,Slots), day(Slots,DX), element(_,DaysOff, DO), DX #\= DO, element(_,SlotsDomain,SD), DX #\= SD, X #= 3 ), FreeTeach),
    %append(AllTeach, FreeTeach, FinalTeach),
    
    labeling([], SlotsDomain).
% ==================================
findTotalStaffCost([], _, _, 0) :- !.
findTotalStaffCost(_, [], _, 0) :- !.
findTotalStaffCost([Staff|S],[[Prefrence]|P], TutsComp, TotalCost) :-
    getStaffCost(Prefrence, Staff, TutsComp, StaffCost),
    findTotalStaffCost(S, P, TutsComp, SubCost), 
    TotalCost #= SubCost + StaffCost.

%Get The Cost Of Slots Being In The Staff Days Off. 
getStaffCost(Preference, Staff, TutsComp, Cost) :-
    staff(Staff, _, StaffDaysOff,_),
    getMemberSlots(Staff, TutsComp, StaffSlots),
    daysOffCost(StaffDaysOff, StaffSlots, StaffCost),
    
    prefrenceCost(Preference, StaffSlots, PrefrenceCost),
    Cost #= StaffCost + PrefrenceCost.

prefrenceCost(Preference, StaffSlots, Num) :-
    maplist(inPreference(Preference), StaffSlots, Costs),
    sum(Costs, #=, Num).

inPreference(Preference, Slot, Cost) :-
    day(Slot, SlotDay),
    SlotDay #\= Preference #<==> Cost. 


findTotalTutCost([], _, 0) :- !.
findTotalTutCost([Teach|T], TutsToComp, TotalCost) :-
    Teach = teach(_, _, Group, Tut, Major, _, _, _, _),
    getTutGroupCost(Group, Tut, Major, TutCost),
    findTotalTutCost(T, TutsToComp, SubCost),
    TotalCost #= SubCost + TutCost.

getTutGroupCost(Group, Tut, Major, TutGroupCost) :-
    tutSlots(Group, Tut, Major, AllTeach, TutGroupSlots),
    getDaysOffTut(Group, Tut, Major, TutDaysOff),
    daysOffCost(TutDaysOff, TutGroupSlots, TutGroupCost).

daysOffCost(DaysOff, Slots, Num) :-
    maplist(isInDaysOff(DaysOff), Slots, Costs),
    sum(Costs, #=, Num).

isInDaysOff(DaysOff, Slot, Cost):-
    element(_,DaysOff,DO),
    day(Slot, SlotDay),
    DO #= SlotDay #<==> Cost.

% ==================================
roomConstraint(AllTeach):-
    ava(LargeHalls, SmallHalls, Rooms, Labs),
    
    rTaskCreation(AllTeach,RTasks),  
    shTaskCreation(AllTeach,SHTasks),
    lhTaskCreation(AllTeach,LHTasks), 
    lTaskCreation(AllTeach,LTasks),  
    cumulative(RTasks, [limit(Rooms)]),
    !,
    cumulative(SHTasks, [limit(SmallHalls)]),
    cumulative(LHTasks, [limit(LargeHalls)]),
    cumulative(LTasks, [limit(Labs)]).


roomConstraint(AllTeach):-
    ava(LargeHalls, SmallHalls, Rooms, Labs),
    shTaskCreation(AllTeach,SHTasks),
    lhTaskCreation(AllTeach,LHTasks), 
    rTaskCreation(AllTeach,RTasks),
    lTaskCreation(AllTeach,LTasks), 

    append(RTasks, LTasks, LRTasks),
    LR #= Rooms + Labs, 

    cumulative(SHTasks, [limit(SmallHalls)]),
    cumulative(LHTasks, [limit(LargeHalls)]),
    cumulative(LRTasks, [limit(LR)]).


shTaskCreation([],[]).
shTaskCreation([H|T], [RH|RT]):-
    H = teach(0, StaffMember, Group, Tut, Major, FirstYear, Subject, Hall, Slot), Hall #=< 10,
    shTaskCreation(T,RT),
    RH = task(Slot,1,_,1,_),!.
shTaskCreation([_|T], RT):-
    shTaskCreation(T,RT).


lhTaskCreation([],[]).
lhTaskCreation([H|T], [RH|RT]):-
    H = teach(0, StaffMember, Group, Tut, Major, FirstYear, Subject, Hall, Slot), Hall #> 10,
    lhTaskCreation(T,RT),
    RH = task(Slot,1,_,1,_),!.
lhTaskCreation([_|T], RT):-
    lhTaskCreation(T,RT).

rTaskCreation([],[]).
rTaskCreation([H|T], [RH|RT]):-
    H = teach(1, StaffMember, Group, Tut, Major, FirstYear, Subject, Hall, Slot),
    rTaskCreation(T,RT),
    RH = task(Slot,1,_,1,_),!.
rTaskCreation([_|T], RT):-
    rTaskCreation(T,RT).

lTaskCreation([],[]).
lTaskCreation([H|T], [RH|RT]):-
    H = teach(2, StaffMember, Group, Tut, Major, FirstYear, Subject, Hall, Slot),
    lTaskCreation(T,RT),
    RH = task(Slot,1,_,1,_),!.
lTaskCreation([_|T], RT):-
    lTaskCreation(T,RT).

% ==================================
findCompTeach(DaysOff, CompTeach) :-
    bagof(teach(X,St,Group,Tut,Mj,Fy,Sb,Hall,Slots),X^Slots^(teach(X,St,Group,Tut,Mj,Fy,Sb,Hall,Slots),element(_, DaysOff, DayOff), day(Slots, SlotDay), SlotDay #= DayOff, X #\= 3),CompTeach), !.
findCompTeach(_, []).

% ==================================
staffConstraint([], _).
staffConstraint([StaffName|T], AllTeach) :-
    getMemberSlots(StaffName, AllTeach, MemberSlots),
    all_distinct(MemberSlots),
    staffConstraint(T, AllTeach).

getMemberSlots(_, [], []).
getMemberSlots(StaffName, [teach(_,StaffName,_,_,_,_,_,_,Slot)|T], [Slot|L]) :-
    !,
    getMemberSlots(StaffName, T, L).
getMemberSlots(StaffName, [_|T], L) :-
    getMemberSlots(StaffName, T, L).

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
% ==================================Tutorial Predicates==================================
getCommonFreeSlots(StaffMember, Group, Tut, Major, DaysOff, CommonSlots) :-
    staff(StaffMember,OccSlots,_,_),
    findall(Slots,(teach(3,_,Group,Tut,Major,_,_,_,Slots), day(Slots,Day ), element(_,DaysOff, DO),  DO #\=Day) ,FreeSlots),
    subtract(FreeSlots, OccSlots, CommonFree),
    element(_, CommonFree, CommonSlots).

% ==================================
getTutorialGroupTuts(Group, Tut, Major, DaysOff, L):-
    findall(teach(X,St,Group,Tut,Major,Fy,Sb,Hall,Slots),(teach(X,St,Group,Tut,Major,Fy,Sb,Hall,Slots), day(Slots, SlotDay), element(_,DaysOff, DO), DO #\= SlotDay, X #\= 3),L).

% ==================================
getDaysOffTut(Group, Tut, Major, R) :-
    findall(Slots,teach(3,_,Group,Tut,Major,_,_,_,Slots),FreeSlots),
    sort(FreeSlots, SortedSlots),
    getDaysOff(SortedSlots, IndexDaysOff),
    returnIndexList(0, IndexDaysOff, R).

returnIndexList(_, [], []).
returnIndexList(Counter, [H|T], [Counter|L]) :-
    H = 1, !,
    Counter1 #= Counter + 1,
    returnIndexList(Counter1, T, L).
returnIndexList(Counter, [_|T], L):-
    Counter1 #= Counter + 1,
    returnIndexList(Counter1, T, L).

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
