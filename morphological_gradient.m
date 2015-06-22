
%###########################################
%#		Script  -  Octave
%
%###########################################


%###########################################
%#		Defining the auxiliaries functions
%###########################################


function print_flat_structuring_element(b)
	N = size(b)(1)
	if 0 == N
		printf('{ }\n')
	else
		printf '{'
		for k = 1:size(b)(1)-1
			x = b(k, 1);
			y = b(k, 2);
			printf('(%d , %d), ', x, y) 
		end
		x = b(N, 1);
		y = b(N, 2);
		printf('(%d , %d)}\n', x, y) 
	end
endfunction


%   This function checks if the intersection between img
% and the structuring element b centered in (i, j) is non-empty.
%	Note: b must be represented as a set of pairs, for instance
%			b = [ [0, 1]; [0, 0]; [0, -1]]
%						    0 0 0		
%					==> b = 1 X 1    (where X, position (0, 0),  is the origin)
%							0 0 0
%		or
%			b = [ [-1, 0]; [0, 1]; [0, 0]; [0, -1]; [1, 0]]
%						    0 1 0		
%					==> b = 1 X 1    (where X, position (0, 0), is the origin)
%							0 1 0
function value = has_intersection(img, b, i, j)
	[N M] = size(img);
	value = 0;
	for k = 1:size(b)(1) 
		% get (x, y) coordinates from b
		x = b(k, 1);
		y = b(k, 2);
		% if it's inside the image boundaries
		if 0 < i + x && i + x < N \
		  && 0 < j + y && j + y < M \
		  % if has intersection and it's greter then the previous intersection 
		  && img(i + x, j + y) > value
		  	value = img(i + x, j + y);
		end
	end

endfunction


%   Receive a matrix representing a grayscale image and 
% another matrix representing the structuring element.
%	Find its (morphological) dilation, returning it.
function dlt = dilation(img, b)
	L = 256;
	[N M] = size(img);
	dlt = zeros(N, M);

	for i=1:N
		for j=1:M
			intersection = has_intersection(img, b, i,j);
			dlt(i, j) = intersection;
		end
	end
endfunction



%   This function centers the structuring element b in (i, j)
% and looks to its intersection with the image img, returning 
% the minimum value of this intersection.
%	Note: b must be represented as a set of pairs, for instance
%			b = [ [1, 1]; [0, 0]; [-1, -1]]
%						    1 0 0		
%					==> b = 0 X 0    (where X, position (0, 0),  is the origin)
%							0 0 1
%		or
%			b = [ [0, 1]; [0, 0]; [0, -1]]
%						    0 0 0		
%					==> b = 1 X 1    (where X, position (0, 0), is the origin)
%							0 0 0
function value = minimum_value_inside_intersection(img, b, i, j)
	[N M] = size(img);
	value = 256;
	for k = 1:size(b)(1) 
		% get (x, y) coordinates from b
		x = b(k, 1);
		y = b(k, 2);
		% if it's inside the image boundaries
		if 0 < i + x && i + x <= N \
		  && 0 < j + y && j + y <= M \
		  % if has intersection and it's greter then the previous intersection 
		  && img(i + x, j + y) < value
		  	value = img(i + x, j + y);
		end
	end

endfunction


%   Receives a matrix representing a grayscale image and 
% another matrix representing the structuring element.
%	Find its (morphological) erosion, returning it.
function ers = erosion(img, b)
	L = 256;
	[N M] = size(img);
	ers = zeros(N, M);

	for i=1:N
		for j=1:M
			min_val = minimum_value_inside_intersection(img, b, i,j);
			ers(i, j) = min_val;
		end
	end
endfunction

function grad = gradient(img, b)
	dlt = dilation(img, b);
	ers = erosion(img, b);

	grad = dlt - ers;
endfunction

A = [0 0 1 0 0 0;
     0 5 2 1 0 0;
	 0 3 3 1 2 0;
	 0 5 1 0 0 0;
	 0 0 0 0 0 0]

b = [-1 0;
	 0 0;
	 1 0];

print_flat_structuring_element(b)

dlt = dilation(A, b)

ers = erosion(A, b)

grad = gradient(A, b)

%file = input('Type the path of the image: ', 's');
%img = imread(file);  % read the image

%limit = input('Type the limit value for the thresholding (among 0 and 255): ');

%img_binary = thresholding(img, limit);


%imwrite (img_binary, "binary_image.png", "png"); % save the binary image