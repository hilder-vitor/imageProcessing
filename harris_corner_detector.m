%###########################################
%#		Script  -  Octave
%
%	Recebe uma imagem e tenta achar os 
% cantos usando o algoritmo do Harris
%###########################################


%###########################################
%#		Definindo as funções auxiliares
%###########################################

%   Recebe uma matriz representando uma imagem e aplica o método
% de stretching linear, devolvendo a imagem resultante.
function img_cantos = harris(img)
	L = 256;
	tamanhoJanela = 5;
	k = 0.04;
	[N M] = size(img);

	% calcula as derivadas parciais (na horizontal e na vertical)
	Ix = conv2(img, [-1 0 1], 'same');  % convolução de cada linha com [-1 0 1]
	Iy = conv2(img, [-1; 0; 1], 'same'); % convolução de cada coluna com [-1; 0; 1]

	Ix2 = Ix .* Ix;
	Iy2 = Iy .* Iy;
	Ixy = Ix .* Iy;

	% cria uma janela gaussiana <tamanhoJanela> x <tamanhoJanela>
	w = fspecial('gaussian', tamanhoJanela, 1.5);

	% aplica esta janela às matrizes que representam as derivadas parciais
	A = conv2(Ix2, w, 'same');
	B = conv2(Iy2, w, 'same');
	C = conv2(Ixy, w, 'same');

	% equivalente a H(x, y) = [A(x,y) C(x,y); C(x,y) B(x,y)]; R(x,y) = det(H) - k (trace(H)^2); para todo (x,y)
	R = (A .* B - C.^2) - k * ((A + B) .* (A + B));
	
	threshold = 0.03 * max(R(:));
	img_cantos = zeros(N, M);

	for x=2:N-1
		for y=2:M-1
		 	if (R(x, y) > threshold
				&& R(x,y) > R(x-1,y-1)
				&& R(x,y) > R(x-1,y)
				&& R(x,y) > R(x-1,y+1)
				&& R(x,y) > R(x,y-1)
				&& R(x,y) > R(x,y+1)
				&& R(x,y) > R(x+1,y-1)
				&& R(x,y) > R(x+1,y)
				&& R(x,y) > R(x+1,y+1))

				img_cantos(x, y) = 1;
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
	for i=3:N-1
		for j=3:M-1
			if cantos(i, j)
				plot(j,i,'r','markersize', 10)
			end
		end
	end
	% gravando a imagem com os cantos destacados
	print('cantos_destacados_harris.png');
endfunction



%%%%%%%%%%%%%%%%%%
%%		main
%%%%%%%%%%%%%%%%%%


arquivo = input('Digite o caminho da imagem: ', 's');
img = imread(arquivo);  % lê a imagem

cantos = harris(img);

mostraCantos(img, cantos);
