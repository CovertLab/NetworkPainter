function PBMC_immune_signaling()
% BooleanSimulation
%
%  Simulates biological network using boolean expression rules.
%
%  Title: PBMC immune signaling
%  Subject: This diagram depicts the human peripheral blood mononuclear cell (PBMC) immune signaling network. PBMCs are a critical component of the immune system, helping fight infection and adapt to intruders. The diagram is modified from Figure S6 of Bodenmiller et al., 2012.
%  Author: Jonathan Karr
%  Creator: NetworkAnalyzer
%  Last Updated: Tue Jan 29 2013 07:33:56 PM

% time points
times = {'0'''};

% biomolecules
biomolecules = repmat(struct('name', '', 'expression', '', 'initialCondition', []), 34, 1);
biomolecules(1) = struct('name', 'AKT', 'expression', 'PI3K', 'initialCondition', 0);
biomolecules(2) = struct('name', 'BCR', 'expression', 'true', 'initialCondition', 0);
biomolecules(3) = struct('name', 'BLNK', 'expression', 'SYK', 'initialCondition', 0);
biomolecules(4) = struct('name', 'BTK', 'expression', 'SYK', 'initialCondition', 0);
biomolecules(5) = struct('name', 'CD22', 'expression', 'true', 'initialCondition', 0);
biomolecules(6) = struct('name', 'ERK', 'expression', 'MEK', 'initialCondition', 0);
biomolecules(7) = struct('name', 'GeneExpression', 'expression', 'STAT1 || STAT3 || STAT5 || S6 || ERK || p38 || NFkB', 'initialCondition', 0);
biomolecules(8) = struct('name', 'GRB_SOS', 'expression', 'BLNK || PLC', 'initialCondition', 0);
biomolecules(9) = struct('name', 'IkB', 'expression', 'IKK', 'initialCondition', 0);
biomolecules(10) = struct('name', 'IKK', 'expression', 'PKC', 'initialCondition', 0);
biomolecules(11) = struct('name', 'JAK', 'expression', 'true', 'initialCondition', 0);
biomolecules(12) = struct('name', 'LAT', 'expression', 'Zap70', 'initialCondition', 0);
biomolecules(13) = struct('name', 'MEK', 'expression', 'RAF', 'initialCondition', 0);
biomolecules(14) = struct('name', 'MEKK', 'expression', 'PKC', 'initialCondition', 0);
biomolecules(15) = struct('name', 'MKK', 'expression', 'MEKK', 'initialCondition', 0);
biomolecules(16) = struct('name', 'mTOR', 'expression', 'AKT', 'initialCondition', 0);
biomolecules(17) = struct('name', 'NFkB', 'expression', 'IkB', 'initialCondition', 0);
biomolecules(18) = struct('name', 'p38', 'expression', 'MKK', 'initialCondition', 0);
biomolecules(19) = struct('name', 'PI3K', 'expression', 'BTK', 'initialCondition', 0);
biomolecules(20) = struct('name', 'PKC', 'expression', 'PLC', 'initialCondition', 0);
biomolecules(21) = struct('name', 'PLC', 'expression', 'BTK || PI3K || BLNK || LAT || Zap70', 'initialCondition', 0);
biomolecules(22) = struct('name', 'RAF', 'expression', 'RAS', 'initialCondition', 0);
biomolecules(23) = struct('name', 'RAS', 'expression', 'GRB_SOS || PKC', 'initialCondition', 0);
biomolecules(24) = struct('name', 'RSK', 'expression', 'ERK', 'initialCondition', 0);
biomolecules(25) = struct('name', 'S6', 'expression', 'mTOR || RSK', 'initialCondition', 0);
biomolecules(26) = struct('name', 'SFK', 'expression', 'SHP', 'initialCondition', 0);
biomolecules(27) = struct('name', 'SHP', 'expression', 'CD22 && ~SFK', 'initialCondition', 0);
biomolecules(28) = struct('name', 'SLP76', 'expression', 'LAT', 'initialCondition', 0);
biomolecules(29) = struct('name', 'STAT1', 'expression', 'SFK || JAK', 'initialCondition', 0);
biomolecules(30) = struct('name', 'STAT3', 'expression', 'SFK || JAK', 'initialCondition', 0);
biomolecules(31) = struct('name', 'STAT5', 'expression', 'SFK || JAK', 'initialCondition', 0);
biomolecules(32) = struct('name', 'SYK', 'expression', 'BCR || SFK', 'initialCondition', 0);
biomolecules(33) = struct('name', 'TCR', 'expression', 'true', 'initialCondition', 0);
biomolecules(34) = struct('name', 'Zap70', 'expression', 'TCR', 'initialCondition', 0);

