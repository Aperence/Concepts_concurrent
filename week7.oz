\insert 'lifts.oz'

% Question 1
declare
fun {NewPortObjectStateless F}
    P S in 
        P = {NewPort S}
        thread {ForAll S F} end
        proc {$ X} {Send P X} end
end

declare
fun {NewPortObjectStateful F Init}
    P S in 
        P = {NewPort S}
        thread _={FoldL S F Init} end
        proc {$ X} {Send P X} end
end
fun {Timer}
    local proc {Handle Msg}
        case Msg of starttimer(X Pid) then
            {Delay X}
            {Pid done}
        end
    end
in
    {NewPortObjectStateless Handle}
end
end
fun {Washer MaxSize}
    % state is represented as state(current_state size maxSize listDishes)
local 
    Pid
    Tid = {Timer}
    fun {Handle State Msg}
        case State of state(waiting Size L) then
            case Msg of add(X) then
                if (Size + 1 =< MaxSize) then {Browse 'Received item'#X} state(waiting Size+1 X|L)
                else {Browse 'Machine is full'} State
                end
            [] start then 
                {Tid starttimer(3000 Pid)}
                {Browse 'Start washing'}
                state(washing Size L)
            [] _ then State
            end
        [] state(washing _ _) then
            case Msg of done then {Browse 'Done washing'} state(waiting 0 nil)
            [] _ then State
            end
        end
    end
in 
    Pid = {NewPortObjectStateful Handle state(waiting 0 nil)}
    Pid
end
end
proc {Add Wash X}
    {Wash add(X)}
end
proc {Start Wash}
    {Wash start}
end

local WashingMachine = {Washer 2}
in
    {Add WashingMachine 2}
    {Add WashingMachine 3}
    {Add WashingMachine 4}
    {Start WashingMachine}
end


% Question 2

proc {Building FN LN ?Floors ?Lifts} C in
    {Controller C}
    Lifts={MakeTuple lifts LN}
    for I in 1..LN do
    Lifts.I={Lift I state(1 nil false) C Floors}
    end
    Floors={MakeTuple floors FN}
    for I in 1..FN do
    Floors.I={Floor I state(false) Lifts}
    end
end

declare F L in
    {Building 10 2 F L}
    
    {Send F.9 call}
    
    {Delay 300}
    {Send F.5 call}
    {Send L.1 call(4)}
    {Send L.2 call(1)}
    {Delay 5000}
    {Send L.1 call(3)}
    {Send L.2 call(3)}

% Le controleur est beaucoup plus sollicité et s'il y a encore plus de message entrant => il peut potentiellement
% y avoir des latences dans la réception des messages. Mais moins de threads seront créés et donc le traitement
% est plus centralisé

% Question 3

proc {Controller Msg}
    case Msg
    of step(Lid Pos Dest) then
        if Pos<Dest then
        {Delay 1000} {Send Lid ’at’(Pos+1)}
        elseif Pos>Dest then
        {Delay 1000} {Send Lid ’at’(Pos-1)}
        end
    end
end

% a) we have to change the sends by a call to this procedure
%
% b) we deleted a component + Now when a lift is waiting to move =>
%    it can't receive any other message from any source as he has to process instructions
%
% c) We change the diagram of lift as it won't receive stoptimer message anymore
%    We also delete the diagram assiociated with the controllers


% Question 4

% Merge the state diagrams of lifts and controllers



% Question 5

% Change the LastSchedule function => insert at the right place and not necessarily at end of list
% => we might need to remember a direction (up or bottom) in order to do this change


% Question 6

% Send a message to all lifts, then they reply with their actual floor.
% We can then select the closest lift based on these informations (we could also consider the directions
% of such lifts)
