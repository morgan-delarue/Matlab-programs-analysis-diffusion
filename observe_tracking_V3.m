function observe_tracking_V3
% This function is designed to observe the tracking of particles in cells.
% Two finles need to be loaded for this. A structured matlab file,
% containing the time, x and y coordinates, MSD and frame number of a
% particular track, as well as the piture file. Exist_z takes a value 0 if
% these are 2D data, and a value 1 if there is a third dimension. 

close all
% clear all
clc



fig = figure('position',[20 20 1300 650]);

global I
global I_zoom
global result
global num_tracks
global hresults_button
global isolate_idx
global size_tif
global mean_x
global mean_y
global size_zoom
global conv
global dt
global filename
global exist_z
global fig_load_image
global h_frame_start
global h_frame_end
global path_im
global filename_im
global h_slider_image


exist_z = 0;
isolate_idx = [];

h_load_images = uicontrol('Style','Pushbutton','String','Load .tif','Position',[30 160 70 25],...
    'Callback',{@pre_load_image_callback},'visible','off');
h_dt_text = uicontrol('Style','Text','String','dt =','Position',[30 70 35 25],'visible','off');
h_dt_value = uicontrol('Style','Edit','String','0.1','Position',[65 70 35 25],'visible','off');
h_diff_text = uicontrol('Style','Text','String','D =','Position',[30 100 35 25],'visible','off');
h_diff_value = uicontrol('Style','Edit','String','0.05','Position',[65 100 35 25],'visible','off');
h_conv_text = uicontrol('Style','Text','String','conv =','Position',[30 40 35 25],'visible','off');
h_conv_value = uicontrol('Style','Edit','String','0.13','Position',[65 40 35 25],'visible','off');
h_3D_value = uicontrol('Style','popupmenu','String','2D|3D','Position',[30,10,75,25],'Visible','off',...
    'callback',{@threeD_callback});
% h_slider_image = uicontrol('Style','slider','Position',[745 10 470 30],'visible','off',...
%     'min',1,'callback',{@slider_image_callback},'value',1);
uicontrol('Style','Pushbutton','String','Load .mat','Position',[30 130 70 25],'Callback',{@load_mat_callback});
h_thresh_length = uicontrol('Style','Edit','String','40','Position',[540 300 70 25],'visible','off');
h_thresh_length_text = uicontrol('Style','text','String','Thresh. length','Position',[540 320 70 25],'visible','off');
h_replot_button = uicontrol('Style','Pushbutton','String','Replot','Position',[540 270 70 25],...
    'visible','off','callback',{@replot_callback});
h_isolate_button = uicontrol('Style','Pushbutton','String','Isolate','Position',[540 240 70 25],...
    'visible','off','callback',{@isolate_callback});
h_clear_isolate_button = uicontrol('Style','Pushbutton','String','Clear Isolate','Position',[540 210 70 25],...
    'visible','off','callback',{@clear_isolate_callback});
h_zoom_trace = uicontrol('Style','Text','String','Zoom Trace','Position',[540 180 70 25],'Visible','off');
h_zoom_trace_box = uicontrol('Style','Checkbox','Position',[540 160 25 25],'Visible','off','callback',{@zoom_trace_callback});
h_zoom_trace_size = uicontrol('Style','Edit','String','20','Position',[580 160 25 25],'Visible','off');
h_extract_isolate_curve = uicontrol('Style','Pushbutton','String','Extract Isolate','Position',[540 130 70 25],...
    'Visible','off','Callback',{@extract_isolate_curve});
h_sliding_MSD = uicontrol('Style','Pushbutton','String','Sliding MSD','Position',[540 100 70 25],...
    'Visible','off','Callback',{@sliding_MSD_callback});
h_sliding_step = uicontrol('Style','Edit','String','1','Position',[580 70 25 25],'Visible','off');
h_sliding_size = uicontrol('Style','Edit','String','15','Position',[540 70 25 25],'Visible','off');
h_save_figure = uicontrol('Style','Pushbutton','String','Save Data','Position',[540 40 70 25],...
    'Visible','off','Callback',{@save_figure_callback});
h_extract = uicontrol('Style','Pushbutton','String','Extract Data',...
    'Position',[540 10 70 25],'Callback',{@extract_data_sliding_callback},'Visible','off');

