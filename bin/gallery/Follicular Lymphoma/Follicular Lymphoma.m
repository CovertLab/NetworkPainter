function BooleanSimulation()
% BooleanSimulation
%
%  Simulates biological network using boolean expression rules.
%
%  Title: Follicular Lymphoma Network
%  Subject: 
%  Author: Ed Chen, Harendra Guturu, Jonathan Karr
%  Creator: NetworkAnalyzer
%  Last Updated: Tue Mar 31 2009 02:23:49 PM

% time points
times={'0m';'4m';'16m';'60m';'90m'};

% biomolecules
biomolecules=struct('name','','expression','','initialCondition',[]);
biomolecules(1)=struct('name','CXCR4','expression','SDF1','initialCondition',0);
biomolecules(2)=struct('name','IL2Rb','expression','IL2 || gC','initialCondition',0);
biomolecules(3)=struct('name','gC','expression','IL2 || IL7 || IL15 || IL4 || IL13','initialCondition',0);
biomolecules(4)=struct('name','gp130','expression','IL6','initialCondition',0);
biomolecules(5)=struct('name','Iga_b','expression','aBCR || H2O2','initialCondition',0);
biomolecules(6)=struct('name','SHP1','expression','Iga_b || aBCR || H2O2','initialCondition',0);
biomolecules(7)=struct('name','CD19','expression','true','initialCondition',0);
biomolecules(8)=struct('name','TRAF6','expression','CpG || CD40L','initialCondition',0);
biomolecules(9)=struct('name','TLR9','expression','CD40L || CpG','initialCondition',0);
biomolecules(10)=struct('name','IRAK1_4','expression','TRAF6 || TLR9','initialCondition',0);
biomolecules(11)=struct('name','LynLck','expression','IL2Rb || Iga_b || SHP1 || CD19','initialCondition',0);
biomolecules(12)=struct('name','SDF1','expression','true','initialCondition',0);
biomolecules(13)=struct('name','IL2','expression','true','initialCondition',0);
biomolecules(14)=struct('name','IL7','expression','true','initialCondition',0);
biomolecules(15)=struct('name','IL15','expression','true','initialCondition',0);
biomolecules(16)=struct('name','IL4','expression','true','initialCondition',0);
biomolecules(17)=struct('name','IL13','expression','true','initialCondition',0);
biomolecules(18)=struct('name','IL6','expression','true','initialCondition',0);
biomolecules(19)=struct('name','IL10','expression','true','initialCondition',0);
biomolecules(20)=struct('name','IFNg','expression','true','initialCondition',0);
biomolecules(21)=struct('name','IFNabd','expression','true','initialCondition',0);
biomolecules(22)=struct('name','Jak2','expression','CXCR4 || gp130 || IFNg || LynLck','initialCondition',0);
biomolecules(23)=struct('name','Jak3','expression','gC','initialCondition',0);
biomolecules(24)=struct('name','Jak1','expression','gC || gp130 || IL10 || IFNg || IFNabd || LynLck','initialCondition',0);
biomolecules(25)=struct('name','Tyk2','expression','gp130 || IL10 || IFNabd','initialCondition',0);
biomolecules(26)=struct('name','Shc','expression','IL2Rb || gp130','initialCondition',0);
biomolecules(27)=struct('name','aBCR','expression','true','initialCondition',0);
biomolecules(28)=struct('name','H2O2','expression','true','initialCondition',0);
biomolecules(29)=struct('name','PMAi','expression','true','initialCondition',0);
biomolecules(30)=struct('name','CD40L','expression','true','initialCondition',0);
biomolecules(31)=struct('name','CpG','expression','true','initialCondition',0);
biomolecules(32)=struct('name','BtkItk','expression','LynLck','initialCondition',0);
biomolecules(33)=struct('name','SykZap','expression','IL2Rb || LynLck || BtkItk','initialCondition',0);
biomolecules(34)=struct('name','PIP3','expression','BtkItk || CD19','initialCondition',0);
biomolecules(35)=struct('name','PLCg2','expression','LynLck || SykZap || BtkItk || PIP3 || Ca2plus','initialCondition',0);
biomolecules(36)=struct('name','Ca2plus','expression','PMAi || PIP3','initialCondition',0);
biomolecules(37)=struct('name','DAG','expression','PLCg2','initialCondition',0);
biomolecules(38)=struct('name','cCbl','expression','true','initialCondition',0);
biomolecules(39)=struct('name','Vav','expression','CD19 || cCbl','initialCondition',0);
biomolecules(40)=struct('name','BLNK','expression','PLCg2 || SykZap','initialCondition',0);
biomolecules(41)=struct('name','Grb2','expression','Shc || BLNK','initialCondition',0);
biomolecules(42)=struct('name','SHIP','expression','Grb2 || BLNK || PIP3','initialCondition',0);
biomolecules(43)=struct('name','SOS','expression','Grb2','initialCondition',0);
biomolecules(44)=struct('name','PKC','expression','DAG || PMAi || Ca2plus','initialCondition',0);
biomolecules(45)=struct('name','Ras','expression','SOS || DAG || PKC','initialCondition',0);
biomolecules(46)=struct('name','NIK','expression','TRAF6','initialCondition',0);
biomolecules(47)=struct('name','Rac','expression','Vav','initialCondition',0);
biomolecules(48)=struct('name','MEKK','expression','Rac','initialCondition',0);
biomolecules(49)=struct('name','MKK3_5_6','expression','MEKK || IRAK1_4','initialCondition',0);
biomolecules(50)=struct('name','MKK4_7','expression','MEKK','initialCondition',0);
biomolecules(51)=struct('name','Raf1','expression','Ras','initialCondition',0);
biomolecules(52)=struct('name','MEK1_2','expression','Raf1','initialCondition',0);
biomolecules(53)=struct('name','IKK','expression','PKC || NIK','initialCondition',0);
biomolecules(54)=struct('name','CaM','expression','Ca2plus','initialCondition',0);
biomolecules(55)=struct('name','Akt','expression','PIP3','initialCondition',0);
biomolecules(56)=struct('name','GSK3b','expression','Akt','initialCondition',0);
biomolecules(57)=struct('name','mTOR','expression','Akt','initialCondition',0);
biomolecules(58)=struct('name','Stat1','expression','Jak2 || Jak1 || LynLck','initialCondition',0);
biomolecules(59)=struct('name','Stat5','expression','Jak2 || Jak1 || LynLck','initialCondition',0);
biomolecules(60)=struct('name','Stat6','expression','Jak3 || Jak1','initialCondition',0);
biomolecules(61)=struct('name','Stat3','expression','Jak1 || Tyk2 || LynLck','initialCondition',0);
biomolecules(62)=struct('name','Erk1_2','expression','MEK1_2','initialCondition',0);
biomolecules(63)=struct('name','IkB','expression','IKK','initialCondition',0);
biomolecules(64)=struct('name','MFkB','expression','IkB','initialCondition',0);
biomolecules(65)=struct('name','NFAT','expression','CaM || GSK3b','initialCondition',0);
biomolecules(66)=struct('name','S6','expression','mTOR','initialCondition',0);
biomolecules(67)=struct('name','JNK1_2','expression','MKK4_7','initialCondition',0);
biomolecules(68)=struct('name','p38','expression','MKK3_5_6','initialCondition',0);

% conditions
conditions=struct('name','','perturbations',[]);
conditions(1)=struct('name','aBCR','perturbations',[]);
conditions(1).perturbations=struct('biomolecule','','expression','');
conditions(1).perturbations(1)=struct('biomolecule','aBCR','expression','false');
conditions(2)=struct('name','aBCR H2O2','perturbations',[]);
conditions(2).perturbations=struct('biomolecule','','expression','');
conditions(2).perturbations(1)=struct('biomolecule','H2O2','expression','false');

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