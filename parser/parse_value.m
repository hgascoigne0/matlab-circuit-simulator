function value = parse_value(str)

    str = lower(str);

    suffix = str(end);

    switch suffix

        case 'k'
            mult = 1e3;

        case 'm'
            mult = 1e-3;

        case 'u'
            mult = 1e-6;

        case 'n'
            mult = 1e-9;

        case 'p'
            mult = 1e-12;

        otherwise
            mult = 1;

    end

    if mult ~= 1
        str = extractBefore(str, strlength(str));
    end

    value = str2double(str);

    if isnan(value)
        error("Could not parse value: %s", str);
    end

    value = value * mult;

end