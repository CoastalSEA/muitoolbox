function dydx = central_differences(y,x)
    %Compute central differences of variable y with spacing defined by x
    dydx = zeros(size(y));
    % Compute central differences for interior points
    for i = 2:length(y)-1
        dx_forward = x(i+1) - x(i); % Forward interval
        dx_backward = x(i) - x(i-1); % Backward interval
        dydx(i) = (y(i+1) - y(i-1)) / (dx_forward + dx_backward);
    end
    % Handle boundary points (optional, using forward/backward differences)
    dydx(1) = (y(2) - y(1)) / (x(2) - x(1)); % Forward difference at the start
    dydx(end) = (y(end) - y(end-1)) / (x(end) - x(end-1)); % Backward difference at the end
end

