function [result output] = cascade(classifiers,img,thresh)
    result = 0;
    classNum = size(classifiers,1);
    weightSum = sum(classifiers(:,12));
    % iterate through each classifier
    for i = 1:classNum
        classifier = classifiers(i,:);
        haar = classifier(1);
        pixelX = classifier(2);
        pixelY = classifier(3);
        haarX = classifier(4);
        haarY = classifier(5);
        
        % Compare the Haar value of the specific feature to our classifier
        haarVal = calcHaarVal(img,haar,pixelX,pixelY,haarX,haarY);
        if haarVal >= classifier(9) && haarVal <= classifier(10)
            % increase score by the weight of the corresponding classifier
            score = classifier(12);
        else
            score = 0;
        end
       result = result + score;
    end
    % compare resulting weighted success rate to the threshold
    if result >= weightSum*thresh
        output = 1; % true
    else
        output = 0; % false
    end
end