classdef WayPoint
    properties
        % numeric flag to know what type of features are stored
        FeatureType
        % hold the features assocaited with the corresponding feature type
        FeatureSet
        % remember the assigned group
        GroupID
        % hold the list of possible next two group IDs
        TailSequence
        % remember the order of the samples, time
        SampleID
        % track the annotations associated with the TrailSequence
        AnnotationSequence
    end
    methods
        
    end
end