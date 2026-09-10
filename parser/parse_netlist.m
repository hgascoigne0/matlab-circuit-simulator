function circuit = parse_netlist(filename)
   
   fid = fopen(filename, "r");

   if fid == -1
       error("Could not open file: %s", filename);
   end

   elements = struct( ...
       'type',  {}, ...
       'name',  {}, ...
       'n1',    {}, ...
       'n2',    {}, ...
       'value', {}, ...
       'branch_index', {}, ...
       'initial_cond', {});

   dt = [];
   tstop = [];

   while ~feof(fid)
       
       line = strtrim(fgetl(fid));

       if isempty(line) || startsWith(line, '*')
           continue;
       end

       if strcmpi(line, '.END')
           break;
       end

       tokens = split(line);

       name = tokens{1};

       switch upper(name(1))

           case 'R'
               if length(tokens) < 4
                   error("Invalid resistor definition: %s", line);
               end
               element.type = "R";
               element.name = name;
               element.n1 = tokens{2};
               element.n2 = tokens{3};
               element.value = parse_value(tokens{4});
               element.branch_index = [];
               element.initial_cond = [];
               elements(end+1) = element;

           case 'C'
               if length(tokens) < 4
                   error("Invalid capacitor definition: %s", line);
               end
               element.type = "C";
               element.name = name;
               element.n1 = tokens{2};
               element.n2 = tokens{3};
               element.value = parse_value(tokens{4});
               element.branch_index = [];
               element.initial_cond = [];

               % IC is a voltage
               if length(tokens) >= 5 && startsWith(upper(tokens{5}), "IC=")
                   element.initial_cond = ...
                       parse_value(extractAfter(tokens{5}, "IC="));
               end

               elements(end+1) = element;

           case 'V'
               if length(tokens) < 4
                   error("Invalid voltage source definition: %s", line);
               end
               element.type = "V";
               element.name = name;
               element.n1 = tokens{2};
               element.n2 = tokens{3};
               element.value = parse_value(tokens{4}); % ONLY DC VOLTAGE SUPPORTED
               element.branch_index = [];
               element.initial_cond = [];
               elements(end+1) = element;

           case 'L'
               if length(tokens) < 4
                   error("Invalid inductor definition: %s", line);
               end
               element.type = "L";
               element.name = name;
               element.n1 = tokens{2};
               element.n2 = tokens{3};
               element.value = parse_value(tokens{4});
               element.branch_index = [];
               element.initial_cond = [];

               % IC is a current
               if length(tokens) >= 5 && startsWith(upper(tokens{5}), "IC=")
                   element.initial_cond = ...
                       parse_value(extractAfter(tokens{5}, "IC="));
               end

               elements(end+1) = element;
           
           case '.'
               if strcmpi(name, '.TRAN')
                   if length(tokens) < 3
                       error("Invalid .TRAN definition: %s", line);
                   end
                   
                   dt = parse_value(tokens{2});
                   tstop = parse_value(tokens{3});
               end

           otherwise
               warning("Unknown element: %s", name);

       end
   end

   fclose(fid);

   nodes = {};

   for k = 1:length(elements)
       nodes{end + 1} = elements(k).n1;
       nodes{end + 1} = elements(k).n2;
   end

   nodes = unique(nodes, 'stable');

   is_ground = strcmp(nodes, "0");
   non_ground_nodes = nodes(~is_ground);

   branch_current_count = 0;

   for k = 1:length(elements)
       if elements(k).type == "V" || elements(k).type == "L"
           branch_current_count = branch_current_count + 1;
           elements(k).branch_index = length(non_ground_nodes) + branch_current_count;
       end
   end

   circuit.elements = elements;
   circuit.nodes = nodes;
   circuit.non_ground_nodes = non_ground_nodes;

   circuit.num_nodes = length(nodes);
   circuit.num_non_ground_nodes = length(non_ground_nodes);
   circuit.num_branch_currents = branch_current_count;

   circuit.num_unknowns = circuit.num_non_ground_nodes + ...
                          circuit.num_branch_currents;

   circuit.dt = dt;
   circuit.tstop = tstop;

end