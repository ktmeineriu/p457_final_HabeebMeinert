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
imagesc(Ci);
%%
%plot the graph
g = graph(a, 'upper');

f = figure;
plot(g);
plot(g, 'NodeLabel',node_names , 'NodeColor',Ci, 'LineWidth',(g.Edges.Weight)/5, 'MarkerSize',(degrees_und(a) + 1)/5, 'NodeCData',cicon)



%%
%Going to try generating rich club

% binarize network
CIJ = +(a ~= 0);

% target degree
k = 100;

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
%Give the p-value from the rich-club club formula and the fact that we get
%just a repeat of each number for community analysis. It is quiet possible
%that there are no rich clubs. However, we can still evaluate high degree
%nodes.

%%

z = a(idx > 0);

bins =  1:max(a);

hist(z,bins), xlabel("degree"), ylabel("number of nodes"), title("Rich Club connections");

%%
% Your existing code to create the graph
g = graph(a, 'upper');

% Specify the index (node numbers) you want to highlight
highlight_nodes = idx;

% Create a figure and plot the graph, highlighting specific nodes
f = figure;
p = plot(g, 'NodeLabel', node_names, 'LineWidth', (g.Edges.Weight)/5, 'MarkerSize', (degrees_und(a))/10);
highlight(p, highlight_nodes, 'NodeColor', 'r', 'MarkerSize', 10);

