%        Structural SIMilarity 
% Medida de similaridade de duas imagens que leva em conta 
% luminância, contraste e estrutura, ao invés dos seus conteúdos.
%

global L = 256; % definindo a quantidade de tons de cinza.
global K = 0.01; % definindo a constante usada para evitar instabilidade.
global C = (L * K) * (L * K); % definindo a constante usada para evitar instabilidade.

function mu = media(img)
	% qnt de linhas e de colunas da imagem
	N = size(img)(1);
	M = size(img)(2);
	
	soma = sum(img(:)); % soma todos os valores da imagem
	mu = soma / (N*M); % divide pela quantidade de pixeis

endfunction

function dp = desvio_padrao(img)
	% qnt de linhas e de colunas da imagem
	N = size(img)(1);
	M = size(img)(2);

	mi = media(img);
	soma = 0.0;

	for i=1:N
		for j=1:M
			soma = soma + (img(i, j) - mi) * (img(i, j) - mi);
		end
	end

	variancia = soma / (N*M - 1);
	dp = sqrt(variancia);

endfunction


function corr = correlacao(img1, img2)
	% qnt de linhas e de colunas da imagem 1
	N1 = size(img1)(1);
	M1 = size(img1)(2);

	% qnt de linhas e de colunas da imagem 2
	N2 = size(img2)(1);
	M2 = size(img2)(2);

	N = min(N1, N2);
	M = min(M1, M2);

	mi1 = media(img1);
	mi2 = media(img2);
	soma = 0.0;	

	for i=1:N
		for j=1:M
			soma = soma + (img1(i, j) - mi1) * (img2(i, j) - mi2);		
		end
	end

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


nome1 = input('Digite o nome da primeira imagem: ', 's');
nome2 = input('Digite o nome da segunda imagem: ', 's');

img1 = int32(imread(nome1));
img2 = int32(imread(nome2));

l = luminancia_comp(img1, img2);
disp('O índice de comparação das luminâncias é');
disp(l);

c = contraste_comp(img1, img2);
disp('O índice de comparação dos constrastes é');
disp(c);

e = estrutura_comp(img1, img2);
disp('O índice de comparação das estruturas das imagens é');
disp(e);

s = ssim(img1, img2);
disp('SSIM das duas imagens é');
disp(s);
