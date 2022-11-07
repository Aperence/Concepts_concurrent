% Question 1

declare
fun {Ints N} % [0 1 ... N]
    fun {DoInts I}
        if I > N then nil
        else I|{DoInts I+1}
        end
    end
    in
    {DoInts 0}
end
fun lazy {LAppRev F R B}
    {Browse "Lazy Suspension"}
    case pair(F R)
    of pair(X|F2 Y|R2) then
    X|{LAppRev F2 R2 Y|B}
    [] pair(nil [Y]) then Y|B
    end
end
fun {NewQueue} q(0 nil 0 nil) end
    fun {Check Q}
    case Q of q(LenF F LenR R) then
        if LenF<LenR then % Here: |F|+1 = |R| (F and R about the same)
        q(LenF+LenR {LAppRev F R nil} 0 nil)
        else Q end
    end
end
fun {Insert Q X}
    case Q of q(LenF F LenR R) then {Check q(LenF F LenR+1 X|R)} end
end
fun {Delete Q X}
    case Q of q(LenF F LenR R) then F1 in
    F=X|F1 {Check q(LenF-1 F1 LenR R)} end
end

% 4.4. Example execution (same API as before!):
declare Q0 Q1 Q2 X in
Q0={NewQueue}
Q1={FoldL {Ints 32} Insert Q0}
{Browse Q1}
Q2={Delete Q1 X}

% A  
%   persistent but it is no more amortized constant (we have to reverse for each
%   call to delete => O(n*n / n) => O(n))
%
% B
%  B.1
%    AppRev 16 -> AppRev 8 -> AppRev 4 -> AppRev 2 -> AppRev 1
%    31 items     15 item     7 items     3 items     1 item
%    => 5 lazy suspensions
%
%  B.2
%    In general O(log n) lazy suspensions after n inserts (create a suspension
%    when we getting over 2^n)
%
%  B.3 
%    No => it must execute O(log n) lazy expension before getting an element
%
%  B.4
%    O(log n / n) => O(1)
%
%  B.5
%    No as the lazy suspension is only executed once => we can do as much
%    delete => lazy only proc'd by the first call


% Question 1 C

declare
fun lazy {LAppRev F R B}
    case pair(F R)
    of pair(X|F2 Y|R2) then
    X|{LAppRev F2 R2 Y|B}
    [] pair(nil [Y]) then Y|B
    end
end
fun {NewQueue}
    q(
    nil % F
    nil % R
    nil % S(chedule), things we want to force
    )
end
fun {ForceOne Q}
    case Q of q(F R nil) then 
        X 
    in 
        X = {LAppRev F R nil} 
        q(X nil X)
    [] q(F R S) then 
        q(F R S.2)  % call for an element => do 1 step of calculation
    end
end
fun {Insert q(F R S) X} {ForceOne q(F X|R S)} end
fun {Delete q(X|Fr R S) Y} Y=X {ForceOne q(Fr R S)} end

% Can do {Browse {Delete Q2 {Browse $}}}
% or     {Browse {Delete Q2 {Browse}}}


% Question 2

declare
    fun {BinomialHeap}
    fun {NewHeap} nil end
    fun {Link N1 N2} % make a bigger tree from two trees with the same rank
        node(R E1 T1) = N1
        node(_ E2 T2) = N2
    in
        if E1 < E2
        then node(R+1 E1 N2|T1)
        else node(R+1 E2 N1|T2)
        end
    end
    fun {InsTree T Ls} % Insert one tree in the list of trees.
        {Browse insTree(T Ls)}
        case Ls of nil then [T]
        [] L|Lr then
            if T.1 < L.1 then T|Ls
            elseif L.1 < T.1 then L|{InsTree T Lr}
            else {InsTree {Link T L} Lr}
            end
        end
    end
    fun lazy {Insert X Ts} % Insert one element in the Heap
        {Browse insert(X Ts)}
        {InsTree node(0 X nil) Ts}
    end
    fun lazy {Merge Ts Us} % Merge two heaps
        case Ts#Us
        of nil#_ then Us
        [] _#nil then Ts
        [] (T|Tr)#(U|Ur) then
            if T.1 < U.1 then T|{Merge Tr Us}
            elseif T.1 > U.1 then U|{Merge Ts Ur}
            else {InsTree {Link T U} {Merge Tr Ur}}
            end
        end
    end
    fun {RemoveMinTree Ts} % Get the tree with the minimal root in the list, and the remaining ones altogether.
        case Ts
        of [T] then pair(T nil)
        [] T|Tr then
            pair(L Lr) = {RemoveMinTree Tr}
        in
            if T.2 < L.2 then pair(T Tr)
            else pair(L T|Lr)
            end
        end
    end
    fun {FindMin Ts} % Get the minimal value in the heap
        {RemoveMinTree Ts}.1.2
    end
    fun lazy {DeleteMin Ts} % Get the heap minus the minimum element.
        pair(T Tr) = {RemoveMinTree Ts}
    in
        {Merge {Reverse T.3} Tr}
    end
    fun {Ints N}
        0|{Arity {Tuple.make i N}}
    end
in
    b(new : {NewHeap} insert: Insert merge : Merge ints : Ints )
end
{Browse lol}
{Browse {Insert 5 nil}}
{Browse {Ints 9}}
{Browse {FoldR {Ints 9} Insert {NewHeap}}}
% node(Depth Value Children)
% 
%                
%     
%     0            2   
%     |         /  |  \
%     1        6   4   3
%            / |   |
%           8  7   5
%           |
%           9


% 1) Rank n => have at most 2^n nodes
%
% 2) 
%      n = #nodes
%      d = depth = log n
%
%  Worst Case
%
%    Insert:
% 
%      O(log n) => if we have n nodes, we have log n depth levels
%      Thus, we may have at most log n children in list => O(log n)
%
%    FindMin 
%    
%       O(log n) => we have to run through the whole list of length log n 
% 
%    DeleteMin:
%       
%       O(log n) => because we have to merge the children in the 
%       remaining tree
%
%    Merge:
%       O(log n) => we have to go up to a leaf in the worst case
%
%
%
%  Average
%    Insert:
% 
%      O(1) 
%
%    FindMin 
%    
%       O(1) => we have to run through the whole list of length log n 
% 
%    DeleteMin:
%       
%       O(1)
%
%    Merge:
%       O(log n) => we have to go up to a leaf in the worst case
%
%
%
% 4) We make merge, insert and delete lazy as the copies of trees are costly