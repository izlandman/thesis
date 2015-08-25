function output = readHueText(filename,varargin)
% allow a cell of file names to be used
switch iscell(filename)
    
    case 0
        
        if( nargin == 1 )
            output = csvread(filename);
        elseif( nargin == 2 )
            columns = varargin{1};
            output = csvread(filename);
            output = output(:,columns);
        else
            disp('Input error.');
        end
        
    case 1
        % given a cell of strings, process each string
        iterations = length(filename);
        output = cell(3,1);
        
        if( nargin == 1)
            
            for i=1:iterations
                output{i} = csvread(filename{i});
            end
            
        elseif( nargin == 2)
            columns = varargin{1};
            [row_c, ~] = size(columns);
            if( row_c == 1)
                for i=1:iterations
                    temp_output = csvread(filename{i});
                    output{i} = temp_output(:,columns);
                end
            else
                for i=1:iterations
                    temp_output = csvread(filename{i});
                    output{i} = temp_output(:,columns(i,:));
                end
            end
        end
        
    otherwise
        
end

end