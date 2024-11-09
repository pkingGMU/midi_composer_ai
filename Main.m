% Add path 

addpath(genpath('miditoolbox'))

%% Convert Midi to data
directory = uigetdir();

[nm, name] = dir2coll(directory);

%% Get length of all data
length_of_files = sum(cellfun(@(x) size(x,1), nm));

%% Initialize an empty array to hold the combined data
combined_data = cell(length_of_files, 9);
%% Combine data

% Keep track where to add new data
current_idx = 1;

%%
for i = 1:length(nm)
    % Extract the current MIDI file data (assumed to be nx7)
    midi_data = nm{i};  % nm{i} is an n x 7 matrix, each row is a note
    
    % Skip if midi_data is empty
    if isempty(midi_data)
        continue
    end
    
    % Extract the full file name from the 'name' array (assumed to be a string)
    file_name = name(i, :);  % Get the full file name as a string (row of characters)
    
    % First, try to extract the composer name before the first underscore
    if contains(file_name, '_')
        composer_name = regexp(file_name, '^[^_]+', 'match', 'once');
        piece_name = regexp(file_name, '(?<=_)(.*?)(?=\.mid)', 'match', 'once', 'ignorecase');
    elseif contains(file_name, ',')
        % If no underscore, try to extract based on a comma
        composer_name = regexp(file_name, '^[^,]+', 'match', 'once');
        piece_name = regexp(file_name, '(?<=,)(.*?)(?=\.mid)', 'match', 'once', 'ignorecase');
    else
        % If neither underscore nor comma, set composer_name and piece_name to empty
        composer_name = '';
        piece_name = '';
    end
    
    % If there's no piece name found (e.g., no underscore or comma), set piece_name to empty
    if isempty(piece_name)
        piece_name = '';
    end
    
    % Repeat the composer name for all rows in the current MIDI data
    composer_name_column = repmat({composer_name}, size(midi_data, 1), 1);  % Repeat for all notes
    
    % Repeat the piece name for all rows in the current MIDI data
    piece_name_column = repmat({piece_name}, size(midi_data, 1), 1);  % Repeat for all notes
    
    % Insert the current MIDI data, composer, and piece columns into the preallocated combined_data
    combined_data(current_idx:current_idx + size(midi_data, 1) - 1, :) = ...
        [num2cell(midi_data), composer_name_column, piece_name_column];
    
    % Update current_idx for the next set of rows
    current_idx = current_idx + size(midi_data, 1);
end
%%


% Loop through each cell in the nm array (i.e., for each MIDI file)
% for i = 1:length(nm)
%     % Extract the current MIDI file data (assumed to be nx7)
%     midi_data = nm{i};  % nm{i} is a n x 7 matrix, each row is a note
% 
%     if isempty(midi_data)
%         continue
%     end
% 
%     % Extract the full file name from the 'name' array (assumed to be a string)
%     file_name = name(i, :);  % Get the full file name as a string (row of characters)
% 
%     % First, try to extract the composer name before the first underscore
%     if contains(file_name, '_')
%         composer_name = regexp(file_name, '^[^_]+', 'match', 'once');
%         piece_name = regexp(file_name, '(?<=_)(.*?)(?=\.mid)', 'match', 'once', 'ignorecase');
%     elseif contains(file_name, ',')
%         % If no underscore, try to extract based on a comma
%         composer_name = regexp(file_name, '^[^,]+', 'match', 'once');
%         piece_name = regexp(file_name, '(?<=,)(.*?)(?=\.mid)', 'match', 'once', 'ignorecase');
%     else
%         % If neither underscore nor comma, set composer_name and piece_name to empty
%         composer_name = '';
%         piece_name = '';
%     end
% 
%     % If there's no piece name found (e.g., no underscore or comma), set piece_name to empty
%     if isempty(piece_name)
%         piece_name = '';
%     end
% 
%     % Repeat the composer name for all rows in the current MIDI data
%     composer_name_column = cellstr(repmat(composer_name, size(midi_data, 1), 1));  % Repeat for all notes
% 
%     % Repeat the piece name for all rows in the current MIDI data
%     piece_name_column = cellstr(repmat(piece_name, size(midi_data, 1), 1));  % Repeat for all notes
% 
%     % Ensure the data is in the correct shape for concatenation
%     midi_data_with_composer_and_piece = [num2cell(midi_data), composer_name_column, piece_name_column];  % Add 'Composer' and 'Piece' columns
% 
%     % Append this data to the combined dataset
%     combined_data = [combined_data; midi_data_with_composer_and_piece];
% end

%% Write to csv

combined_data_table = cell2table(combined_data, 'VariableNames', {'Onset_Beats','Duration_Beats','Midi_Channel','Midi_Pitch','Velocity','Onset_Sec','Duration_Sec','Composer','Piece'});
writetable(combined_data_table, 'midi_training.csv');


