clear;clc;close all;
% folder = uigetdir();
canada_vote_path='E:\2020-8-8 sdp\2022-9-2 balanced signed graph\graphLearning_datasets\graphLearning_datasets\CANADA_house_data';
addpath(genpath(canada_vote_path));
% CANADA VOTE
folder = 'E:\2020-8-8 sdp\2022-9-2 balanced signed graph\graphLearning_datasets\graphLearning_datasets\CANADA_house_data';
% US VOTE
% folder = 'E:\2020-8-8 sdp\2022-9-2 balanced signed graph\graphLearning_datasets\graphLearning_datasets\US_senate_data';
files = dir([folder '\**\*.xml']);

total_xml = size(files,1);

canada_vote_dataset=[]; % people x vote

first_name=8;
last_name=9;
party=11;
vote_result=7;

%Conservative
%Liberal
%Bloc Québécois
%NDP
%Independent

for i=1:total_xml

    disp(['reading the ' num2str(i) 'th (' num2str(total_xml) ' in total) xml file']);
    current_xml=xml2struct(files(i).name);

    number_of_people=size(current_xml.Children,2);

    for j=1:number_of_people
        %         current_people_id=sscanf(current_xml.Children(j).Children(2*j).Children(people_id).Children.Data,'S%d');

        current_person_first_name=current_xml.Children(j).Children(first_name).Children.Data;
        current_person_last_name=current_xml.Children(j).Children(last_name).Children.Data;
        current_person_party=current_xml.Children(j).Children(party).Children.Data;

        if size(canada_vote_dataset,1)==0 % empty
            canada_vote_dataset=[canada_vote_dataset 0]; % party vote_results ...
            canada_vote_dataset(end,1)=max(canada_vote_dataset(:,1))+1;
            name_party=struct('name',[current_person_first_name current_person_last_name],'party',current_person_party); % add person into the list
            current_person_id=1; % this is the first person
        end
        
        if j==1 % need to add one more column
            canada_vote_dataset=[canada_vote_dataset zeros(size(canada_vote_dataset,1),1)];
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
        if strcmp(current_person_party,'Conservative')
            canada_vote_dataset(current_person_id,1)=1;
        else % false
            if strcmp(current_person_party,'Liberal')
                canada_vote_dataset(current_person_id,1)=-1;
            else % false false
                canada_vote_dataset(current_person_id,1)=0;
            end
        end

        current_vote=current_xml.Children(j).Children(vote_result).Children.Data;

        % write vote
        if strcmp(current_vote,'Yea')
            canada_vote_dataset(current_person_id,i+1)=1;
        else % false
            if strcmp(current_vote,'Nay')
                canada_vote_dataset(current_person_id,i+1)=-1;
            else % false false
                canada_vote_dataset(current_person_id,i+1)=0;
            end
        end

    end

end

clearvars -except canada_vote_dataset
save CanadaHouse.mat