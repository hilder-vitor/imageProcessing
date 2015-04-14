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
	soma = sum(sum(img));
	
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
	alpha = 1.0;
	beta = 1.0;
	gamma = 1.0;
	l = luminancia_comp(img1, img2);
	c = contraste_comp(img1, img2);
	e = estrutura_comp(img1, img2);
	indice = (l**alpha) * (c**beta) * (e**gamma);
	
endfunction

function new_map = map_into_interval_0_255 (A)

   % y = 7.26648*10^6 * x^11 - 2.05466 * 10^7 * x^10 
	%  + 7.26512*10^6 * x^9 + 2.91364*10^7 * x^8 - 2.91585* 10^7 * x^7  - 4.89464 * 10^6 * x^6  + 1.67244 * 10^7 * x^5  - 4.83483 * 10^6 * x^4 - 1.96304 * 10^6 * x^3 + 1.13975 * 10^6 * x^2 - 134307 * x  + 30;
	
 %	 y = int8(y)
	[N M] = size(A);
	new_map = zeros(N, M);
	for i=1:N
		for j=1:M
			x = A(i, j);
			if x < 0
				y = 0;
			elseif x < 0.7
				y = 35 * x;
			elseif x < 0.75
				y = 45 * x;
			elseif x < 0.85
				y = 60 * x;
			elseif x < 0.95
				y = 75 * x;
			elseif x < 0.98
				y = 100 * x;
			elseif x < 0.99
				y = 120 * x + rem(x*1000, 10);
			elseif x < 0.999
				y = 150 * x + rem(x*10000, 10);
			elseif x < 0.9999
				y = 185 * x + rem(x*10000, 10);
			else
				y = 255 * x;
			end
			new_map(i, j) = y;
		end
	end

	new_map = int8(new_map);

%	m = 127.5;
%	y = rem(int32(m * x +  m), 256);

endfunction

function ssim_map = ssim_map(img1, img2, window_size)

	% create a gaussian window
	window = fspecial('gaussian', window_size, 1.5);
	[N M] = size(img1);
	window_img1 = zeros(window_size);
	window_img2 = zeros(window_size);

	ssim_map = zeros(N/window_size, M/window_size);
	k = l = 0;


	for i=int32(1+window_size/2):window_size:int32(N-window_size/2)
		k++;
		l = 0;
		for j=int32(1+window_size/2):window_size:int32(M-window_size/2)
			l++;
			% copy only a window centered in (i, j)
			window_img1(1:window_size,1:window_size) = img1(int32(i-window_size/2):int32(i+window_size/2-1),int32(j-window_size/2):int32(j+window_size/2-1));
			window_img2(1:window_size,1:window_size) = img2(int32(i-window_size/2):int32(i+window_size/2-1),int32(j-window_size/2):int32(j+window_size/2-1));
			% apply the gaussian window to these subfigures
			window_img1 = window_img1 .* window;
			window_img2 = window_img2 .* window;
			ssim_map(k, l) = ssim(window_img1, window_img2); % -1 <= index <= 1
		end
	end

endfunction


nome1 = input('Digite o nome da primeira imagem: ', 's');
nome2 = input('Digite o nome da segunda imagem: ', 's');
%nome1 = 'monalisa.jpg';
%nome1 = 'teste_mapa_SSIM/borboleta.jpg';
%nome1 = 'teste_mapa_SSIM/lobo.png';
%nome2 = 'teste_mapa_SSIM/lobo_borrado_cantos.png';
%nome2 = 'monalisa_inclinada.jpg';
%nome2 = 'teste_mapa_SSIM/borboleta_borrada_meio.jpg';

img1 = imread(nome1);
img2 = imread(nome2);

[N1 M1] = size(img1);
[N2 M2] = size(img2);
N = min(N1, N2);
M = min(M1, M2);

img1 = int32(imresize (img1, [N M]));
img2 = int32(imresize (img2, [N M]));

s = ssim(img1, img2);
ssim_map = ssim_map(img1, img2, 11);
map = map_into_interval_0_255(ssim_map); % map to integers in [0, 255] 
imshow(map);
hold on;
print('ssim_map.png');

disp('SSIM');
disp(s);

disp('MSSIM');
[Nmap Mmap] = size(ssim_map);
ms = sum(sum(ssim_map)) / (Nmap * Mmap);
disp(ms);
