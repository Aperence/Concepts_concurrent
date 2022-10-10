% In browser => can display strings in options/representations
% Can stop oz in command palette

% Question 1

declare
fun lazy {Gen I}
    I|{Gen I+1}
end
proc {Touch L I}
    if (I==0) then skip 
    else {Touch L.2 I-1}
    end
end
fun {GiveMeNth N L}
    if (I==0) then N.1 
    else {GiveMeNth L.2 I-1}
    end
end

local S in 
    S = {Gen 1}
    {Browse S}
    {Touch S 3}
end

% Question 2

declare
fun lazy {Filter Xs P}
    case Xs of
    nil then nil
    [] X|Xr then
        if {P X} then X|{Filter Xr P}
        else {Filter Xr P}
        end
    end
end
fun lazy {Sieve Xs}
    case Xs of nil then nil
    [] X|Xr then
    X|{Sieve {Filter Xr fun {$ Y} Y mod X \= 0 end}}
    end
end
fun lazy {Prime}
    {Sieve {Gen 2}}
end

% Question 3
declare
proc {ShowPrimes N}
    local S in
        S = {Prime}
        {Browse S}
        {Touch S N}
    end
end

{ShowPrimes 20}


% Question 4
declare
fun {Gen I N}
    {Delay 500}
    if I==N then [I] else I|{Gen I+1 N} end
end
fun {Filter L F}
    case L of nil then nil
    [] H|T then
    if {F H} then H|{Filter T F} else {Filter T F} end
    end
end
fun {Map L F}
    case L of nil then nil
    [] H|T then {F H}|{Map T F}
    end
end

% with threads
declare Xs Ys Zs
{Browse Zs}
thread {Gen 1 100 Xs} end
thread {Filter Xs fun {$ X} (X mod 2)==0 end Ys} end
thread {Map Ys fun {$ X} X*X end Zs} end

% with lazy

declare
fun lazy {Gen I N}
    {Delay 500}
    if I==N then [I] else I|{Gen I+1 N} end
end
fun lazy {Filter L F}
    case L of nil then nil
    [] H|T then
    if {F H} then H|{Filter T F} else {Filter T F} end
    end
end
fun lazy {Map L F}
    case L of nil then nil
    [] H|T then {F H}|{Map T F}
    end
end

declare Xs Ys Zs
{Browse Zs}
{Gen 1 100 Xs}
{Filter Xs fun {$ X} (X mod 2)==0 end Ys}
{Map Ys fun {$ X} X*X end Zs}
{Touch Zs 100}

% Question 5
declare
fun lazy {Insert X Ys} % O(n)
    {Show 2}
    case Ys of
    nil then [X]
    [] Y|Yr then
        if X < Y then X|Ys
        else Y|{Insert X Yr}
        end
    end
end
fun lazy {InSort Xs} %% Sorts list Xs
    {Show 1}
    case Xs of
    nil then nil
    [] X|Xr then {Insert X {InSort Xr}} % O(n) * O(n) = O(n^2)
    end
end
fun {Minimum Xs}  % O(n^2) 
    {InSort Xs}.1 
end
local R in 
    R = {Minimum [1 2 5 8 7 6]}  % O(n) when lazy => return only first element
    {Browse R}
end

% Question 6 
fun {Last Xs}
    case Xs of
    [X] then X
    [] X|Xr then {Last Xr}
    end
end
fun {Maximum Xs}
    {Last {InSort Xs}}
end
% is the same when lazy or not => we need last element => thus must compute all elements

% Question 7
declare
proc {MapRecord R1 F R2}
    A={Record.arity R1}
    S 
    P={NewPort S}
    proc {Loop L}
        case L of nil then skip
        [] H|T then
            {Send P 1}
            thread R2.H={F R1.H} {Send P ~1} end
            {Loop T}
        end
    end
    proc {WaitZero L Acc}
        if (Acc+L.1 == 0) then skip
        else {WaitZero L.2 Acc+L.1}
        end
    end
    in
    R2={Record.make {Record.label R1} A}
    {Loop A}
    {WaitZero S 0}
end

{Show {MapRecord tuple(a:1 b:2 c:3 d:4 e:5 f:6 g:7) fun {$ X} {Delay 1000} 2*X end}}

% Question 8
declare
fun  lazy {MapLazy L F}
    case L of nil then nil 
    [] H|T then {F H}|{MapLazy T F}
    end
end
fun lazy {Buffer In N}
    End=thread {List.drop In N} end
    fun lazy {Loop In End}
        case In of I|In2 then
        I|{Loop In2 thread End.2 end}
        end
    end
    in
    {Loop In End}
end
/* local DGenerate Buf DSum1 DSum2 in
    DGenerate = {Gen 1}
    Buf = {Buffer DGenerate 10}
    DSum1 = {MapLazy Buf fun{$ X } X+1 end}
    DSum2 = {MapLazy Buf fun{$ X} X+2 end }
    {Browse DSum1}
    {Browse DSum2}
    {Touch DSum1 10}
    {Touch DSum2 10}
end */

declare
proc {DGenerate N Xs}
    case Xs of X|Xr then
        X=N
        Xr=_|_
        {DGenerate N+1 Xr}
    end
end
fun {DSum01 ?Xs A Limit}
    {Delay {OS.rand} mod 10}
    if Limit>0 then 
    X|Xr=Xs
    in
    {DSum01 Xr A+X Limit-1}
    else A end
end
fun {DSum02 ?Xs A Limit}
    {Delay {OS.rand} mod 10}
    if Limit>0 then
    X|Xr=Xs
    in
    {DSum02 Xr A+X Limit-1}
    else A end
end
local Xs=_|_ Ys V1 V2 in
    thread {DGenerate 1 Xs} end % Producer thread
    {Buffer Xs 4 Ys} % Buffer thread
    thread V1={DSum01 Ys 0 15} end % Consumer thread
    thread V2={DSum02 Ys 2 15} end % Consumer thread
    {Browse [Xs Ys V1 V2]}
end
