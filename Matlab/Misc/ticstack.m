function T = ticstack(fun, T)
% wraps adds the value of execution time to T
T(end+1) = tictac(fun);
end