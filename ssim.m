%        Structural SIMilarity 
% Medida de similaridade de duas imagens que leva em conta 
% luminância, contraste e estrutura, ao invés dos seus conteúdos.
%

global L = 256; % definindo a quantidade de tons de cinza.
global K = 0.01; % definindo a constante usada para evitar instabilidade.
global C = (L * K) * (L * K); % definindo a constante usada para evitar instabilidade.

function mu = media(img)
	% qnt de linhas e de colunas da imagem
	[N M] = size(img);
	
	soma = sum(sum(img)); % soma todos os valores da imagem
	mu = soma / (N*M); % divide pela quantidade de pixeis

endfunction



function dp = desvio_padrao(img)
	% qnt de linhas e de colunas da imagem
	[N M] = size(img);

	mi = media(img);
	soma = 0.0;

	img = img - mi;
	img = img .* img;
	soma = sum(sum(img))
	
	variancia = soma / (N*M - 1);
	dp = sqrt(variancia);

endfunction


function corr = correlacao(img1, img2)
	% qnt de linhas e de colunas das images
	[N M] = size(img1);

	mi1 = media(img1);
	mi2 = media(img2);
	soma = 0.0;	

	img1 = img1 - mi1;
	img2 = img2 - mi2;
	soma = sum(sum(img1 .* img2));

	corr = soma / (N*M - 1);

endfunction


function indice = luminancia_comp (img1, img2)
	global C;
	media1 = media(img1);
	media2 = media(img2);

	indice = double(2 * media1 * media2 + C) / double(media1*media1 + media2*media2 + C);
endfunction


function indice = contraste_comp (img1, img2)
	global C;
	dp1 = desvio_padrao(img1);
	dp2 = desvio_padrao(img2);

	indice = double(2 * dp1 * dp2 + C) / double(dp1*dp1 + dp2*dp2 + C);
endfunction



function ec = estrutura_comp (img1, img2)
	global C;
	dp1 = desvio_padrao(img1);
	dp2 = desvio_padrao(img2);
	corr = correlacao(img1, img2);
	ec = double(corr + C) / double(dp1 * dp2 + C);
endfunction

function indice = ssim(img1, img2)
	alpha = 1;
	beta = 1;
	gamma = 1;
	l = luminancia_comp(img1, img2);
	c = contraste_comp(img1, img2);
	e = estrutura_comp(img1, img2);
	indice = (l**alpha) * (c**beta) * (e**gamma);
endfunction

function ssim_map = ssim_map(img1, img2, window_size)

	% create a gaussian window
	window = fspecial('gaussian', window_size, 1.5);
	[N M] = size(img1);
	window_img1 = zeros(window_size);
	window_img2 = zeros(window_size);

	ssim_map = zeros(N, M);


	for i=1+window_size/2:window_size:N-window_size/2
		for j=1+window_size/2:window_size:M-window_size/2
			% copy only a window centered in (i, j)
			window_img1(1:window_size,1:window_size) = img1(i-window_size/2:i+window_size/2,j-window_size/2:j+window_size/2);
			window_img2(1:window_size,1:window_size) = img2(i-window_size/2:i+window_size/2,j-window_size/2:j+window_size/2);
			% apply the gaussian window to these subfigures
			window_img1 = window_img1 .* window;
			window_img2 = window_img2 .* window;
			ssim_map(i, j) = ssim(window_img1, window_img2);
		end
	end


endfunction


nome1 = input('Digite o nome da primeira imagem: ', 's');
nome2 = input('Digite o nome da segunda imagem: ', 's');

img1 = imread(nome1);
img2 = imread(nome2);

[N1 M1] = size(img1);
[N2 M2] = size(img2);
N = min(N1, N2);
M = min(M1, M2);

img1 = int32(imresize (img1, [N M]));
img2 = int32(imresize (img2, [N M]));

map = ssim_map(img1, img2, 11);
%disp('SSIM');
%disp(s);
imshow(map);
