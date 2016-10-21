% TODO: separate constraints and bodies, so that I can
% assign the initial condition of the bodies in a .m file
function constraints = loadConstraints(filename)
% open input file
fid = fopen(filename);
% read constraints info
while 1
    tline = fgetl(fid);
    if strcmp(tline, '    "constraints": [')
        break;
    end
    
end

constraints{1}{1} = 'haha';
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
        if (length(findstr(tline,'name')) > 0)
            
            loc = findstr(tline,'"');
            name = tline(loc(3)+1:loc(4)-1);
            % find the constraint ID
            tline = fgetl(fid);
            loc_c = findstr(tline,':');
            id = str2num(tline(loc_c+1:end-1));
            
            constraints{id}{1} = name;
            
            % find body i number
            tline = fgetl(fid);
            loc_c = findstr(tline,':');
            bodyi = str2num(tline(loc_c+1:end-1));
            constraints{id}{2} = bodyi;
            
            % find body j number
            tline = fgetl(fid);
            loc_c = findstr(tline,':');
            bodyj = str2num(tline(loc_c+1:end-1));
            constraints{id}{3} = bodyj;
            
            
            % find constraint type
            tline = fgetl(fid);
            loc = findstr(tline, '"');
            type = tline(loc(3)+1:loc(4)-1);
            constraints{id}{4} = type;
            
            % parse file for DP1 constraint
            if (strcmp(type,'DP1'))
                field1 = 'ai';
                field2 = 'aj';
                
                
                for i = 1:2
                    tline = fgetl(fid);
                    loc1 = findstr(tline,'[');
                    loc2 = findstr(tline,']');
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
                    loc1 = findstr(tline,'[');
                    loc2 = findstr(tline,']');
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
                    loc1 = findstr(tline,'[');
                    loc2 = findstr(tline,']');
                    val3{i} = str2num(tline(loc1:loc2));
                end
                attr = struct(field1, val3{1}', field2, val3{2}', field3, val3{3}');
                constraints{id}{5} = attr;
            end
            
            tline = fgetl(fid);
            loc = findstr(tline,'"');
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