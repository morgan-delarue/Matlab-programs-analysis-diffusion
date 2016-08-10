function analize_tracking

% close all
% clear all
% clc

global extracted
global Rc_track
global D_track_c
global D_track_out
global duration_track_c
global duration_track_out

fig = figure('position',[20 20 1330 650]); % test

uicontrol('Style','Pushbutton','String','Load result','Position',...
    [30 100 100 25],'Callback',{@load_mat_callback});
h_thresh_text = uicontrol('Style','Text','String','Threshold','Position',[30 70 50 25],...
    'visible','off');
h_thresh_value = uicontrol('Style','Edit','String','1.2','Position',[60 70 50 25],...
    'visible','off');
h_extract = uicontrol('Style','Pushbutton','String','Extract','Position',[60 40 50 25],...
    'visible','off','callback',{@extract_callback});
h_slider_track = uicontrol('Style','slider','Position',[30 10 100 30],'visible','off',...
    'min',1,'callback',{@slider_track_callback},'value',1);


function load_mat_callback(source,eventdata)

[filename,path] = uigetfile('multiselect','on','.mat');

cd(path)

num_results = zeros(1,length(filename));
for i = 1:length(filename)
    num_results(i) = size(importdata(filename{i}),1);
end

S = [];
for i = 1:sum(num_results)
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

