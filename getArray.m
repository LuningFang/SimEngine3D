% extract a certain field of the cell array
% cell has to be one dimensional with structs
% that has different fields
function y = getArray(cell, field, n)

[length,~] = size(cell);
y = zeros(length,1);
for i = 1:length
    val = getfield(cell{i}, field);
    y(i) = val(n);
end