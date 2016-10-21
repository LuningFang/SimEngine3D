function bodies = loadBodies(filename)
global numB
% open input file
fid = fopen(filename);

% read total number of bodies to allocate
% memory space for bodies cell
while 1
    tline = fgetl(fid);
    if (~isempty(strfind(tline, 'numB')))
        break;
    end
end
loc = strfind(tline, ':');
numB = str2num(tline(loc+1:end-1));

bodies = cell(numB, 7);

% read body parts and assign attributes
while 1
    tline = fgetl(fid);
    if strcmp(tline, '    "bodies": [')
        break;
    end
end


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

