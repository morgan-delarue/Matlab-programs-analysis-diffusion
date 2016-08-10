function [step_size,C] = disp_corr(x,y,step)

C = zeros(1,floor((length(x)-1)/step));
step_size = zeros(1,floor((length(x)-1)/step));

for i = 1:step:length(x)-step
%     C(i) = ( (x(i)-x(i-1))*(x(i+1)-x(i)) + (y(i)-y(i-1))*(y(i+1)-y(i)) ) /...
%         sqrt( ( (x(i)-x(i-1))^2 + (y(i)-y(i-1))^2 ) * ( (x(i+1)-x(i))^2 + (y(i+1)-y(i))^2 ));
    
    C(i) = ( (x(2)-x(1))*(x(i+step)-x(i)) + (y(2)-y(1))*(y(i+step)-y(i)) ) /...
        sqrt( ( (x(2)-x(1))^2 + (y(2)-y(1))^2 ) );
    step_size(i) = sqrt( ( (x(i+step)-x(i))^2 + (y(i+step)-y(i))^2 ) );
    
end


end