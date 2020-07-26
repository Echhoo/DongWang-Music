%% ===== init ===== %%
clear all; clc;

%% ===== load Data ===== %%

A = load("user_artists.dat");
a=sparse(A(:,1)', A(:,2)', A(:,3)');%��һ�����У��ڶ������У��������Ǿ������
b = full(a);

%% ===== compute Rating ===== %%
[row, column] = size(b);
% ����ÿ���˶�ÿ�����ֵĲ��Ŵ����������Ŵ���ת��Ϊ����
for i = 1:row
    temp = b(i, b(i,:) > 0);
    m = mean(temp);
    s = std(temp);
    b(i, b(i,:) > 0) = sigmoid((temp - m) / s);
end
b(isnan(b)) = 0;

%% ===== compute person ===== %%
% �����һ�ε����ƶ�
sim = calculateSim(b);

%% ===== add1: �������1 ===== %%
% ��ϡ��������������
X = addData(b, sim);

%% ===== sim2: �ڶ��μ������Ƴ̶� ===== %%
% �����������֮������ƶ�
sim2 = calculateSim(X);

%% ===== ����Ԥ������ ===== %
k = 50;         % ��ѡ���ٽ��û���
all_p = zeros(row, column);
for i = 1:row
    all_p(i, :) = predict(b, sim, i, k);
end
all_p(isnan(all_p)) = 0;

%% ===== MAE ===== %
count = sum(sum(b > 0));         % �û��ܹ����ֵ�����
MAE = sum(sum(abs(all_p(b > 0) - b(b > 0)))) / count;

%% ===== precision ===== %
recommand_num = 30;     % �Ƽ�����
target_rate = 0.5;      % ������ֵ
[bst, bidx] = sort(b, 2, 'descend');
[pst, pidx] = sort(all_p, 2, 'descend');
precision = zeros(row, 1);
for i = 1:row
    pred = pidx(i, 1:recommand_num);            % Ԥ��ĸ���
    origin = bidx(i, bst(i, :) > target_rate);  % ���ֳ�����ֵ�ĸ���
    same = size(intersect(pred, origin), 2);    % �غϵĸ�������
    precision(i) = same / size(origin, 2);
    fprintf("precise %d finished!", i);
end
precise_rate = mean(precision(~isnan(precision)));
