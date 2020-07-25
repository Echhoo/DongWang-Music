function sim = calculateSim(x)
[row, ~] = size(x);
sim = zeros(row);

for i = 1:row
    for j = i + 1:row
        Ui = x(i, :); % i �Ѿ������ֵ���Ŀ
        Uj = x(j, :); % j �Ѿ������ֵ���Ŀ
        si = norm(Ui);
        sj = norm(Uj);
        if si * sj == 0
            continue
        else
            sim(i, j) = dot(Ui, Uj) / (si * sj);
        end
    end
    fprintf("user %d finished!\n", i);
end

sim = sim + sim' + eye(size(sim));

end