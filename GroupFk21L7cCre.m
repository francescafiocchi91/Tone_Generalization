function Group =  GroupFk21L7cCre
%define Fk2.1L7cCre mice groups according to genotype.
%tg = transgenic = mice who express the mutant protein; wt = wild type =
%mice who do not express mutant protein.

% ----------------------------- Define Groups
% G = cellfun(@(x) x{end}, geno, 'UniformOutput', false); %strings in groups   
% unique_groups = unique(G); %define unique groups
% 
% disp(['Groups:', (unique_groups')]);

Group.het = [522; 525; 526; 528; 530; 533; 535; 537; 539; 541]; %het+ 
Group.wt = [523; 524; 527; 529; 531; 532; 534; 536; 538; 540; 559; 560; 561; 562; 563; 564]; %het-

end

