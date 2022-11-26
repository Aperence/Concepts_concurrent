declare 
proc {Partition L Pivot Left Right}
    case L of nil then Left=nil Right=nil
    [] H|T then 
        if H<Pivot then M1 in
            Left=H|M1 {Partition T Pivot M1 Right}
        else M1 in 
            Right=H|M1 {Partition T Pivot Left M1}
        end
    end
end
fun lazy {LAppend L1 L2}
    case L1 of nil then L2 
    [] H|T then H|{LAppend T L2}
    end
end
fun lazy {QuickSort L}
    case L of nil then nil
    [] H|T then Left Right L1 L2 in
        {Partition T H Left Right}
        L1 = {QuickSort Left}
        L2 = {QuickSort Right}
        {Append L1 H|L2}
    end
end
proc {Touch L}
    if L==nil then skip
    else {Wait L.1} {Touch L.2}
    end
end
declare 
S= {QuickSort [1 4 5 3 2 8 1 7]}
{Browse S}

{Touch S}
