
load fold6_faces.mat
load fold6_nonfaces.mat
load selected.mat
faceScores = [];
for i = 1:size(faces,2)
    [score, ~] = cascade(selectedClassifiers, faces{i}, 0.5);
    faceScores = [faceScores;score];
    
end

nonfaceScores = [];

for i = 1:size(nonFaces,2)
    [score, ~] = cascade(selectedClassifiers, nonFaces{i}, 0.5);
    nonfaceScores = [nonfaceScores;score];
end

% accuracy = (sum(faceScores>0)+sum(nonfaceScores==0))/(1035*2);

scores = [faceScores; nonfaceScores];

target = [ones(518,1); zeros(518,1)];

prec_rec(scores,target)


%{

load faceScores.mat
load nonfaceScores.mat
maxi = 0;
for i = 200:1000
    score = sum(faceScores>=i)+sum(nonfaceScores<i)

    if(score>maxi)
        maxi = score;
        accuracy = score/(2070);
        i
    end
end    

%}