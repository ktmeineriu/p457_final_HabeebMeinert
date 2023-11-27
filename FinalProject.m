%Load the network
total_network = load("eac_network.mat");

%Our network is a directed network

%Loading this network gives us three variables
% a = the total network
% good_nodes = this is 8200+ rows with '1' in the first column
% node_names = this is a 8200+ columns with different words in each column
%              for the first row

%%
% we're going to try seeing how many connections are made

% calculate incoming/outgoing/total degree for each node in a directed network
[degree_in,degree_out,degree_tot] = degrees_dir(total_network.a);

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
num_iter = 1; %reduced to 10 but still said out of memory

% number of nodes
n_nodes = length(total_network.a);

% empty array for storing the community labels
Ci = zeros(n_nodes,num_iter);

% run the community detection algorithm num_iter times
for iter = 1:num_iter
  Ci(:,iter) = community_louvain(total_network.a);
end
%%

% calculate the module coassignment matrix -- for every pair of nodes
% how many times were they assigned to the same community
Coassignment = agreement(Ci)/num_iter;

% node we use the consensus clustering function
thr = 0.5;
cicon = consensus_und(Coassignment,thr,num_iter);

%%
%Get the following errors from the above section if iterator is 10 or 50:

% Out of memory.
% 
% Error in dummyvar (line 6)
%         I = [I,double(ci(:,i) == j)];
% 
% Error in agreement (line 36)
%     ind = dummyvar(ci);
% 
% Error in FinalProject (line 50)
% Coassignment = agreement(Ci)/num_iter;
% 
% Related documentation
%%
%However if only do 1 as num_iter it works however cicon is just the
%numbers as is. It does not provide information about the network. Need to
%be able to tease out more information or specify for a directed network.