% conditions
conditions = repmat(struct('name', '', 'perturbations', []), 1, 1);
conditions(1) = struct('name', 'Basal condition', 'perturbations', []);

% allocate
states = zeros(length(biomolecules), length(times), length(conditions));

% loop over conditions
for i = 1:length(conditions)
    % initial conditions
    states(:, 1, i) = initialState(times(1), biomolecules, conditions(i).perturbations);

    % loop over times, evaluate perturbations and expression rules
    for j = 2:length(times)
        states(:, j, i) = evolveState(times(j), states(:, j, i), biomolecules, conditions(i).perturbations);
    end
    
    % plot
    cols = ceil(sqrt(length(conditions)));
    rows = ceil(length(conditions) / cols);
    subplot(rows, cols, i);
    plotTimeCourse(times, states(:, :, i), biomolecules, conditions(i).name);
end

% initial conditions
function state = initialState(time, biomolecules, perturbations)
state = [biomolecules.initialCondition];
for i = 1:length(perturbations)
    biomoleculeIdx = findBiomolecule(biomolecules,perturbations(i).biomolecule);
    if biomoleculeIdx > 0
        state(biomoleculeIdx) = eval(perturbations(i).expression);
    end
end

% time evolution
function state2 = evolveState(time, state1, biomolecules, perturbations)
vectorToVariables({biomolecules.name}, state1);
state2 = zeros(size(state1));
for i = 1:length(biomolecules)
    perturbationIdx = findPerturbation(perturbations,biomolecules(i).name);
    if perturbationIdx > 0
        state2(i) = eval(perturbations(perturbationIdx).expression);
    else
        state2(i) = eval(biomolecules(i).expression);
    end
end

% plot simulation as heatmap
function plotTimeCourse(times, states, biomolecules, condition)
img = zeros(size(states, 1), size(states, 2), 3);
for i = 1:size(states, 1)
    for j = 1:size(states, 2)
        if states(i, j)
            img(i, j, :) = [0 1 0];
        else 
            img(i, j, :) = [1 0 0];
        end
    end
end

image(img);
axis(gca, 'ij');
box(gca, 'on');

title(gca, condition, 'FontSize', 12);
xlabel(gca, 'Time', 'FontSize', 12);
ylabel(gca, 'Biomolecule', 'FontSize', 12);
set(gca, 'FontSize', 8, 'TickLength', [0 0]);
set(gca, 'XTick', 1:length(times), 'XTickLabel', times, 'XAxisLocation', 'top');
set(gca, 'YTick', 1:length(biomolecules), 'YTickLabel', {biomolecules.name});

function idx = findBiomolecule(biomolecules, name)
idx = 0;
for i = 1:length(biomolecules)
    if strcmp(biomolecules(i).name, name)
        idx = i;
        break;
    end
end

function idx = findPerturbation(perturbations, biomoleculename)
idx = 0;
for i = 1:length(perturbations)
    if strcmp(perturbations(i).biomolecule, biomoleculename)
        idx = i;
        break;
    end
end

% assign in caller variables with names and values
function vectorToVariables(names, values)
for i = 1:length(names)
    assignin('caller', names{i}, values(i));
end