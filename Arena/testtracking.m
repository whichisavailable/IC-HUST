load('./maps/c1map.mat')

se = strel('square',5);
branchmap = imclose(branchmap,se);
imshow(branchmap)