columnname =   {'Trajectory','Length','Visible ?', 'Isolate ?'};
columnformat = {'numeric','numeric',[],[]}; 
columneditable =  [false edit true true]; 
hresults_button = uitable('Position',...
            [180,10,350,330], ... 
            'ColumnName', columnname,...
            'ColumnFormat', columnformat,...
            'ColumnEditable', columneditable,...
            'visible','off');

function threeD_callback (source,eventdata)
        
exist_z = get(h_3D_value,'Value')-1;  
end

function save_figure_callback (source,eventdata)

dt = str2double(get(h_dt_value,'String'));
conv = str2double(get(h_conv_value,'String'));    
    
dat = get(hresults_button,'Data');
isolate_idx = find([dat{:,4}] == true);

size_rest_data = length(isolate_idx);

S = [];
for i = 1:size_rest_data
    if i < 10
        S = [S;strcat('part0000',num2str(i))];
    elseif i >= 10 && i < 100
        S = [S;strcat('part000',num2str(i))];
    elseif i >= 100 && i < 999
        S = [S;strcat('part00',num2str(i))];
    elseif i >=1000 && i < 9999
        S = [S;strcat('part0',num2str(i))];
    elseif i >= 10000 && i < 99999
        S = [S;strcat('part',num2str(i))];
    end
end

field = cellstr(S);

