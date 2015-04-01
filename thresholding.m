
%###########################################
%#		Script  -  Octave
%
%	Receives a image and a limit value.
%   Apply the binary thresholding, generating
% a new image called "binary_image.png"
%###########################################


%###########################################
%#		Defining the auxiliaries functions
%###########################################

%   Receive a matrix representing the imagem and apply the
% binary thresholding, returning the resulting image.
function img_binary = thresholding(img, limit)
	L = 256;
	N = size(img)(1);
	M = size(img)(2);
	img_binary = zeros(N, M);

	for i=1:N
		for j=1:M
			intensity = uint8(img(i,j));
			if intensity < limit
				img_binary(i,j) = 0;
			else
				img_binary(i,j) = L - 1;
			end
		end
	end
endfunction

file = input('Type the path of the image: ', 's');
img = imread(file);  % read the image

limit = input('Type the limit value for the thresholding (among 0 and 255): ');

img_binary = thresholding(img, limit);

imwrite (img_binary, "binary_image.png", "png"); % save the binary image
