function compare_fit_lin_corr_data

[filename,path] = uigetfile('multiselect','on','.mat');
cd(path)

figure('position',[50 300 2000 600]);

data_D_lin = cell(1,length(filename));
data_D_corr = cell(1,length(filename));
data_R_c = cell(1,length(filename));
name = cell(1,length(filename));

for n  = 1:length(filename)
    
    res = importdata(filename{n});
    
    data_D_lin{n} = res.lin.D_lin;
    
    name{n} = filename{n};

    size_1 = size(res.corr,1); % number of trajectories that have been analyzed with the corraled fitting
    for i = 1:size_1
       data_D_corr{n} = [data_D_corr{n} res.corr(i).D_corr{:}];
       data_R_c{n} = [data_R_c{n} res.corr(i).R_c{:}];
    end

end

subplot(1,3,1)
title('Diffusion calculated from linear fitting')
distributionPlot(data_D_lin,'xName',name,'yLabel','Diffusion (\mum^2.s^{-1})','histOri','right','xyOri','flipped')

subplot(1,3,2)
title('Diffusion calculated from corraled fitting')
distributionPlot(data_D_corr,'xName',name,'yLabel','Diffusion (\mum^2.s^{-1})','histOri','right','xyOri','flipped')

subplot(1,3,3)
title('Radius of confinement')
distributionPlot(data_R_c,'xName',name,'yLabel','Radius of confinement (\mum)','histOri','right','xyOri','flipped')


end