clear;clc;close all;
% folder = uigetdir();
us_vote_path='E:\2020-8-8 sdp\2022-9-2 balanced signed graph\graphLearning_datasets\graphLearning_datasets\US_senate_data';
addpath(genpath(us_vote_path));
% CANADA VOTE
% folder = 'E:\2020-8-8 sdp\2022-9-2 balanced signed graph\graphLearning_datasets\graphLearning_datasets\CANADA_house_data';
% US VOTE
folder = 'E:\2020-8-8 sdp\2022-9-2 balanced signed graph\graphLearning_datasets\graphLearning_datasets\US_senate_data';
files = dir([folder '\**\*.xml']);

total_xml = size(files,1);

us_vote_dataset=[]; % people x vote

first_name=4;
last_name=6;
party=8;
vote_result=12;
people_id=14;

for i=1:total_xml

    disp(['reading the ' num2str(i) 'th (' num2str(total_xml) ' in total) xml file']);
    current_xml=xml2struct(files(i).name);

    list_queue=size(current_xml.Children,2);
    number_of_people=(size(current_xml.Children(list_queue-1).Children,2)-1)/2;

    for j=1:number_of_people
        %         current_people_id=sscanf(current_xml.Children(list_queue-1).Children(2*j).Children(people_id).Children.Data,'S%d');

        current_person_first_name=current_xml.Children(list_queue-1).Children(2*j).Children(first_name).Children.Data;
        current_person_last_name=current_xml.Children(list_queue-1).Children(2*j).Children(last_name).Children.Data;
        current_person_party=current_xml.Children(list_queue-1).Children(2*j).Children(party).Children.Data;

        if size(us_vote_dataset,1)==0 % empty
            us_vote_dataset=[us_vote_dataset 0]; % party vote_results ...
            us_vote_dataset(end,1)=max(us_vote_dataset(:,1))+1;
            name_party=struct('name',[current_person_first_name current_person_last_name],'party',current_person_party); % add person into the list
            current_person_id=1; % this is the first person
        end
        
        if j==1 % need to add one more column
            us_vote_dataset=[us_vote_dataset zeros(size(us_vote_dataset,1),1)];
        end 

        % check if the person has already been added into the list
        check_person=contains({name_party.name},[current_person_first_name current_person_last_name]); 

        if sum(check_person)>0 % no need to add one more row
            current_person_id=find(check_person);
        else % need to add one more row
            name_party(end+1)=struct('name',[current_person_first_name current_person_last_name],'party',current_person_party);
            current_person_id=size(name_party,2);
        end

        % write party
        if strcmp(current_person_party,'D')
            us_vote_dataset(current_person_id,1)=1;
        else % false
            if strcmp(current_person_party,'R')
                us_vote_dataset(current_person_id,1)=-1;
            else % false false
                us_vote_dataset(current_person_id,1)=0;
            end
        end

               current_vote=current_xml.Children(list_queue-1).Children(2*j).Children(vote_result).Children.Data;

        % write vote
        if strcmp(current_vote,'Yea')
            us_vote_dataset(current_person_id,i+1)=1;
        else % false
            if strcmp(current_vote,'Nay')
                us_vote_dataset(current_person_id,i+1)=-1;
            else % false false
                us_vote_dataset(current_person_id,i+1)=0;
            end
        end

    end

end

% clearvars -except us_vote_dataset
% save USsenate.mat