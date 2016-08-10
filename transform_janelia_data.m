function transform_janelia_data

clc
[filename,path] = uigetfile('multiselect','on','.mat');
% path_save = uigetdir;

conv = 1;
n = length(filename);

for i = 1:n

cd(path)
tracks = importdata(filename{i});

num_track = size(tracks,1);

S = [];
for k = 1:length(num_track)
    if k < 10
        S = [S;strcat('part0000',num2str(k))];
    elseif k >= 10 && k < 100
        S = [S;strcat('part000',num2str(k))];
    elseif k >= 100 && k < 999
        S = [S;strcat('part00',num2str(k))];
    elseif k >=1000 && k < 9999
        S = [S;strcat('part0',num2str(k))];
    elseif k >= 10000 && k < 99999
        S = [S;strcat('part',num2str(k))];
    end
end

field = cellstr(S);

result = cell2struct(field,'tracking',1);
    
for j = 1:num_track
   track_length = length(tracks{j}(:,1));
   
   MSD = zeros(1,length(track_length));
   time = zeros(1,length(track_length));
   x_res = zeros(1,length(track_length));
   y_res = zeros(1,length(track_length));
   z_res = zeros(1,length(track_length));
   frame_res = zeros(1,length(track_length));
   
   x_res = tracks{j}(:,1);
   y_res = tracks{j}(:,2);
   z_res = tracks{j}(:,3);
   time = tracks{j}(:,4);
   
   dt = mean(diff(time));
   
   MSD = calculate_MSD(x_res,y_res,z_res,dt,conv);
   
   result(j).tracking = struct('time',time-time(1),...
        'x',x_res,...
        'y',y_res,...
        'z',z_res,...
        'MSD',MSD',...
        'frame',frame_res);
end

% cd(path_save)
saving_name = strcat('trans_',filename{i});

save(saving_name,'result')
    
    
end

end