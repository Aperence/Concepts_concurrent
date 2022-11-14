% Question 1

declare
A={NewCell 0}
B={NewCell 0}
T1=@A
T2=@B
{Show A==B} % a: What will be printed here
% false

{Show T1==T2} % b: What will be printed here
% true

{Show T1=T2} % c: What will be printed here
% 0
% can also be used to raise exceptions when patterns doesn't match => exemple H|T = 1

A:=@B
{Show A==B} % d: What will be printed here
% false



% Question 2
declare
fun {NewPortObject F Init}
    P S in 
        P = {NewPort S}
        thread _={FoldL S F Init} end
        proc {$ X} {Send P X} end
end
fun {NewCell I}
    fun {Handle State Msg}
        case Msg 
        of get(R) then R=State State
        [] set(X) then X
        end
    end
in
    {NewPortObject Handle I}
end
proc {Access C R} 
    {C get(R)}
end 
proc {Assign C R} 
    {C set(R)}
end

local Cell R R2 in
    Cell = {NewCell 0}
    {Access Cell R}
    {Browse R}
    {Assign Cell 1}
    {Access Cell R2}
    {Browse R2}
end


% Question 3 

declare
fun {NewPort S}
    {NewCell S}
end
proc {Send P X}
    Y in 
        @P = X|!!Y   % make a future => end is read-only => can only be bound by this function
        P := Y
end

local P S in
    {Browse S}
    P = {NewPort S} 
    {Send P 2}
    {Send P 3}
    {Send P null}
    {Send P 4}
    S.2.2.2.2 = nil % try to bind the future
end


% Question 4

declare
fun {NewPortClose S}
    {NewCell S}
end
proc {Send P X}
    Y in 
        @P = X|!!Y
        P := Y
end
proc {Close P}
   @P = nil
end

local P S in
    {Browse S}
    P = {NewPortClose S} 
    {Send P 2}
    {Send P 3}
    {Send P null}
    {Close P}
end


% Question 5

declare
fun {Q A B} 
    C in
    C = {NewCell 0}
    for I in A..B do
        C := @C + I
    end
    @C
end

{Browse {Q 4 7}}  % 4 + 5 + 6 + 7 = 22


% Question 6 


% Question A
declare
class Counter 
    attr Count
    meth new()
        Count := 0
    end
    meth add(N)
        Count := @Count + N
    end
    meth read(N)
        N = @Count
    end
end
fun {Q A B} 
    C = {New Counter new()} Res in
    for I in A..B do
        {C add(I)}
    end
    {C read(Res)}
    Res
end

{Browse {Q 4 7}}


% Question B

declare
class Port
    attr stream
    meth init(S)
        stream := S
    end
    meth send(X)
        Y in
            @stream = X|!!Y
            stream := Y
    end
end
fun {NewPort S}
    {New Port init(S)}
end
proc {Send P X}
    {P send(X)}
end

local P S in
    {Browse S}
    P = {NewPort S} 
    {Send P 2}
    {Send P 3}
    {Send P null}
end



% Question C

declare
class PortClose from Port
    meth close()
        @stream = nil
    end
end
declare
fun {NewPortClose S}
    {New PortClose init(S)}
end
proc {Send P X}
    {P send(X)}
end
proc {Close P}
   {P close()}
end

local P S in
    {Browse S}
    P = {NewPortClose S} 
    {Send P 2}
    {Send P 3}
    {Send P null}
    {Close P}
end

% Question 7

declare
fun {NewCell I}
    I|_
end
proc {Access C R} 
    if {Value.isDet C.2} then {Access C.2 R}
    else R = C.1
    end
end 
proc {Assign C R} 
    if {Value.isDet C.2} then {Assign C.2 R}
    else C.2 = R|_
    end
end

local Cell R R2 in
    Cell = {NewCell 0}
    {Access Cell R}
    {Browse R}
    {Assign Cell 1}
    {Access Cell R2}
    {Browse R2}
end