extracted = cell2struct(field','res',1);

for i = 1:length(filename)
    for j = 1:num_results(i)
        extract = importdata(filename{i});
        if i > 1
            extracted(j+sum(num_results(1:i-1))).res = struct('time',extract(j).result.time,...
                'D',extract(j).result.D,'Rc',extract(j).result.Rc);
%             extracted(j+sum(num_results(1:i-1))).res = struct('time',extract(j).result.time,...
%                 'D',extract(j).result.D*2./(5*extract(j).result.Rc),'Rc',extract(j).result.Rc);
        elseif i == 1
            extracted(j).res = struct('time',extract(j).result.time,...
                'D',extract(j).result.D,'Rc',extract(j).result.Rc);
            extracted(j).res = struct('time',extract(j).result.time,...
                'D',extract(j).result.D*2./(5*extract(j).result.Rc),'Rc',extract(j).result.Rc);
        end
    end
end

subplot(2,3,1)
plot(extracted(1).res.time,extracted(1).res.D)

subplot(2,3,2)
plot(extracted(1).res.time,extracted(1).res.Rc)

subplot(2,3,3)
plot(extracted(1).res.Rc,extracted(1).res.D,'bo')

set(h_slider_track,'visible','on')
set(h_slider_track,'max',size(extracted,1))
set(h_thresh_value,'visible','on')
set(h_thresh_text,'visible','on')
set(h_extract,'visible','on')

end

function slider_track_callback(source,eventdata)
    
value = floor(get(h_slider_track,'Value'));

% subplot(2,3,1)
% plot(extracted(value).res.time,extracted(value).res.D)
% 
% subplot(2,3,2)
% plot(extracted(value).res.time,extracted(value).res.Rc)

subplot(2,3,1)
plot(extracted(value).res.Rc,extracted(value).res.D,'bo')    
    
        
end

function extract_callback (source,eventdata)

thresh = str2double(get(h_thresh_value,'String'));
dt = 0.1;

num_domain_track = zeros(1,size(extracted,1));
Rc_track = 0;
D_track_c = 0;
D_track_out = 0;
duration_track_c = 0;
duration_track_out = 0;

for i = 1:size(extracted,1)
   idx_thresh = find(extracted(i).res.Rc < thresh);
   idx_domain = find(diff(idx_thresh) > 3);
   if numel(idx_domain) > 1
       num_domain_track(i) = length(idx_domain)+1;
   end
end


Rc_track = zeros(1,sum(num_domain_track));
D_track_c = zeros(1,sum(num_domain_track));
D_track_out = zeros(1,size(extracted,1));
duration_track_c = zeros(1,sum(num_domain_track));
% duration_track_out = zeros(1,sum(num_domain_track));

for i = 1:size(extracted,1)
    idx_thresh = find(extracted(i).res.Rc < thresh);
    idx_domain = find(diff(idx_thresh) > 3);
    idx_thresh_out = find(extracted(i).res.Rc > thresh);
    D_track_out(i) = median(extracted(i).res.D(idx_thresh_out));
    
    if numel(idx_domain) > 1
        
    for j = 1:num_domain_track(i)
        if i > 1 && j > 1
            if length(idx_domain) > j
                Rc_track(sum(num_domain_track(1:i-1)) + j) = mean(extracted(i).res.Rc(idx_thresh(idx_domain(j-1)+1):idx_thresh(idx_domain(j))));
                duration_track_c(sum(num_domain_track(1:i-1)) + j) = dt*length(idx_thresh(idx_domain(j-1)+1):idx_thresh(idx_domain(j)));
                D_track_c(sum(num_domain_track(1:i-1)) + j) = mean(extracted(i).res.D(idx_thresh(idx_domain(j-1)+1):idx_thresh(idx_domain(j))));
            elseif length(idx_domain) < j
                Rc_track(sum(num_domain_track(1:i-1)) + j) = mean(extracted(i).res.Rc(idx_thresh(idx_domain(j-1)+1):max(idx_thresh)));
                duration_track_c(sum(num_domain_track(1:i-1)) + j) = dt*length(idx_thresh(idx_domain(j-1)+1):max(idx_thresh));
                D_track_c(sum(num_domain_track(1:i-1)) + j) = mean(extracted(i).res.D(idx_thresh(idx_domain(j-1)+1):max(idx_thresh)));
            end
        elseif i > 1 && j == 1
            Rc_track(sum(num_domain_track(1:i-1)) + j) = ...
                mean(extracted(i).res.Rc(idx_thresh(1):idx_thresh(idx_domain(j))));
            duration_track_c(sum(num_domain_track(1:i-1)) + j) = dt*length(idx_thresh(1):idx_thresh(idx_domain(j)));
            D_track_c(sum(num_domain_track(1:i-1)) + j) = ...
                mean(extracted(i).res.D(idx_thresh(1):idx_thresh(idx_domain(j))));
        elseif i == 1 && j == 1
            Rc_track(j) = mean(extracted(i).res.Rc(idx_thresh(1):idx_thresh(idx_domain(j))));
            duration_track_c(j) = dt*length(idx_thresh(1):idx_thresh(idx_domain(j)));
            D_track_c(j) = mean(extracted(i).res.D(idx_thresh(1):idx_thresh(idx_domain(j))));
        elseif i == 1 && j > 1
            if length(idx_domain) > j
                Rc_track(j) = mean(extracted(i).res.Rc(idx_thresh(idx_domain(j-1)+1):idx_thresh(idx_domain(j))));
                duration_track_c(j) = dt*length(idx_domain(j-1)+1:idx_thresh(idx_domain(j)));
                D_track_c(j) = mean(extracted(i).res.D(idx_thresh(idx_domain(j-1)+1):idx_thresh(idx_domain(j))));
            elseif length(idx_domain) < j
                Rc_track(j) = mean(extracted(i).res.Rc(idx_thresh(idx_domain(j-1)+1):max(idx_thresh)));
                duration_track_c(j) = dt*length(idx_thresh(idx_domain(j-1)+1):max(idx_thresh));
                D_track_c(j) = mean(extracted(i).res.D(idx_thresh(idx_domain(j-1)+1):max(idx_thresh)));
            end
        end
    end
    
    end
    
end

subplot(2,3,2)
hist(Rc_track(find(duration_track_c > 0.5)),20)

subplot(2,3,5)
hist(duration_track_c(find(duration_track_c > 0.5)),20)

subplot(2,3,3)
hist(D_track_c(find(duration_track_c > 0.5)),20)

subplot(2,3,6)
hist(D_track_out(D_track_out>0),20)

% median(D_track_out(D_track_out>0))
% std(D_track_c(D_track_out>0))
% 
% median(D_track_c(find(duration_track_c > 0.5)))
% std(D_track_c(find(duration_track_c > 0.5)))
% 
% median(Rc_track(find(duration_track_c > 0.5)))
% std(Rc_track(find(duration_track_c > 0.5)))

results_final = struct('D_in',D_track_c(find(duration_track_c > 0.5)),...
       'D_out',D_track_out(D_track_out>0),...
       'R_c',Rc_track(find(duration_track_c > 0.5)),...
       'duration_c',duration_track_c(find(duration_track_c > 0.5)));
   
uisave('results_final')

    
end











end
