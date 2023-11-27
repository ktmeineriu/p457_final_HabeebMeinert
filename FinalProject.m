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