function [output] = repintersect(A,B)

    % find the indexes of the intersect
    C = intersect(A,B);
    ia = ismember(A,C);
    ib = ismember(B,C);
    
    % check, both return all the elements of the intersect
    % it might be preferable to index by logical arrays bmin, bmax
    CA = A(ia);
    CB = B(ib);
    
    if(length(CA) < length(CB)) 
        output = CA;
    else
        output = CB;
    end
end

