\insert 'monitors.oz'
\insert 'transaction.oz'

% Question 1

declare proc{MakeMvar Put Get}
    Cell = {NewCell unit}
    IsFull = {NewCell false}
    LockM WaitM NotifyM NotifyAllM
in
    {NewMonitor LockM WaitM NotifyM NotifyAllM}

    proc {Put X}
        {LockM proc{$} 
            if (@IsFull) then {WaitM} {Put X}
            else
                Cell := X
                IsFull := true
                {NotifyAllM}
            end
        end}
    end

    proc {Get X}
        {LockM proc{$} 
            if ({Not @IsFull}) then {WaitM} {Get X}
            else
                X = @Cell
                IsFull := false
                {NotifyAllM}
            end
        end}
    end
end

local Put Get Go in
    {MakeMvar Put Get}

    for X in 1..10 do
        thread
            {Wait Go}
            {Put X}
        end
    end
    for X in 11..20 do
        thread
            {Wait Go}
            {Put X}
        end
    end

    for X in 1..20 do
        thread {Browse {Get $}} end
    end

    Go = unit
end

% Using only locks ==> see week10.oz


% Question 2

declare
Trans NewCellT
{NewTrans Trans NewCellT}
T={MakeTuple db 1000}
for I in 1..1000 do T.I={NewCellT I} end
fun {Rand} {OS.rand} mod 1000 + 1 end
proc {Mix}
    {Trans proc {$ Acc Ass Exc Abo _}
        I={Rand} J={Rand} K={Rand}
        if I==J orelse I==K orelse J==K then {Abo} end
        A={Acc T.I} B={Acc T.J} C={Acc T.K}
    in
        {Ass T.I A+B-C}
        {Ass T.J A-B+C}
        {Ass T.K ~A+B+C}
end _ _}

end


S={NewCellT 0}
fun {Sum}
    {Trans fun {$ Acc Ass Exc Abo}
        {Ass S 0}
        for I in 1..1000 do
        {Ass S {Acc S}+{Acc T.I}} end
        {Acc S}
    end _}
end

{Browse {Sum}} % Displays 500500
for I in 1..1000 do {Mix} end % Mixes up the elements
{Browse {Sum}} % Still displays 500500




% Question 3

declare
proc {ReadWriteLock LockR LockW}
    Type = {NewCell unit}
    NbRead = {NewCell 0}
    LockM WaitM NotifyM NotifyAllM
in
    {NewMonitor LockM WaitM NotifyM NotifyAllM}

    proc {LockR P}
        {LockM proc {$}
            if (Type == unit orelse Type == read) then
                Type := read
                NbRead := @NbRead + 1
            else 
                {WaitM} {LockR P}
            end
        end}

        {P} % we are sure no writing is in use, but reading is allowed in parallel

        {LockM proc {$}
            NbRead := NbRead - 1 
            if (@NbRead == 0) then
                Type := unit
                {NotifyAllM}
            end
        end}
    end

    proc {LockW P}
        {LockM proc {$}
            if (Type == unit) then
                {P} 
                {NotifyAllM}
            else 
                {WaitM} {LockW P}
            end
        end}
    end
end

% solution 2 : using only locks, and get-release lock
% see the LINFO1252 course for more explanation
% as Get-Release is implementing semaphore's behaviour in this example

declare
proc {ReadWriteLock LockR LockW}
    NbRead = {NewCell 0}
    Lock1 = {NewLock}
    GetLock ReleaseLock
    {GetReleaseLock GetLock ReleaseLock}
in
    proc {LockR P}
        lock Lock1 then
            if (@NbRead == 0) then
                {GetLock}
            end
            NbRead := @NbRead + 1
        end

        {P} % we are sure no writing is in use, but reading is allowed in parallel

        lock Lock1 then
            NbRead := @NbRead - 1
            if (@NbRead == 0) then
                {ReleaseLock}
            end
        end
    end

    proc {LockW P}
        {GetLock}
        {P}
        {ReleaseLock}
    end
end