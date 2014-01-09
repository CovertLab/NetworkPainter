function BooleanSimulation()
% BooleanSimulation
%
%  Simulates biological network using boolean expression rules.
%
%  Title: NF-kB
%  Subject: NF-kB (nuclear factor kappa-light-chain-enhancer of activated B cells) is a protein complex that acts as a transcription factor. NF-kB is found in almost all animal cell types and is involved in cellular responses to stimuli such as stress, cytokines, free radicals, ultraviolet irradiation, oxidized LDL, and bacterial or viral antigens. NF-kB plays a key role in regulating the immune response to infection. Consistent with this role, incorrect regulation of NF-kB has been linked to cancer, inflammatory and autoimmune diseases, septic shock, viral infection, and improper immune development. NF-kB has also been implicated in processes of synaptic plasticity and memory.References:- TD Gilmore (2006). Introduction to NF-B: players, pathways, perspectives. Oncogene. 25 (51): 6680-4.- AR Brasier (2006). The NF-B regulatory network. Cardiovasc. Toxicol. 6 (2): 111-30.- ND Perkins (2007). Integrating cell-signalling pathways with NF-B and IKK function. Nat. Rev. Mol. Cell Biol. 8 (1): 49-62.
%  Author: Jonathan Karr
%  Creator: NetworkAnalyzer
%  Last Updated: Tue Mar 31 2009 07:31:03 PM

% time points
times={'0m';'4m';'16m';'60m';'90m'};

% biomolecules
biomolecules=struct('name','','expression','','initialCondition',[]);
biomolecules(1)=struct('name','receptor1','expression','signal1','initialCondition',0);
biomolecules(2)=struct('name','receptor2','expression','signal2','initialCondition',0);
biomolecules(3)=struct('name','signal1','expression','true','initialCondition',0);
biomolecules(4)=struct('name','signal2','expression','true','initialCondition',0);
biomolecules(5)=struct('name','IKK','expression','receptor1 || receptor2','initialCondition',0);
biomolecules(6)=struct('name','nfkb_cytoplasm','expression','~ikba','initialCondition',0);
biomolecules(7)=struct('name','ikba','expression','~IKK','initialCondition',0);
biomolecules(8)=struct('name','nfkb_nucleus','expression','nfkb_cytoplasm','initialCondition',0);
biomolecules(9)=struct('name','mRNA_cytoplasm','expression','mRNA_nucleus','initialCondition',0);
biomolecules(10)=struct('name','protein','expression','mRNA_cytoplasm','initialCondition',0);
biomolecules(11)=struct('name','mRNA_nucleus','expression','gene_expression','initialCondition',0);
biomolecules(12)=struct('name','gene_expression','expression','nfkb_nucleus','initialCondition',0);

% conditions
conditions=struct('name','','perturbations',[]);
conditions(1)=struct('name','aBCR','perturbations',[]);
conditions(1).perturbations=struct('biomolecule','','expression','');
conditions(1).perturbations(1)=struct('biomolecule','signal1','expression','false');
conditions(2)=struct('name','aBCR H2O2','perturbations',[]);
conditions(2).perturbations=struct('biomolecule','','expression','');
conditions(2).perturbations(1)=struct('biomolecule','signal2','expression','false');

% allocate
states=zeros(length(biomolecules),length(times),length(conditions));

% loop over conditions
for i=1:length(conditions)
    % initial conditions
    states(:,1,i)=initialState(times(1),biomolecules,conditions(i).perturbations);    

    % loop over times, evaluate perturbations and expression rules
    for j=2:length(times)
        states(:,j,i)=evolveState(times(j),states(:,j,i),biomolecules,conditions(i).perturbations);
    end
    
    % plot
    cols=ceil(sqrt(length(conditions)));
    rows=ceil(length(conditions)/cols);
    subplot(rows,cols,i);
    plotTimeCourse(times,states(:,:,i),biomolecules,conditions(i).name);
end

% initial conditions
function state=initialState(time,biomolecules,perturbations)
state=[biomolecules.initialCondition];
for i=1:length(perturbations)
    biomoleculeIdx=findBiomolecule(biomolecules,perturbations(i).biomolecule);
    if(biomoleculeIdx>0)
        state(biomoleculeIdx)=eval(perturbations(i).expression);
    end
end

% time evolution
function state2=evolveState(time,state1,biomolecules,perturbations)
vectorToVariables({biomolecules.name},state1);
state2=zeros(size(state1));
for i=1:length(biomolecules)
    perturbationIdx=findPerturbation(perturbations,biomolecules(i).name);
    if(perturbationIdx>0)
        state2(i)=eval(perturbations(perturbationIdx).expression);
    else
        state2(i)=eval(biomolecules(i).expression);
    end
end

% plot simulation as heatmap
function plotTimeCourse(times,states,biomolecules,condition)
img=zeros(size(states,1),size(states,2),3);
for i=1:size(states,1)
    for j=1:size(states,2)
        if(states(i,j))
            img(i,j,:)=[0 1 0];
        else 
            img(i,j,:)=[1 0 0];             
        end
    end
end

image(img);
axis(gca,'ij');
box(gca,'on');

title(condition,'FontSize',12);
xlabel('Time','FontSize',12);
ylabel('Biomolecule','FontSize',12);
set(gca,'FontSize',8,'TickLength',[0 0]);
set(gca,'XTick',[1:length(times)],'XTickLabel',times,'XAxisLocation','top');
set(gca,'YTick',[1:length(biomolecules)],'YTickLabel',{biomolecules.name});

function idx=findBiomolecule(biomolecules,name)
idx=0;
for i=1:length(biomolecules)
    if(strcmp(biomolecules(i).name,name))
        idx=i;
        break;
    end
end

function idx=findPerturbation(perturbations,biomoleculename)
idx=0;
for i=1:length(perturbations)
    if(strcmp(perturbations(i).biomolecule,biomoleculename))
        idx=i;
        break;
    end
end

% assign in caller variables with names and values
function vectorToVariables(names,values)
for i=1:length(names)
    assignin('caller',names{i},values(i));
end