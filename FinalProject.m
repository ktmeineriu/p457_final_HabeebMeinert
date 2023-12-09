%Load the network
total_network = load("eac_network.mat");

%This accounts for mismatch in network a. 
good_nodes = total_network.good_nodes;
node_names = total_network.node_names;
a = total_network.a;

a = a(good_nodes > 0,good_nodes > 0);
node_names = node_names(good_nodes > 0);

%Our network is a directed network

%Loading this network gives us three variables
% a = the total network
% good_nodes = this is 8200+ rows with '1' in the first column
% node_names = this is a 8200+ columns with different words in each column
%              for the first row

%%
% we're going to try seeing how many connections are made

% calculate incoming/outgoing/total degree for each node in a directed network
[degree_in,degree_out,degree_tot] = degrees_dir(a);

%we get some obvious degrees of connections from the above function.
%Especially focusing on degree_tot

%%
%Distance and efficiency

% calculate distance matrix
D = distance_bin(total_network.a);

% calculate binary path length and efficiency
[lambda,efficiency] = charpath(D); %Having some issues running this

%%

% run modularity maximization for a network where all edge weights are positive
[Ci,Q] = community_louvain(total_network.a);

%%

% number of times to repeat community detection algorithm
num_iter = 5; %reduced to 10 but still said out of memory

% number of nodes
n_nodes = length(a);

% empty array for storing the community labels
Ci = zeros(n_nodes,num_iter);

% run the community detection algorithm num_iter times
for iter = 1:num_iter
  Ci(:,iter) = community_louvain(a);
end
%%

% calculate the module coassignment matrix -- for every pair of nodes
% how many times were they assigned to the same community
Coassignment = agreement(Ci)/num_iter;

% node we use the consensus clustering function
thr = 0.5;
cicon = consensus_und(Coassignment,thr,num_iter);

%%
%Finding degree

degrees = degrees_und(a);
%%
f = figure;
imagesc(Coassignment);
%%
%plot the graph
g = digraph(a);

f = figure;
plot(g);
plot(g, 'NodeLabel',node_names , 'NodeColor',Ci, 'LineWidth',(g.Edges.Weight)/5, 'MarkerSize',3, 'NodeCData',cicon, 'Arrowsize', 3)



%%
%Going to try generating rich club

% binarize network
CIJ = +(a ~= 0);

% target degree
k = 275;

% calculate nodes' degrees
degrees = degrees_und(CIJ);

% get sub-network
idx = degrees > k;
CIJsub = CIJ(idx,idx);

% get density
phi = density_und(CIJsub);

% generate randomized networks
nrand = 10; % number of randomized networks
nswaps = 32; % number of times each edge is "rewired" on average
for irand = 1:nrand
  CIJrand = randmio_und(CIJ,nswaps);
  CIJrandsub = CIJrand(idx,idx);
  phirand(irand) = density_und(CIJrandsub);
end

% calculate p-value
p = mean(phirand >= phi);

% calculate normalized coefficient
phinorm = mean(phi./phirand);

%%


% Find the indices where idx is equal to 1
indices = find(idx == 1);

% Use the indices to extract the corresponding names from good_names
selected_names = node_names(indices);

% Display the result
%disp(selected_names);


%%
% Example data: replace this with your actual data
%selected_names = {'name1', 'name2', 'name3', ...}; % 1x88 cell array of strings

% Specify the file name
fileName = 'rich_club_words.txt';

% Open the file for writing
fileID = fopen(fileName, 'w');

% Check if the file was opened successfully
if fileID == -1
    error('Error opening file for writing');
end

% Loop through the strings and write them to the file
for i = 1:numel(selected_names)
    fprintf(fileID, '%s\n', selected_names{i});
end

% Close the file
fclose(fileID);

disp(['Strings have been written to ' fileName]);



%%
% Create a directed graph object

% Create a directed graph object
g = digraph(a);

highlight_nodes = indices;

% Plot the directed graph
figure;
p = plot(g, 'LineWidth', (g.Edges.Weight)/5, 'MarkerSize', 6, 'Arrowsize',10);
title('Not so rich-club of EWAN');
highlight(p, highlight_nodes, 'NodeColor', 'r', 'Marker', 'pentagram', 'MarkerSize', 6);

% Add labels to highlighted nodes
if ~isempty(highlight_nodes) && max(highlight_nodes) == numel(selected_names)
    text(p.XData(highlight_nodes), p.YData(highlight_nodes), selected_names(highlight_nodes), 'Color', 'k', 'FontSize', 8, 'FontWeight', 'bold');
else
    disp('Error: Highlight nodes are out of bounds or selected_names is not long enough.');
end


%%
%I have no idea why error occurs for above
result = (length(highlight_nodes) == length(selected_names));


