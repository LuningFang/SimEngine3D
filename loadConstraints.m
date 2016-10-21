function constraints = loadConstraints(filename)
global numC
% open input file
fid = fopen(filename);

% read total number of constraints to allocate
% memory space for bodies cell
while 1
    tline = fgetl(fid);
    if (~isempty(strfind(tline, 'numC')))
        break;
    end
end
loc = strfind(tline, ':');
numC = str2num(tline(loc+1:end-1));

constraints = cell(numC, 8);


% read constraints info
while 1
    tline = fgetl(fid);
    if strcmp(tline, '    "constraints": [')
        break;
    end
    
end

% start reading constraints info
while 1
    if strcmp(tline, '	]')
        break;
    end
    while 1
        if strcmp(tline, '        },')
            break;
        end
        tline = fgetl(fid);
        if (~isempty((strfind(tline,'name'))) > 0)
            
            loc = strfind(tline,'"');
            name = tline(loc(3)+1:loc(4)-1);
            % find the constraint ID
            tline = fgetl(fid);
            loc_c = strfind(tline,':');
            id = str2num(tline(loc_c+1:end-1));
            
            constraints{id}{1} = name;
            
            % find body i number
            tline = fgetl(fid);
            loc_c = strfind(tline,':');
            bodyi = str2num(tline(loc_c+1:end-1));
            constraints{id}{2} = bodyi;
            
            % find body j number
            tline = fgetl(fid);
            loc_c = strfind(tline,':');
            bodyj = str2num(tline(loc_c+1:end-1));
            constraints{id}{3} = bodyj;
            
            
            % find constraint type
            tline = fgetl(fid);
            loc = strfind(tline, '"');
            type = tline(loc(3)+1:loc(4)-1);
            constraints{id}{4} = type;
            
            % parse file for DP1 constraint
            if (strcmp(type,'DP1'))
                field1 = 'ai';
                field2 = 'aj';
                
                
                for i = 1:2
                    tline = fgetl(fid);
                    loc1 = strfind(tline,'[');
                    loc2 = strfind(tline,']');
                    val1{i} = str2num(tline(loc1:loc2));
                end
                
                attr = struct(field1, val1{1}', field2, val1{2}');
                constraints{id}{5} = attr;
            end
            
            % parse file for DP2 constraint
            if (strcmp(type,'DP2'))
                field1 = 'sPi';
                field2 = 'sQj';
                field3 = 'ai';
                for i = 1:3
                    tline = fgetl(fid);
                    loc1 = strfind(tline,'[');
                    loc2 = strfind(tline,']');
                    val2{i} = str2num(tline(loc1:loc2));
                end
                attr = struct(field1, val2{1}', field2, val2{2}', field3, val2{3}');
                constraints{id}{5} = attr;
            end
            
            % parse file for CD constraint
            if (strcmp(type,'CD'))
                field1 = 'sPi';
                field2 = 'sQj';
                field3 = 'c';
                for i = 1:3
                    tline = fgetl(fid);
                    loc1 = strfind(tline,'[');
                    loc2 = strfind(tline,']');
                    val3{i} = str2num(tline(loc1:loc2));
                end
                attr = struct(field1, val3{1}', field2, val3{2}', field3, val3{3}');
                constraints{id}{5} = attr;
            end
            
            tline = fgetl(fid);
            loc = strfind(tline,'"');
            if (strcmp('fun', tline(loc(1)+1:loc(2)-1)))
                func = eval(['@(t)',tline(loc(3)+1:loc(4)-1)]);
                constraints{id}{6} = func;
                syms t;
                ftdt = diff(func, t);
                ftddt = diff(ftdt, t);
                constraints{id}{7} = eval(['@(t)', char(ftdt)]);
                constraints{id}{8} = eval(['@(t)', char(ftddt)]);
            end
            
            tline = fgetl(fid);
        end
    end
    tline = fgetl(fid);
end