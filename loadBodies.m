function bodies = loadBodies(filename)
% open input file
fid = fopen(filename);
% read body parts and assign attributes
while 1
    tline = fgetl(fid);
    if strcmp(tline, '    "bodies": [')
        break;
    end
end

bodies{1}{1} = 'haha';

while 1
    if strcmp(tline, '    ],')
        break;
    end
    
    while 1
        if strcmp(tline, '        },')
            break;
        end
        tline = fgetl(fid);
        if (~isempty(strfind(tline,'name')))
            loc = strfind(tline,'"');
            name = tline(loc(3)+1:loc(4)-1);
            % find body ID
            tline = fgetl(fid);
            loc_c = strfind(tline,':');
            id = str2num(tline(loc_c+1:end-1));
            bodies{id}{1} = name;
            
            % find body mass
            tline = fgetl(fid);
            loc_c = strfind(tline,':');
            mass = str2double(tline(loc_c+1:end-1));
            bodies{id}{2} = mass;
            
            % find inertia, position, position_dt, euler parameter and p_dt
            for i = 3:7
                tline = fgetl(fid);
                
                loc1 = strfind(tline,'[');
                loc2 = strfind(tline,']');
                val = eval(tline(loc1:loc2));
                
                bodies{id}{i} = val';
            end
        end
    end
    tline = fgetl(fid);
end

