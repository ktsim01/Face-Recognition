clc;
clear all;

load faces_resized.mat
load nonfaces_resized.mat

faceIntegrals = cell(1,4136);
nonfaceIntegrals = {};

for faceNum = 1:4136
    integral = integralImg(faces{faceNum});
    faceIntegrals{faceNum} = integral;
end

allIntegrals = faceIntegrals;

% nonface images
count = 1;
for nonFaceNum = 1:4129
    integral = integralImg(nonFaces{nonFaceNum});
    nonfaceIntegrals{nonFaceNum} = integral;
    allIntegrals{nonFaceNum+4136} = integral;
end

% initialize image weights
imgWeights = ones(4136+size(nonfaceIntegrals,2),1)./(4136+size(nonfaceIntegrals,2));

% haar feature dimensions
haars = [1,2;2,1;1,3;3,1;2,2];

% size of training images, I have resized the training pictures to 19 by
% 19
window = 19;
weakClassifiers = {};
for iterations = 1:2    
    % iterate through each feature
    for haar = 1:5
        fprintf(printout);
        % x dimension
        dimX = haars(haar,1);
        % y dimension
        dimY = haars(haar,2);
        % iterate through available pixel within the window
        for pixelX = 2:window-dimX
            for pixelY = 2:window-dimY
                % iterate through possible haar dimensions
                for haarX = dimX:dimX:window-pixelX
                    for haarY = dimY:dimY:window-pixelY
                        haarVector1 = [];
                        for img = 1:4136
                            val = calcHaarVal(faceIntegrals{img},haar,pixelX,pixelY,haarX,haarY);
                            % store feature value for faces
                            haarVector1 = [haarVector1,val];
                        end
                        % distribution values for haar feature in faces
                        faceMean = mean(haarVector1);
                        faceStd = std(haarVector1);
                        faceMax = max(haarVector1);
                        faceMin = min(haarVector1);

                        haarVector2 = [];
                        for img = 1:size(nonfaceIntegrals,2)
                            val = calcHaarVal(nonfaceIntegrals{img},haar,pixelX,pixelY,haarX,haarY);
                            % store feature value for nonfaces
                            haarVector2 = [haarVector2,val];
                        end
                        % examine haar feature value distribution
                        rateDiff = [];
                        faceRating = [];
                        nonFaceRating = [];
                        totalError = [];
                        lowerBound = [];
                        upperBound = [];
                        counter = 0;

                        for iter = 1:25
                            C = ones(size(imgWeights,1),1);
                            minRating = faceMean-abs((iter/50)*(faceMean-faceMin));
                            maxRating = faceMean+abs((iter/50)*(faceMax-faceMean));
                            % false negatives
                            for val = 1:size(haarVector1,2)
                                if haarVector1(val) >= minRating && haarVector1(val) <= maxRating
                                    C(val) = 0;
                                end
                            end
                            % weighted false negative capture rate
                            faceRating = sum(imgWeights(1:4136).*C(1:4136));
                            if faceRating < 0.05 % if less than 5% faces misclassified
                                % capture all false positive values
                                for val = 1:size(haarVector2,2)
                                    if haarVector2(val) >= minRating && haarVector2(val) <= maxRating
                                    else
                                        C(val+size(haarVector1,2)) = 0;
                                    end
                                end
                                % weighted false positiverate
                                nonFaceRating = sum(imgWeights(4136+1:4136+size(nonfaceIntegrals,2)).*C(4136+1:4136+size(nonfaceIntegrals,2)));
                                % total error
                                totalError = sum(imgWeights.*C);
                                if totalError < .5 
                                    % store as a weak classifier since it
                                    % had a pretty good accuracy
                                    counter = counter+1;
                                    rateDiff = [rateDiff,(1-faceRating)-nonFaceRating];
                                    faceRating = [faceRating,1-faceRating];
                                    nonFaceRating = [nonFaceRating,nonFaceRating];
                                    totalError = [totalError,totalError];
                                    lowerBound = [lowerBound,minRating];
                                    upperBound = [upperBound,maxRating];
                                end
                            end
                        end

                        % if potential features exist, find index of one with the 
                        % maximum difference between true and false positives
                        if size(rateDiff) > 0
                            maxRatingIndex = -inf; % by default
                            maxrateDiff = max(rateDiff);
                            for index = 1:size(rateDiff,2)
                                if rateDiff(index) == maxrateDiff
                                    maxRatingIndex = index; % found the index of maxrateDiff
                                    break;
                                end
                            end
                        end

                        % store classifier metadata into thisClassifier
                        if size(rateDiff) > 0
                            thisClassifier = [
                                haar,pixelX,pixelY,haarX,haarY,...
                                maxrateDiff,storeFaceRating(maxRatingIndex),storeNonFaceRating(maxRatingIndex),...
                                storeLowerBound(maxRatingIndex),storeUpperBound(maxRatingIndex),...
                                storeTotalError(maxRatingIndex)];

                            % run Adaboost
                            [imgWeights,alpha] = adaboost(thisClassifier,allIntegrals,imgWeights);
                            % append alpha to classifier metadata
                            thisClassifier = [thisClassifier,alpha];
                            % store weak classifiers
                            weakClassifiers{size(weakClassifiers,2)+1} = thisClassifier;
                        end
                    end
                end
            end
        end
    end 
end

alphas = zeros(size(weakClassifiers,1),1);
for i = 1:size(alphas,1)
    alphas(i) = weakClassifiers(i,12);
end

% sort weakClassifiers according to alpha values

tempClassifiers = zeros(size(alphas,1),2); % 2 column
% first column is simply original alphas
tempClassifiers(:,1) = alphas;
for i = 1:size(alphas,1)
   tempClassifiers(i,2) = i; 
end

tempClassifiers = sortrows(tempClassifiers,-1); % sort descending order

% Select the first 250
selectedClassifiers = zeros(250,12);
for i = 1:286
    selectedClassifiers(i,:) = weakClassifiers(tempClassifiers(i,2),:);
end

