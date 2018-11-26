function tictoc(fun)
% wraps fun call with tic and toc
tic;
fun();
toc;
end