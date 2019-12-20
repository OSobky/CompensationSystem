% Author:
% Date: 11/28/2019

:- use_module(library(clpfd)).

%group(Semester, Major, T-Num, Schedule).

%tut(TA, Course)

%ava(LargeHalls, smallHalls, Rooms, Labs).

Sch_resources= [ ava(10, 5, 10,5) , ava(10, 5, 10,5) , ava(10, 5, 10,5) ,ava(10, 5, 10,5) ,ava(10, 5, 10,5) ,
                 ava(10, 5, 10,5) , ava(10, 5, 10,5) , ava(10, 5, 10,5) ,ava(10, 5, 10,5) ,ava(10, 5, 10,5) ,
                 ava(10, 5, 10,5) , ava(10, 5, 10,5) , ava(10, 5, 10,5) ,ava(10, 5, 10,5) ,ava(10, 5, 10,5) ,
                 ava(10, 5, 10,5) , ava(10, 5, 10,5) , ava(10, 5, 10,5) ,ava(10, 5, 10,5) ,ava(10, 5, 10,5) ,
                 ava(10, 5, 10,5) , ava(10, 5, 10,5) , ava(10, 5, 10,5) ,ava(10, 5, 10,5) ,ava(10, 5, 10,5) ]



compensate(A,):-
               SCH= [ free, free, tut("Kadiki", "AI"), free,  tut("Kadiki", "AI"),
                     free, free, tut("Kadiki", "AI"), free,  tut("Kadiki", "AI"),
                     free, free, tut("Kadiki", "AI"), free,  tut("Kadiki", "AI"),
                     free, free, tut("Kadiki", "AI"), free,  tut("Kadiki", "AI"),
                     free, free, tut("Kadiki", "AI"), free,  tut("Kadiki", "AI") ],

               element( 0,SCH, A).
