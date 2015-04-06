%###########################################
%         Moravec Corner Detector
%
%	This script find the corners in a image
% using the Moravec method.
%###########################################


%###########################################
%#		Defining the auxiliares functions
%###########################################


%%    This function calculates the intensity variation caused by a shift (u, v) using a window
%% whose size is wxw and is centered at (x, y)
%%    Important: w is supposed to be odd.
function variation = intensity_variation_from_shift (img, x, y, u, v, w)
	% find subscripts to the submatrix regarding the img and a wxw window	
	% note that x_subscript (and y_subscript) is a w-dimensional vector
	x_subscript = x - floor(w/2):x + floor(w/2);
	y_subscript = y - floor(w/2):y + floor(w/2);

	window = img(x_subscript, y_subscript);
	shifted_window = img(x_subscript + u, y_subscript + v); % sum u (v) to each position of x_subscript (y_subscript)

	dif = window - shifted_window;
	square_diff = dif .* dif;

	variation = sum(square_diff(:));
endfunction


function min_variation = cornerness_measure (img, x, y, w)
	s1 = intensity_variation_from_shift(img, x, y, 1, 0, w);
	s2 = intensity_variation_from_shift(img, x, y, 1, 1, w);
	s3 = intensity_variation_from_shift(img, x, y, 0, 1, w);
	s4 = intensity_variation_from_shift(img, x, y, -1,1, w);
	s5 = intensity_variation_from_shift(img, x, y, -1,0, w);
	s6 = intensity_variation_from_shift(img, x, y, -1,-1, w);
	s7 = intensity_variation_from_shift(img, x, y, 0,-1, w);
	s8 = intensity_variation_from_shift(img, x, y, 1,-1, w);
	
	min_variation = min([s1 s2 s3 s4 s5 s6 s7 s8]);

endfunction


function corners = moravec(img, threshold)
	L = 256;
	windowSize = 3;
	k = 0.04;
	[N M] = size(img);
	cornerness = zeros(N, M);

	for x=3:N-2
		for y=3:M-2
			cornerness(x, y) = cornerness_measure(img, x, y, windowSize);
			if (cornerness(x, y) < threshold)
				cornerness(x, y) = 0;
			end
		end
	end

	corners = zeros(N, M);

	for x=2:N-1
		for y=2:M-1
		 	if (cornerness(x,y) > cornerness(x-1,y-1)
				&& cornerness(x,y) > cornerness(x-1,y)
				&& cornerness(x,y) > cornerness(x-1,y+1)
				&& cornerness(x,y) > cornerness(x,y-1)
				&& cornerness(x,y) > cornerness(x,y+1)
				&& cornerness(x,y) > cornerness(x+1,y-1)
				&& cornerness(x,y) > cornerness(x+1,y)
				&& cornerness(x,y) > cornerness(x+1,y+1))

				corners(x, y) = 1;
			end
		end
	end


endfunction


%  	Recebe a matriz img representando a imagem e a matriz binárias cantos, representando os pontos que
% devem ser destacados.
%	A imagem é mostrada em uma janela com a seguinte modificação: 
% 		para cada posição (i, j) da matriz cantos cujo valor seja diferente de zero, um círculo vermelho
%		é desenhado na posição (i, j) da imagem.
function mostraCantos(img, cantos)
	[N M] = size(img);
	imshow(img);
	hold on;
	for i=3:N-2
		for j=3:M-2
			if cantos(i, j)
				plot(j,i,'r','markersize', 10)
			end
		end
	end
	% gravando a imagem com os cantos destacados
	print('cantos_destacados_moravec.png');
endfunction



%%%%%%%%%%%%%%%%%%
%%		main
%%%%%%%%%%%%%%%%%%


arquivo = input('Digite o caminho da imagem: ', 's');
img = imread(arquivo);  % lê a imagem

corners = moravec(img, 175);

mostraCantos(img, corners);
