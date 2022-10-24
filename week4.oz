
declare
fun {AppendDiff Q1 Q2}
    Q1.2 = Q2.1   % set end of Q1 to start of Q2
    q(Q1.1 Q2.2)  % q(Start End)
end
fun {InOrderHelp Tree DiffList}
    case Tree of leaf then DiffList
    [] tree(Item Left Right) then 
        Temp L R in 
            L = {InOrderHelp Left q(Item|Temp Temp)}
            R = {InOrderHelp Right DiffList}
            {AppendDiff L R}
    end
end
fun {InOrderExplicit Tree}
    X Q in
    Q = {InOrderHelp Tree q(X X)}
    Q.2 = nil  % set end of list to nil
    Q.1        % final list
end

{Browse {InOrderExplicit Tree}}


% Question 1

declare
Tree = tree(4
            tree(2
                tree(1 leaf leaf)
                tree(3 leaf leaf))
            tree(7
                tree(6
                    tree(5 leaf leaf)
                    leaf)
                tree(8
                    leaf
                    tree(9 leaf leaf))))
declare
proc {InOrder Tree ?S E}         % O(n) with n number of nodes 
    case Tree of leaf then S=E
    [] tree(Item Left Right) then 
        End in
        thread {InOrder Left S Item|End} end
        {InOrder Right End E}
    end
end
declare List
{InOrder Tree List nil}
{Browse List}
{Browse {InOrder Tree $ nil}}   % use $ to get a one use variable
declare
fun {Promenade Tree Tail}       % O(n) with n number of nodes
    case Tree
    of tree(V L R) then {Promenade L V|{Promenade R Tail}}
    [] leaf then Tail
    end
end
{Browse {Promenade Tree nil}}




% Question 2 

declare 
fun {NewQueue}
    q(nil nil)
end
fun {Check Q}
    case Q of q(S nil) then q(nil {Reverse S})
    [] _ then Q 
    end
end
fun {Push Q X}
    case Q of q(S E) then {Check q(X|S E)} end
end
fun {Pop Q X}
    case Q of q(S E) then 
        X=E.1 {Check q(S E.2)}
    end
end

local Q1 Q2 Q3 Q4 X in
    Q1 = {NewQueue}
    Q2 = {Push Q1 5}
    Q3 = {Push Q2 6}
    {Browse Q3}
    Q4 = {Pop Q3 X}
    {Browse Q4}
    {Browse X}
end


declare 
fun {NewQueue}
    X in
    q(X X)
end
fun {Push Q X}
    case Q of q(S E) then Y in E=X|Y q(S Y) end
end
fun {Pop Q X}
    case Q of q(S E) then 
        T in
        S=X|T 
        q(T E)
    end
end
fun {PushList Q L}
    case L of nil then Q 
    [] H|T then {PushList {Push Q H} T}
    end
end
fun {PopList Q N R}
    if (N==0) then R=nil Q
    else X Y in R=X|Y {PopList {Pop Q X} N-1 Y}
    end
end

local Q1 Q2 Q3 Q4 L in
    Q1 = {NewQueue}
    Q2 = {PushList Q1 [1 2 3]}
    {Browse Q2}
    Q3 = {PopList Q2 5 L}
    {Browse Q3}
    {Browse L}
    Q4 = {PushList Q2 [4 5]}  % these elements will be retrieved by the pop above
    {Browse Q4}
end


% Question 3

declare
fun {Test NewQueue Insert Delete}
    try
        Q0 Q1 Q2 Q4 Q5 in 
            Q0 = {NewQueue}
            Q1 = {Insert Q0 5}
            Q2 = {Insert Q0 6}
            Q4={Delete Q1 _}
            Q5={Delete Q2 _}
        persistent
    catch _ then
        ephemeral
    end
end
% Browse persistent for amortized constant time queue
% Browse ephemeral for worst case constant time queue
{Browse {Test NewQueue Push Pop}}
