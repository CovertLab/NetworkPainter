function BooleanSimulation()
% BooleanSimulation
%
%  Simulates biological network using boolean expression rules.
%
%  Title: TCR Signaling
%  Subject: The adaptive phase of the immune response begins with engagement on CD4+ helper T cells of the T cell antigen receptor (TCR) by its ligand, a small foreign peptide bound to a cell surface protein of the class II major histocompatibility complex (peptide-MHC) expressed on an antigen-presenting cell. This engagement initiates a series of biochemical events that can differentially signal the naive T cell to: 1) enter into a pathway leading to generation of effector T cells with the onset of rapid proliferation and production of effector cytokines; 2) enter into a state of antigenic non-responsiveness known as anergy; or 3) die by apoptosis. The type of response elicited depends on multiple factors including the affinity of the interaction, the duration of the interaction, and the presence or absence of various costimulatory signaling inputs such as those provided by the CD4 coreceptor and the CD28 costimulatory receptor.References- Yanping Huang and Ronald L. Wange (2004). T Cell Receptor Signaling: Beyond Complex Complexes. J. Biol. Chem. 279 (28): 28827-28830.
%  Author: Jonathan Karr
%  Creator: NetworkAnalyzer
%  Last Updated: Tue Mar 31 2009 09:46:13 PM

% time points
times={'0m';'4m';'16m';'60m';'90m'};

% biomolecules
biomolecules=struct('name','','expression','','initialCondition',[]);
biomolecules(1)=struct('name','Peptide_MHC','expression','true','initialCondition',0);
biomolecules(2)=struct('name','CD40','expression','true','initialCondition',0);
biomolecules(3)=struct('name','TCR_CD3','expression','Peptide_MHC','initialCondition',0);
biomolecules(4)=struct('name','Lck','expression','CD40','initialCondition',0);
biomolecules(5)=struct('name','ZAP70','expression','TCR_CD3','initialCondition',0);
biomolecules(6)=struct('name','Itk','expression','Lck && ZAP70','initialCondition',0);
biomolecules(7)=struct('name','Akt','expression','Itk','initialCondition',0);
biomolecules(8)=struct('name','NFAT_cytoplasm','expression','true','initialCondition',0);
biomolecules(9)=struct('name','NFAT_nucleus','expression','NFAT_cytoplasm','initialCondition',0);
biomolecules(10)=struct('name','c_Fos','expression','ERK','initialCondition',0);
biomolecules(11)=struct('name','c_Jun','expression','PKCt','initialCondition',0);
biomolecules(12)=struct('name','p50_nucleus','expression','p50_cytoplasm','initialCondition',0);
biomolecules(13)=struct('name','p65_nucleus','expression','p65_cytoplasm','initialCondition',0);
biomolecules(14)=struct('name','p50_cytoplasm','expression','~IkB','initialCondition',0);
biomolecules(15)=struct('name','p65_cytoplasm','expression','~IkB','initialCondition',0);
biomolecules(16)=struct('name','IkB','expression','~(IKK && NIK && CAMKII && UBC13)','initialCondition',0);
biomolecules(17)=struct('name','IKK','expression','true','initialCondition',0);
biomolecules(18)=struct('name','RasGRP','expression','true','initialCondition',0);
biomolecules(19)=struct('name','Ras','expression','RasGRP','initialCondition',0);
biomolecules(20)=struct('name','Raf_1','expression','Ras','initialCondition',0);
biomolecules(21)=struct('name','MEK','expression','Raf_1','initialCondition',0);
biomolecules(22)=struct('name','ERK','expression','MEK','initialCondition',0);
biomolecules(23)=struct('name','PKCt','expression','cytoskeleton_reorganization','initialCondition',0);
biomolecules(24)=struct('name','COT','expression','Akt','initialCondition',0);
biomolecules(25)=struct('name','NIK','expression','COT','initialCondition',0);
biomolecules(26)=struct('name','CAMKII','expression','PKCt','initialCondition',0);
biomolecules(27)=struct('name','CARMA1','expression','true','initialCondition',0);
biomolecules(28)=struct('name','Bcl10','expression','true','initialCondition',0);
biomolecules(29)=struct('name','MALT1','expression','true','initialCondition',0);
biomolecules(30)=struct('name','UBC13','expression','true','initialCondition',0);
biomolecules(31)=struct('name','gene_expression_NFAT','expression','NFAT_nucleus','initialCondition',0);
biomolecules(32)=struct('name','gene_expression_ap1','expression','c_Fos && c_Jun','initialCondition',0);
biomolecules(33)=struct('name','gene_expression_nfkb','expression','p50_nucleus && p65_nucleus','initialCondition',0);
biomolecules(34)=struct('name','IL_2','expression','gene_expression_nfkb','initialCondition',0);
biomolecules(35)=struct('name','PI3K','expression','true','initialCondition',0);
biomolecules(36)=struct('name','Nck','expression','true','initialCondition',0);
biomolecules(37)=struct('name','Vav1','expression','true','initialCondition',0);
biomolecules(38)=struct('name','SLP76','expression','true','initialCondition',0);
biomolecules(39)=struct('name','PLCy1','expression','true','initialCondition',0);
biomolecules(40)=struct('name','LAT','expression','true','initialCondition',0);
biomolecules(41)=struct('name','cytoskeleton_reorganization','expression','Nck && Vav1','initialCondition',0);

% conditions
conditions=struct('name','','perturbations',[]);
conditions(1)=struct('name','aBCR','perturbations',[]);
conditions(1).perturbations=struct('biomolecule','','expression','');
conditions(1).perturbations(1)=struct('biomolecule','Peptide_MHC','expression','false');
conditions(2)=struct('name','aBCR H2O2','perturbations',[]);
conditions(2).perturbations=struct('biomolecule','','expression','');
conditions(2).perturbations(1)=struct('biomolecule','IL_2','expression','false');

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