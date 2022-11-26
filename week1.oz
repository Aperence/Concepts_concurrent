
% higher order 
%Question 1
declare 
fun {Filter L F}
    case L 
    of nil then nil
    [] H|T then 
        if {F H} then H|{Filter T F}
        else {Filter T F}
        end
    end
end

% Question 2
declare
L = [1 2 3]
{Browse {Filter L fun {$ X} X mod 2 == 0 end}}


% Threads

% Question 1
local X Y Z in
    thread if X==1 then Y=2 else Z=2 end end
    thread if Y==1 then X=1 else Z=2 end end
    X=1
    {Browse X}  % X == 1
    {Browse Y}  % Y == 2
    {Browse Z}  % Z == 2
end

local X Y Z in
    thread if X==1 then Y=2 else Z=2 end end
    thread if Y==1 then X=1 else Z=2 end end
    X=2
    {Browse X}  % X == 2
    {Browse Y}  % Y == _
    {Browse Z}  % Z == 2
end

% Question 2

declare
fun {Prod N Count}
    if (Count > N) then nil 
    else Count | {Prod N Count+1}
    end
end

local S S2 S3 in 
    thread S = {Prod 10000 0} end
    thread S2 = {Filter S fun {$ X} X mod 2 == 1 end} end
    thread S3 = {FoldL S2 fun {$ A B} A+B end 0} end
    {Browse S3}
end

% Question 3 
declare
proc {Ping L}
    case L of H|T then T2 in
        {Delay 2000} {Browse ping}
        T=_|T2
        {Ping T2}
    end
end
proc {Pong L}
    case L of H|T then T2 in
        {Browse pong}
        T=_|T2
        {Pong T2}
    end
end

declare L in
thread {Ping L.2} end   % => modify L by L.2 to work
thread {Pong L} end  
L=_|_


% Message passing

% Question 1

declare
P S
{NewPort S P}
{Send P foo}
{Send P bar}
{Browse S} % print foo|bar|_<future>

% Question 2
declare
fun {WaitTwo X Y}
    S P in
    P = {NewPort S}
    thread {Wait X} {Send P 1} end
    thread {Wait Y} {Send P 2} end
    S.1
end

local X Y in
    thread {Delay 1000} X = 1 end
    thread {Delay 2000} Y = 2 end
    {Browse {WaitTwo X Y}}
end

% Question 3

declare
fun {RandBound X Y}
    X + {OS.rand} mod (Y-X)
end

declare
fun {Server F}
    P S in 
    P = {NewPort S}
    thread {ForAll S F} end
    proc {$ Msg} {Send P Msg} end
end
proc {Loop L}
    case L of Msg#Ack then 
        {Delay {RandBound 500 1500}}
        Ack=unit
    [] nil then skip
    end
end

Serv = {Server Loop}
local X Y in
    {Browse X}
    {Browse Y}
    {Serv msg#X}
    {Serv msg#Y}
end

% Question 4 
declare
proc {Loop L}
    case L of Msg#Ack then 
        {Delay 500}
        Ack=unit
    [] nil then skip
    end
end
fun {SafeSend P M T}
    local P2 S in 
        P2 = {NewPort S}
        thread {Send P M} {Wait M.2} {Send P2 true} end
        thread {Delay T} {Send P2 false} end
        S.1
    end
end

local P S X in
P={NewPort S}
thread {ForAll S Loop} end
{Browse {SafeSend P msg#X 5000}}
end

