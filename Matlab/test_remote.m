function test_remote

%% set character encode to UTF-8
feature('DefaultCharacterSet', 'UTF-8')



%%
cd('/home/ljp/Programs/easyRLS/Matlab')
Test = [1:10];

save('Test1.mat','Test')
figure;plot([1:10],[1:10],'o')

save('Test2.mat','Test')

