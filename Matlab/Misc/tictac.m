function t = tictac(fun)
% wraps fun call with tic and toc and returns execution time
tic;
fun();
t = toc;
end