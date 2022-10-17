declare
proc {Touch L N}
    if (N==0) then skip
    else {Touch L.2 N-1}
    end
end

% Question 1 
declare
fun lazy {Ints N} N|{Ints N+1} end
fun lazy {Sum2 Xs Ys}
    case Xs#Ys of (X|Xr)#(Y|Yr) then (X+Y)|{Sum2 Xr Yr} end
end
S=0|{Sum2 S {Ints 1}}
% S = 0|1|3|6|10|_
% somme entre élément à l'index i et i+1
{Browse S.2.2.1}  % browse 3

declare
fun {TransHelp Count Acc N}
    if (Count==N) then Acc
    else {TransHelp Count+1 Acc+N-Count N}
    end
end
fun {Trans I}
    {TransHelp 1 0 I}
end
for X in 1..5 do
    {Browse {Trans X}}
end

declare
proc {Ints N ?R} 
    thread
        {WaitNeeded R}
        R1 N1 in
        N1 = N + 1
        R = N|R1
        {Ints N1 R1} 
    end
end
proc {Sum2 Xs Ys ?R}
    thread 
        {WaitNeeded R}
        case Xs#Ys of (X|Xr)#(Y|Yr) then 
            R1 in 
            R = (X+Y)|R1
            {Sum2 Xr Yr R1} 
        end
    end
end
S=0|{Sum2 S {Ints 1}}
{Browse S.2.2.1} 

declare
F = 0|1|{Sum2 F F.2}
{Browse F}
{Touch F 20}

% Question 2
declare
fun lazy {Prod N} N|{Prod N+1} end
fun lazy {Cons Xs}
    case Xs of X|Xr then X*X|{Cons Xr} end
end
fun lazy {Filter Xs D}
    {Delay D} Xs.1|{Filter Xs.2 D}
end
proc {Dup L R1 R2}
    thread
        {WaitNeeded R1}
        {WaitNeeded R2}
        local T1 T2 in
            R1 = L.1|T1
            R2 = L.1|T2
            {Dup L.2 T1 T2}
        end
    end
end
local L1 L2 L3 L4 L5 in
    L1 = {Prod 1}
    {Dup L1 L2 L3}
    L4 = {Cons {Filter L2 500}}
    L5 = {Cons {Filter L3 250}}
    {Browse L4}
    {Browse L5}
    thread {Touch L5 20} end
    thread {Touch L4 20} end
end


% Question 3
declare 
fun{Insert L Item}
    case L of nil then [Item#1]
    [] H|T then 
        if (Item == H.1) then (Item#(H.2 + 1))|T
        else H|{Insert T Item}
        end
    end
end
fun lazy {CountHelp L Acc}
    case L of H|T then 
        R in 
        R={Insert Acc H} 
        R|{CountHelp T R} 
    end
end
fun {Counter L}
    {CountHelp L nil}
end

local
    InS
    R
    in
    R = {Counter InS}
    {Browse R}
    InS=e|m|e|c|_
    {Touch R 20}
end

declare
fun lazy {MergeLists L}
    case L of H|T then 
        H.1|{MergeLists {Append T [H.2]}}
    end
end

local
    In1
    In2
    In3
    Ins
    R
    in
    Ins = {MergeLists [In1 In2 In3]}
    R = {Counter Ins}
    {Browse R}
    In1 = e|c|_
    In2 = m|_
    In3 = e|_
    {Touch R 20}
end

% Question 4

declare
fun {Buffer In N}
    End=thread {List.drop In N} end
    fun lazy {Loop In End}
        case In of I|In2 then
            I|{Loop In2 thread End.2 end}
    end
end
in
    {Loop In End}
end
fun lazy {DGenerate N}
    N|{DGenerate N+1}
end
fun {DSum01 X|Xr A Limit}
    {Delay {OS.rand} mod 10}
    if Limit =< 0 then A else
        {DSum01 Xr A+X Limit-1}
    end
end
fun {DSum02 X|Xr A Limit}
    {Delay {OS.rand} mod 15}
    if Limit =< 0 then A else
        {DSum02 Xr A+X Limit-1}
    end
end
declare
proc {WaitDelay Xs Ys Count1 Count2 N R1 R2}  % N => maximum difference
    thread 
        local L1 L2 in
            if (Count1 - Count2 =< ~N) then 
                {WaitNeeded R1}
                R1 = Xs.1|L1
                {WaitDelay Xs.2 Ys Count1+1 Count2 N L1 R2}
            elseif (Count1 - Count2 >= N) then
                {WaitNeeded R2}
                R2 = Ys.1|L2
                {WaitDelay Xs Ys.2 Count1 Count2+1 N R1 L2}
            elseif (Count1+Count2 mod 2 == 0) then
                R1 = Xs.1|L1
                {WaitDelay Xs.2 Ys Count1+1 Count2 N L1 R2}
            else 
                R2 = Ys.1|L2
                {WaitDelay Xs Ys.2 Count1 Count2+1 N R1 L2}
            end
        end
    end
end
proc {WaitDelayAPI L N R1 R2}
    {WaitDelay L L 0 0 N R1 R2}
end
local Xs Ys L1 L2 V1 V2 in
    thread Xs={DGenerate 1} end % Producer thread
    thread Ys={Buffer Xs 4} end % Buffer thread
    {WaitDelayAPI Ys 4 L1 L2}
    thread V1={DSum01 L1 0 1500} end % Consumer thread
    thread V2={DSum02 L2 2 1500} end % Consumer thread
    {Browse x#Xs}
    {Browse y#Ys}
    {Browse v1#V1}
    {Browse v2#V2}
end