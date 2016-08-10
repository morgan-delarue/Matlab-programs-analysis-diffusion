function compare_results
% Function that compare the results obtained for the hop diffusion in
% violin plots


[filename,path] = uigetfile('multiselect','on','.mat');
cd(path)

data_Rc = cell(1,length(filename));
data_Din = cell(1,length(filename));
data_Dout = cell(1,length(filename));
data_Tin = cell(1,length(filename));
name = cell(1,length(filename));

for i = 1:length(filename)
    
    res = importdata(filename{i});
    data_Rc{i} = res.Rc;
    data_Din{i} = res.Din;
    data_Dout{i} = res.Dout;
    data_Tin{i} = res.Tres;
    name{i} = filename{i};
     
end
    
figure('position',[100 30 1200 600])
subplot(2,2,1)
distributionPlot(data_Din,'xName',name,'yLabel','Diffusion in corral (um^2/s)')
subplot(2,2,2)
distributionPlot(data_Dout,'xName',name,'yLabel','Diffusion out of corral (um^2/s)')
subplot(2,2,3)
distributionPlot(data_Rc,'xName',name,'yLabel','Corral radius (um)')
subplot(2,2,4)
distributionPlot(data_Tin,'xName',name,'yLabel','Residency time (s)')







end