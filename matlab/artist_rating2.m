%% ===== init ===== %%
clear all; clc;

%% ===== load Data ===== %%

A = load("user_artists.dat");
a=sparse(A(:,1)', A(:,2)', A(:,3)');%��һ�����У��ڶ������У��������Ǿ������
b = full(a);

%% ===== compute Rating ===== %%
[row, column] = size(b);
temp = b(b > 0);
m = mean(temp);
s = std(temp);
b(b > 0) = sigmoid((temp - m) / s);

%% ===== compute person ===== %%
sim = calculateSim(b);

%% ===== add1: �������1 ===== %%
X = addData(b, sim);

%% ===== sim2: �ڶ��μ������Ƴ̶� ===== %%
sim2 = calculateSim(X);

%% ===== ����Ԥ������ ===== %
k = 500;
u = 4;
p = predict(X, sim2, u, k);
[pst, pidx] = sort(p, 'descend');
[bst, bidx] = sort(b(u, :), 'descend');

%% ===== MAE ===== %
count = sum(b(u, :) > 0);
MAE = sum(abs(p(b(u, :) > 0) - b(u, b(u, :) > 0))) / count;

%% ===== test ===== %
all_p = zeros(row, column);
for i = 1:row
    all_p(i, :) = predict(b, sim, i, k);
end
all_p(isnan(all_p)) = 0;
count = sum(sum(b > 0));
MAE = sum(sum(abs(all_p(b > 0) - b(b > 0)))) / count;