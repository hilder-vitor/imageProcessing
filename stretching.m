
%###########################################
%#		Script  -  Octave
%
%	Recebe uma imagem e os parâmetros do stretching,
% e então realiza um realce de contraste usando essa técnica.
%	A imagem gerada é gravada no arquivo
% "imagem_realcada.png"
%###########################################


%###########################################
%#		Definindo as funções auxiliares
%###########################################

%   Recebe uma matriz representando uma imagem e aplica o método
% de stretching linear, devolvendo a imagem resultante.
function img_realcada = stretching(img, x_1, y_1, x_2, y_2)
	L = 256;
	N = size(img)(1);
	M = size(img)(2);

	img_realcada = zeros(N, M);

	% função de streching:
	% é uma função "linear por partes", quer dizer que é formada por
	% uma "junção" de funções afim, ou seja, da forma y = mx + b.
	% Da origem até (x_1, y_1), 
	m_1 = (y_1 - 0)/(x_1 - 0); % coeficiente angular
	b_1 = y_1 - m_1*x_1;
	
	% de (x_1, y_1) até o (x_2, y_2)
	m_1_2 = (y_1 - y_2)/(x_1 - x_2); % coeficiente angular
	b_1_2 = y_1 - m_1_2*x_1;

	% de (x_2, y_2) até o (L-1, L-1)
	m_2 = (L-1 - y_2)/(L-1 - x_2); % coeficiente angular
	b_2 = y_2 - m_2*x_2;

	for i=1:N
		for j=1:M
			intensidade = uint8(img(i,j));
			if intensidade < x_1
				img_realcada(i,j) = m_1*intensidade + b_1;
			elseif intensidade < x_2
				img_realcada(i,j) = m_1_2*intensidade + b_1_2;
			else
				img_realcada(i,j) = m_2*intensidade + b_2;
			end
		end
	end
	img_realcada = uint8(img_realcada);
endfunction



arquivo = input('Digite o caminho da imagem: ', 's');
img = imread(arquivo);  % lê a imagem

x_1 = input('Digite o valor do x_1 (entre 0 e 255): ');
y_1 = input('Digite o valor do y_1 (entre 0 e 255): ');
x_2 = input('Digite o valor do x_2 (entre 0 e 255): ');
y_2 = input('Digite o valor do y_2 (entre 0 e 255): ');

img_realcada = stretching(img, x_1, y_1, x_2, y_2);

imwrite (img_realcada, "imagem_realcada.png", "png"); % grava a versão realçada
