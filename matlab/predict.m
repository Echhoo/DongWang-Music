function p = predict(x, sim, u, k)

[st, index] = sort(sim, 2, 'descend');
simk = st(u, 1:k); % ǰ k ���ٽ��û������ƶ�
idxk = index(u, 1:k);   % ǰ k ���ٽ��û���id
m = mean(x, 2);     % �����û����ֵ�ƽ��ֵ
mu = m(u, :);       % Ŀ���û����ֵ�ƽ��ֵ

if sum(simk) ~= 0
    p = mu + simk * (x(idxk, :) - m(idxk)) / sum(simk);
else
    p = zeros(1, size(x, 2));
end
fprintf("predict %d finished!\n", u);
end