rest = cell2struct(field','result',1);



for i = 1:size_rest_data
    new_size = cell2mat(dat(isolate_idx(i),2));
    rest(i).result = struct('time',result(isolate_idx(i)).tracking.time(1:new_size),...
        'x',result(isolate_idx(i)).tracking.x(1:new_size),...
        'y',result(isolate_idx(i)).tracking.y(1:new_size),...
        'MSD',calculate_MSD(result(isolate_idx(i)).tracking.x(1:new_size),...
            result(isolate_idx(i)).tracking.y(1:new_size),0,dt,conv));
end


    
uisave('rest')
        
end

function extract_data_sliding_callback (source,eventdata)
        
dat = get(hresults_button,'Data');
isolate_idx = find([dat{:,4}] == true);    
    
size_rest_data = length(isolate_idx);

Din = [];
Dout = [];
Rc = [];
tres = [];
alpha = [];

dt = str2double(get(h_dt_value,'String'));
conv = str2double(get(h_conv_value,'String'));
D0 = str2double(get(h_diff_value,'String'));
f_exp = fittype('a^2*(1-exp(-b*x))');
f_lin = fittype('a*x');
count = 0;

h = waitbar(0,'Fitting and extracting data...');

for j = 1:size_rest_data
    
    time = result(isolate_idx(j)).tracking.time;
    x = result(isolate_idx(j)).tracking.x;
    y = result(isolate_idx(j)).tracking.y;
    
    [n,der,center,radius,idx] = number_cluster(time',x',y',5,0.8,0);
    idx_unique = unique(idx);
    for i = 1:n
            xr = x(idx==idx_unique(i));
            yr = y(idx==idx_unique(i));
            
            [MSDr,tr] = calculate_MSD_V2(xr,yr,0,dt,conv);
            
            size_r = 4*round(length(xr)/5);
            if round(size_r/2) == size_r/2
                weight = [20*ones(1,size_r/2),ones(1,size_r/2)];
            else
                weight = [20*ones(1,round(size_r/2)),ones(1,floor(size_r/2))];
            end
            
            [yy_lin,gof_lin] = fit(tr(1:size_r)',MSDr(1:size_r)',f_lin,...
                'Startpoint',[D0],'weight',weight,'display','off');
            [yy_exp,gof_exp] = fit(tr(1:size_r)',MSDr(1:size_r)',f_exp,...
                'Startpoint',[(conv*radius(i)),D0/((conv*radius(i))^2)],...
                'Robust','Bisquare',...
                'Weight',weight,'display','off');
  
            lin_or_expo = gof_lin.rsquare/gof_exp.rsquare;
            
            if lin_or_expo < 0.7
                Din = [Din;yy_exp.a^2*yy_exp.b/4];
                Rc = [Rc;sqrt(5/2)*yy_exp.a];
                tres = [tres;length(xr)*dt];
            elseif lin_or_expo > 0.7
                yy_pow = fit(tr(2:size_r)',MSDr(2:size_r)','power1',...
                'Startpoint',[D0 1],'weight',weight(2:end),'display','off',...
                'Lower',[0 0]);
                Dout = [Dout;yy_pow.a];
                alpha = [alpha;yy_pow.b];
            end
            
    end
    
count = count +1; 
waitbar(count/size_rest_data)
  
end       
 
saving_name = strcat('result_',filename);

extract = struct('Din',Din,'Dout',Dout,'Rc',Rc,'Tres',tres,'alpha',alpha);

save(saving_name,'extract')
% uisave('extract')

disp('Data saved')
close(h)
        
end

function sliding_MSD_callback (source,eventdata)

D0 = str2double(get(h_diff_value,'String'));
dt = str2double(get(h_dt_value,'String'));
conv = str2double(get(h_conv_value,'String'));
    
if length(isolate_idx) == 1
    
    sliding_step = str2double(get(h_sliding_step,'String'));
    sliding_size = str2double(get(h_sliding_size,'String'));
    MSD_length = length(result(isolate_idx).tracking.x);
    chunks_number = floor((MSD_length-sliding_size)/sliding_step);
    
    D = zeros(1,chunks_number);
    R_c = zeros(1,chunks_number);
    t_res = zeros(1,chunks_number);
    
    for i = 1:chunks_number
        t_res(i) = result(isolate_idx).tracking.time(1+(i-1)*sliding_step);
    end
    
    
    MSD_sliding = zeros(sliding_size,chunks_number);

       
    for i = 1:chunks_number
        if exist_z == 0
            MSD_sliding(:,i) = calculate_MSD(result(isolate_idx).tracking.x(1+(i-1)*sliding_step:(i-1)*sliding_step + sliding_size),...
                result(isolate_idx).tracking.y(1+(i-1)*sliding_step:(i-1)*sliding_step + sliding_size),...
                0,dt,conv);
            MSD_sliding(:,i) = MSD_sliding(:,i) - MSD_sliding(1,i);
        elseif exist_z == 1
            MSD_sliding(:,i) = calculate_MSD(result(isolate_idx).tracking.x(1+(i-1)*sliding_step:(i-1)*sliding_step + sliding_size),...
                result(isolate_idx).tracking.y(1+(i-1)*sliding_step:(i-1)*sliding_step + sliding_size),...
                result(isolate_idx).tracking.z(1+(i-1)*sliding_step:(i-1)*sliding_step + sliding_size),...
                dt,conv);
            MSD_sliding(:,i) = MSD_sliding(:,i) - MSD_sliding(1,i);
        end
    end
    
    
    
fexp = fittype('a^2*(1-exp(-b*x))');
flin = fittype('a*x');
fpow = fittype('a*x^b');
   
figure('Position',[100 100 1200 500]);

for i = 1:chunks_number
    
    t = result(isolate_idx).tracking.time(1+(i-1)*sliding_step:(i-1)*sliding_step+sliding_size);
%     length(t)
%     t = (i-1)*sliding_step:dt:(i-1)*sliding_step + sliding_size;
%     length(t)
    t_fit = t-t(1);
    [yy_exp,gof_exp] = fit(t_fit(1:end-1),...
        MSD_sliding(1:end-1,i),fexp,'Lower',[0 0],'Robust','BiSquare','StartPoint',[1,3]);
    [yy_lin,gof_lin] = fit(t_fit(1:end-1),...
        MSD_sliding(1:end-1,i),flin,'Robust','BiSquare','StartPoint',[D0]);

    lin_or_expo = gof_lin.rsquare/gof_exp.rsquare;
    
    if lin_or_expo < 0.7
                
        D(i) = yy_exp.b*yy_exp.a^2/4;
        R_c(i) = sqrt(5/2)*yy_exp.a;

        subplot(2,2,1)
        title('Chunked MSD')
        hold on
        plot(t_fit+t(1),yy_exp.a^2*(1-exp(-yy_exp.b*t_fit)),'r')
        plot(result(isolate_idx).tracking.time(1+(i-1)*sliding_step:(i-1)*sliding_step+sliding_size),MSD_sliding(:,i),'b')
        
        subplot(2,2,2)
        plot(t_res(1:i),R_c(1:i),'r')
        title('Radius of confinement')
        axis([0 t_res(end) 0 1])
    
        subplot(2,2,3)
        plot(t_res(1:i),D(1:i),'r')
        title('Diffusion coefficient')
    
    elseif lin_or_expo > 0.7
        
%         yy_pow = fit(t_fit(1:end-1),...
%         MSD_sliding(1:end-1,i),fpow,'Robust','BiSquare','StartPoint',[D0 1],'Upper',[10 10],'Lower',[0 0]);
        
        D(i) = yy_lin.a/4;
        R_c(i) = 10;
        
        subplot(2,2,1)
        title('Chunked MSD')
        hold on
        plot(t_fit+t(1),yy_lin.a*t_fit,'r--')
        plot(result(isolate_idx).tracking.time(1+(i-1)*sliding_step:(i-1)*sliding_step+sliding_size),MSD_sliding(:,i),'b')
        
%         subplot(2,2,4)
%         title('D_\alpha VS \alpha')
%         hold all
%         plot(yy_pow.a,yy_pow.b,'ro')
        
        subplot(2,2,2)
        plot(t_res(1:i),R_c(1:i),'r')
        title('Radius of confinement')
        axis([0 t_res(end) 0 1])
    
        subplot(2,2,3)
        plot(t_res(1:i),D(1:i),'r')
        title('Diffusion coefficient')
        
    end
        
        
    

    
    
    
    
end


    
    
end
    
end

function extract_isolate_curve (source,eventdata)

dt = str2double(get(h_dt_value,'String'));
conv = str2double(get(h_conv_value,'String'));
D0 = str2double(get(h_diff_value,'String'));
f_exp = fittype('a^2*(1-exp(-b*x))');
f_lin = fittype('a*x');
    
    if length(isolate_idx) == 1
        
       if exist_z == 0
        figure('Position',[100 100 1600 500])
        time = result(isolate_idx).tracking.time;
        MSD = result(isolate_idx).tracking.MSD;
        x = result(isolate_idx).tracking.x;
        y = result(isolate_idx).tracking.y;
        MSD_length = length(result(isolate_idx).tracking.x);
        SD = zeros(MSD_length,1);
        
        SD = conv^2*(result(isolate_idx).tracking.x - result(isolate_idx).tracking.x(1)).^2 + ...
        conv^2*(result(isolate_idx).tracking.y - result(isolate_idx).tracking.y(1)).^2;
        
        z = zeros(size(time));
        
        [n,der,center,radius,idx] = number_cluster(time',x',y',5,0.8,0);
        idx_unique = unique(idx);


        
        
        
        
%         surface([time';time'],[MSD';MSD'],[z';z'],[time';time'],'facecol','no','edgecol','interp','linew',2)
        
%         surface([x';x'],[y';y'],[z';z'],[time';time'],'facecol','no','edgecol','interp','linew',0.5)
%         hold all
        t = linspace(0,2*pi);
        for i = 1:n
            xr = x(idx==idx_unique(i));
            yr = y(idx==idx_unique(i));
            
            if length(xr) > 10
            
            [MSDr,tr] = calculate_MSD_V2(xr,yr,0,dt,conv);
            
            MSDr = MSDr - MSDr(1);
            
            size_r = 4*round(length(xr)/5);
            if round(size_r/2) == size_r/2
                weight = [20*ones(1,size_r/2),ones(1,size_r/2)];
            else
                weight = [20*ones(1,round(size_r/2)),ones(1,floor(size_r/2))];
            end
            
            [yy_lin,gof_lin] = fit(tr(1:size_r)',MSDr(1:size_r)',f_lin,...
                'Startpoint',[D0],'weight',weight,'display','off');
            [yy_exp,gof_exp] = fit(tr(1:size_r)',MSDr(1:size_r)',f_exp,...
                'Startpoint',[(conv*radius(i)),D0/((conv*radius(i))^2)],...
                'Robust','Bisquare',...
                'Weight',weight,'display','off');
            
            lin_or_expo = gof_lin.rsquare/gof_exp.rsquare;
            
            subplot(1,3,2)
            title('Clustered tracks')
            hold all
            plot(xr,yr)
            plot(center(1,i)+radius(i)*cos(t),center(2,i)+radius(i)*sin(t),'r')
            axis equal
            subplot(1,3,3)
            title('Reduced MSD')
            hold all
            plot(tr,MSDr)
            if lin_or_expo < 0.7
                plot(yy_exp,'r-')
            elseif lin_or_expo > 0.7
                yy_pow = fit(tr(2:size_r)',MSDr(2:size_r)','power1',...
                'Startpoint',[0.005 1],'weight',weight(2:end),'display','off',...
                'Lower',[0 0]);
                plot(yy_pow,'r--')
            end
                
%             plot(time,MSD,'k')

            end
        end
        
%         surface([x';x'],[y';y'],[z';z'],[time';time'],'facecol','no','edgecol','interp','linew',2)


        
        subplot(1,3,1)
%         surface([time';time'],[SD';SD'],[z';z'],[time';time'],'facecol','no','edgecol','interp','linew',2)
        surface([x';x'],[y';y'],[z';z'],[time';time'],'facecol','no','edgecol','interp','linew',1)
        axis equal
        colormap jet
        title('Track')
%         subplot(1,4,4)
%         plot(der)
%         axis([0 9 0 1])
%         text(3,0.8,num2str(n))
        
       elseif exist_z == 1
        figure('Position',[100 100 1600 500])
        time = result(isolate_idx).tracking.time;
        MSD = result(isolate_idx).tracking.MSD;
        x = result(isolate_idx).tracking.x;
        y = result(isolate_idx).tracking.y;
        z_data = result(isolate_idx).tracking.z;
        MSD_length = length(result(isolate_idx).tracking.x);
        SD = zeros(MSD_length,1);
        
        SD = conv^2*(result(isolate_idx).tracking.x - result(isolate_idx).tracking.x(1)).^2 + ...
        conv^2*(result(isolate_idx).tracking.y - result(isolate_idx).tracking.y(1)).^2 + ...
        conv^2*(result(isolate_idx).tracking.z - result(isolate_idx).tracking.z(1)).^2;
        
        z = zeros(size(time));
        
        [n,der,center,radius,idx] = number_cluster(time',x',y',5,0.8,0);
        
        subplot(1,4,1)
        surface([time';time'],[MSD';MSD'],[z';z'],[time';time'],'facecol','no','edgecol','interp','linew',2)
        subplot(3,4,2)
        surface([x';x'],[z_data';z_data'],[z';z'],[time';time'],'facecol','no','edgecol','interp','linew',2)
        subplot(3,4,5)
        surface([y';y'],[z_data';z_data'],[z';z'],[time';time'],'facecol','no','edgecol','interp','linew',2)
        subplot(3,4,8)
        surface([x';x'],[y';y'],[z';z'],[time';time'],'facecol','no','edgecol','interp','linew',2)
        subplot(1,4,3)
        surface([time';time'],[SD';SD'],[z';z'],[time';time'],'facecol','no','edgecol','interp','linew',2)
        colormap jet
        subplot(1,4,4)
        plot(der)
        axis([0 9 0 1])
        text(3,0.8,num2str(n))
           
       end
 
       
    end

    
end

function zoom_trace_callback (source,eventdata)
   
if get(h_zoom_trace_box,'Value') == 1
    if length(isolate_idx) == 1
            
        size_zoom = floor(str2double(get(h_zoom_trace_size,'String')));
        I_zoom = zeros(size_zoom+1,size_zoom+1,size_tif);
       
        mean_x = mean(result(isolate_idx).tracking.x);
        mean_y = mean(result(isolate_idx).tracking.y);
    
        rect_zoom = [floor(mean_x - size_zoom/2) floor(mean_y + size_zoom/2) size_zoom size_zoom];

            for i = 1:size_tif
               I_zoom(:,:,i) = imcrop(I(:,:,i),rect_zoom);
            end
            
        end
    end
end

function clear_isolate_callback (source,eventdata)
    
    if length(isolate_idx) >= 1
        
        dat = get(hresults_button,'Data'); 
        for i = 1:length(isolate_idx)
            dat(isolate_idx(i),4) = {false};
        end
        isolate_idx = [];
        
        set(hresults_button,'Data',dat)
        
    end
    
    thresh_length = str2double(get(h_thresh_length,'String'));

delete(subplot(2,2,1))
subplot(2,2,1)
hold all

dat=get(hresults_button,'Data');

for i = 1:num_tracks
    if length(result(i).tracking.x) >= thresh_length
        plot(result(i).tracking.time,result(i).tracking.MSD)
        dat(i,3) = {true};
    else
        dat(i,3) = {false};
    end
end

set(hresults_button,'Data',dat)
    
end

function isolate_callback (source,eventdata)

dt = str2double(get(h_dt_value,'String'));
conv = str2double(get(h_conv_value,'String'));    
    
dat = get(hresults_button,'Data');

isolate_idx = find([dat{:,4}] == true);
   
delete(subplot(2,2,1))
subplot(2,2,1)
hold all

% for i = 1:length(isolate_idx)
%     new_size = cell2mat(dat(isolate_idx(i),2));
%     if length(result(isolate_idx(i)).tracking.frame) > new_size
%         result(isolate_idx(i)).tracking.MSD(1:new_size) = calculate_MSD(result(isolate_idx(i)).tracking.x(1:new_size),...
%             result(isolate_idx(i)).tracking.y(1:new_size),0,dt,conv);
%     end
% end

for i = 1:length(isolate_idx)
%     plot(result(isolate_idx(i)).tracking.time(1:new_size),result(isolate_idx(i)).tracking.MSD(1:new_size))
    plot(result(isolate_idx(i)).tracking.time(),result(isolate_idx(i)).tracking.MSD())

end
    

end

function replot_callback (source,eventdata)
        
thresh_length = str2double(get(h_thresh_length,'String'));

delete(subplot(2,2,1))
subplot(2,2,1)
hold all

dat=get(hresults_button,'Data');


for i = 1:num_tracks
    if length(result(i).tracking.x) >= thresh_length
        plot(result(i).tracking.time,result(i).tracking.MSD)
        dat(i,3) = {true};
        dat(i,4) = {true};
    else
        dat(i,3) = {false};
        dat(i,4) = {false};
    end
end

set(hresults_button,'Data',dat)
        
        
end

function load_mat_callback (source,eventdata)

[filename,path] = uigetfile('multiselect','off','.mat');

cd(path);

result = struct();

result = importdata(filename);

num_tracks = size(result,1);
if num_tracks == 1
   num_tracks = size(result,2);
end

% exist_z = exist('result(1).tracking.z')

delete(subplot(2,2,1))
subplot(2,2,1)
hold all
for i = 1:num_tracks
    plot(result(i).tracking.time,result(i).tracking.MSD)
end

dat = cell(num_tracks,4);

for i = 1:num_tracks
    dat(i,1) =  {i};
    dat(i,2) =  {length(result(i).tracking.x)};
    dat(i,3) =  {true};
    dat(i,4) =  {false};

end


set(hresults_button,'visible','on')
set(hresults_button,'Data',dat)
        
set(h_load_images,'visible','on')   
set(h_thresh_length,'visible','on')
set(h_thresh_length_text,'visible','on')
set(h_replot_button,'visible','on')
set(h_isolate_button,'visible','on')
set(h_clear_isolate_button,'visible','on')
set(h_extract_isolate_curve,'visible','on')
set(h_sliding_step,'visible','on')
set(h_sliding_MSD,'visible','on')
set(h_sliding_size,'visible','on')
set(h_save_figure,'visible','on')
set(h_dt_text,'visible','on')
set(h_dt_value,'visible','on')
set(h_diff_text,'visible','on')
set(h_diff_value,'visible','on')
set(h_conv_text,'visible','on')
set(h_conv_value,'visible','on')
set(h_extract,'visible','on')
set(h_3D_value,'visible','on')
set(h_3D_value,'value',exist_z+1)

dt = str2double(get(h_dt_value,'String'));
conv = str2double(get(h_conv_value,'String'));


end

function pre_load_image_callback (source,eventdata)
    
[filename_im,path_im] = uigetfile('multiselect','off','.tif');
cd(path_im)
size_tif = size(imfinfo(filename_im),1);  

fig_load_image = figure('position',[500 500 500 500]);
uicontrol('style','text','position',[150 250 50 25],...
    'String','From frame ...');
h_frame_start = uicontrol('Style','Edit','Position',[200 250 25 25],...
    'String','1');
uicontrol('style','text','position',[230 250 50 25],...
    'String','to frame ...');
h_frame_end = uicontrol('Style','Edit','Position',[280 250 25 25],...
    'String','');
set(h_frame_end,'String',num2str(size_tif));

uicontrol('Style','Pushbutton','String','Go!','Position',[310 250 25 25],...
    'Callback',{@load_image_callback});


end

function load_image_callback (source,eventdata)

frame_in = floor(str2double(get(h_frame_start,'String')));
frame_end = floor(str2double(get(h_frame_end,'String')));

close(fig_load_image)
        
% [filename,path] = uigetfile('multiselect','off','.tif');
% 
% cd(path)
% size_tif = size(imfinfo(filename),1);
size_tif = frame_end-frame_in;

I_1 = imread(filename_im,'index',1);
m = size(I_1,1);
n = size(I_1,2);

I = zeros(m,n,size_tif);

for i = frame_in:frame_end
    I(:,:,i) = imread(filename_im,'index',i);
end

h_slider_image = uicontrol('Style','slider','Position',[745 10 470 30],'visible','off',...
    'min',1,'callback',{@slider_image_callback},'value',1);
set(h_slider_image,'visible','on');
set(h_slider_image,'max',size_tif);



subplot(1,2,2)

imagesc(I(:,:,1))
axis equal
colormap gray

hold all

frame_num = floor(get(h_slider_image,'value'));
for i = 1:num_tracks
    n = find(result(i).tracking.frame == frame_num);
    if isempty(n) == 0
        plot(result(i).tracking.x(n),result(i).tracking.y(n),'o')
        text(result(i).tracking.x(n),result(i).tracking.y(n),num2str(i),'color','w')
    end
end

set(h_zoom_trace,'visible','on')
set(h_zoom_trace_box,'visible','on')
set(h_zoom_trace_size,'visible','on')  

        
end

function slider_image_callback (source,eventdata)

frame = floor(get(h_slider_image,'value'));

delete(subplot(1,2,2))

subplot(1,2,2)
if get(h_zoom_trace_box,'Value') == 0
    imagesc(I(:,:,frame))
elseif get(h_zoom_trace_box,'Value') == 1
    imagesc(I_zoom(:,:,frame))
end
axis equal
colormap gray

hold all

dat=get(hresults_button,'Data');
visible_idx = find([dat{:,3}] == true);

frame_num = floor(get(h_slider_image,'value'));
for i = 1:length(visible_idx)
    n = find(result(visible_idx(i)).tracking.frame == frame_num);
    if isempty(n) == 0 && isempty(isolate_idx) == 1
        plot(result(visible_idx(i)).tracking.x(1:n),result(visible_idx(i)).tracking.y(1:n),'-')
        text(result(visible_idx(i)).tracking.x(n),result(visible_idx(i)).tracking.y(n),num2str(visible_idx(i)),'color','w')
    end
end
    

if isempty(isolate_idx) == 0
    for i = 1:length(isolate_idx)
        n = find(result(isolate_idx(i)).tracking.frame == frame_num);
        if isempty(n) == 0
            if get(h_zoom_trace_box,'Value') == 1
                plot(result(isolate_idx(i)).tracking.x(1:n)+mean_x+size_zoom/2,...
                    result(isolate_idx(i)).tracking.y(1:n)+mean_y+size_zoom/2,'-')
            else
                plot(result(isolate_idx(i)).tracking.x(1:n),result(isolate_idx(i)).tracking.y(1:n),'-')
                text(result(isolate_idx(i)).tracking.x(n),result(isolate_idx(i)).tracking.y(n),num2str(isolate_idx(i)),'color','w')
            end
        end
    end
end
% delete(subplot(2,2,1))
% subplot(2,2,1)
% hold all
% 
% for i = 1:length(visible_idx)
%     plot(result(visible_idx(i)).tracking.time,result(visible_idx(i)).tracking.MSD)
%     plot([result(visible_idx(i)).tracking.time(frame_num) result(visible_idx(i)).tracking.time(frame_num)],[0 10],'k')
% end
    
end














end