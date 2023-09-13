function score = detectFaces(img)
    % preprocessing by Gaussian filtering
    img = im2gray(img);
    img = conv2(img,fspecial('gaussian',3,3),'same');
    
    % get image parameters
    [m,n] = size(img);
    
    % scan iteration depending on the average picture size
    % More specifically the usual ratio between face and the actual images
    scanItr = 6; 
    score = 0;
    % compute integral image
    intImg = integralImg(img);
    
    % load finalClassifiers
    load 'selected.mat'
    
    % Cascade structure 
    class1 = selectedClassifiers(1:5,:);
    class2 = selectedClassifiers(6:15,:);
    class3 = selectedClassifiers(16:20,:);
    class4 = selectedClassifiers(21:50,:);
    class5 = selectedClassifiers(51:80,:);
    class6 = selectedClassifiers(81:150,:);
    class7 = selectedClassifiers(151:200,:);
    class8 = selectedClassifiers(201:285,:);
    
    % iterate through each window size through each pyramid level
    for itr = 1:scanItr
        for i = 1:2:m-19
            if i + 19 > m 
                break; % boundary check
            end
            for j = 1:2:n-19
                if j + 19 > n
                    break; % boundary case
                end
                window = intImg(i:i+18,j:j+18);
                check1 = cascade(class1,window,1);
                if check1 == 1
                    check2 = cascade(class2,window,.5);
                    if check2 == 1
                        check3 = cascade(class3,window,.5);
                        if check3 == 1
                            check4 = cascade(class4,window,.5);
                            if check4 == 1
                                check5 = cascade(class5,window,.6);
                                if check5 == 1
                                    check6 = cascade(class6,window,.6); 
                                    if check6 == 1
                                        check7 = cascade(class7,window,.5);
                                        if check7 == 1
                                            check8 = cascade(class8, window, 0.5);
                                            if check8==1
                                                % Number of windows that
                                                % make it to the cut
                                                score = score+1;

                                                % 0 means no face detected
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        % create the next image pyramid level
        tempImg = imresize(img,.8);
        img = tempImg;
        [m,n] = size(img);
        intImg = integralImg(img);
    end
end

