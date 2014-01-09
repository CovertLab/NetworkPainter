function %s()
% BooleanSimulation
%
%  Simulates biological network using boolean expression rules.
%
%  Title: %s
%  Subject: %s
%  Author: %s
%  Creator: %s
%  Last Updated: %s

% time points
times = {%s};

% biomolecules
%s

% conditions
%s

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