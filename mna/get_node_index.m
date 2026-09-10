function index = get_node_index(circuit, node)

    if strcmp(node, "0")
        index = 0;
        return;
    end

    index = find(strcmp(circuit.non_ground_nodes, node));

    if isempty(index)
        error("Node not found: $s", node);
    end
end