% Question 1
declare
fun {PortCustom}
    proc {NewPort S P}
        Temp = {NewCell S}
        L = {NewLock}
    in
        P = port(p:Temp   l:L)
    end
    proc {Send port(p:P l:L) Msg}
        NewTail
    in
        lock L then
            @P = Msg|NewTail  % could crash here if two threads do this at the same time
            P := NewTail
        end
    end
in
    p(new:NewPort send:Send)
end

local 
    S P Go
    PC = {PortCustom}
in
    P = {PC.new S}
    for X in 1..100 do
        thread {Wait Go} {PC.send P X} end
    end
    {Browse S}
    Go = unit
end


% Question 2

declare
proc {Inc C}
    % local X in X = C := X+1 end => doesn't work because C == reference to the cell, not the value
    X 
in
    {Exchange C X thread X + 1 end}
end

declare
Go
C = {NewCell 0}
thread 
    {Wait Go}
    for X in 1..100 do
        {Inc C}
    end
end
thread 
    {Wait Go}
    for X in 101..200 do
        {Inc C}
    end
end
{Browse @C}
Go = unit

% Question 3 & 4
declare
class BankAccount
    attr amountBank l

    meth init
        amountBank := 0
        l := {NewLock}
    end

    meth deposit(Amount)
        lock @l then
            amountBank := @amountBank + Amount
             % {Exchange amountBank X thread X+Amount end}
        end
    end

    meth withdraw(Amount)
        lock @l then 
            amountBank := @amountBank - Amount
            % {Exchange amountBank X thread X-Amount end}
        end
    end

    meth getBalance($)
        @amountBank
    end

    meth transfer(Other Amount)
        {Other withdraw(Amount)}
        {self deposit(Amount)}
    end
end

local
    Bank = {New BankAccount init}
in
    {Bank deposit(100)}
    {Bank deposit(200)}
    {Browse {Bank getBalance($)}}
    {Bank withdraw(100)}
    {Browse {Bank getBalance($)}}
end


% Question 5

% correct implementation
fun {NewQueue1 ?Insert ?Delete}
    X C={NewCell q(0 X X)}
    L={NewLock}
in
    proc {Enqueue X}
        N S E1 in
        lock L then
            q(N S X|E1)=@C
            C:=q(N+1 S E1)
        end
    end
    proc {Dequeue ?X}
        N S1 E in
        lock L then
            q(N X|S1 E)=@C
            C:=q(N-1 S1 E)
        end
    end
end

fun {NewQueue2 ?Insert ?Delete}
    X C={NewCell q(0 X X)}
    L1={NewLock}
    L2={NewLock}
in
    proc {Insert X}
        N S E1 in
        lock L1 then
            q(N S X|E1)=@C
            C:=q(N+1 S E1)
        end
    end
    proc {Delete ?X}
        N S1 E in
        lock L2 then
            q(N X|S1 E)=@C
            C:=q(N-1 S1 E)
        end
    end
end

% Question 6

proc {MakeMvar Put Get}
    Mvar = {NewCell _}
    L = {NewLock}
in
    proc {Put X}
        
    end

    proc {Get X}
        Old in
        lock L in
            Old = @Mvar
        end
        {Wait Old}
    end
end