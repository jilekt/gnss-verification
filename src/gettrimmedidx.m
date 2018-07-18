function idx = gettrimmedidx(range, trim)
    if length(trim) == 1
        idx = 1:(1+fix((range-1) * trim));  % end trim
    else
        idx = (1+fix((range-1) * trim(1))) : (1+fix((range-1) * trim(2)));  % start & end trim
    end
end
