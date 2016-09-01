function pool_data_fit_lin_corr_V2

[filename,path] = uigetfile('.mat','multiselect','on');
cd(path)

lin_fit = cell(1,1);
Dlin = [];

corr_fit = cell(1,2);
Dcorr = [];
Rc = [];

size_MSD = [];

eps = [];

for i = 1:length(filename)
    
    res = importdata(filename{i});

    Dlin = [Dlin,res.lin.D_lin'];
    
    eps = cat(1,eps,res.ergo.ergo);
    
    size_MSD = [size_MSD;length(res.MSD.MSD_ens{:})];
    
    size_1 = size(res.corr,1);
    for j = 1:size_1
        Dcorr = [Dcorr;res.corr(j).D_corr{1}(:)];
        Rc = [Rc;res.corr(j).R_c{1}(:)];
    end
  
end


min_MSD_length = min(size_MSD);

MSD_e = zeros(length(filename),min_MSD_length);
MSD_t = zeros(length(filename),min_MSD_length);


for i = 1:length(filename)
   MSD_e(i,:) = res.MSD.MSD_ens{1}(1:min_MSD_length);
   MSD_t(i,:) = res.MSD.MSD_time{1}(1:min_MSD_length);
end

MSD_ens = mean(MSD_e,1);
MSD_time = mean(MSD_t,1);

lin_fit = {Dlin};
corr_fit = {{Dcorr},{Rc}};
MSD = {{MSD_ens},{MSD_time}};

ergo = {eps};

row_headings = {'D_corr','R_c'};
extract_corr = cell2struct(corr_fit,row_headings,2);
extract_lin = cell2struct(lin_fit,'D_lin',1);
row_headings = {'MSD_ens','MSD_time'};
extract_MSD = cell2struct(MSD,row_headings,2);
extract_ergo = cell2struct(ergo,'ergo',1);

pool = struct('lin',extract_lin,'corr',extract_corr,'MSD',extract_MSD,...
    'ergo',extract_ergo);

uisave('pool')








end