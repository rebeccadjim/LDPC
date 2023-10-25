clear all;
close all;

function c_cor = SOFT_DECODER_GROUPE3(c, H, p, MAX_ITER)
% DESCRIPTION:
%   Décodeur LDPC soft appelé par le testeur automatique
%
% ENTREES:
%   c - Vecteur binaire de dimension [N, 1]
%   H - Matrice booléenne de parité de dimension [M, N] 
%   p - Vecteur de dimension [N, 1] contenant les probabilités p(i) 
%   MAX_ITER - Nombre d'itérations maximales du décodeuer
%
% SORTIES:
%   c_cor - vecteur binaire de dimension [N, 1] issu du décodage

% à coder

end


function CNresponse = calculateCNresponse(recievedVNmessage, CNnumber)
% DESCRIPTION:
%   Calcule la réponse rij(0) à envoyer au Variable Node c(i)
%
% ENTREES:
%   recievedVNmessage - Vecteur de probabilités de dimension [N, 1]
%   CNnumber - Index i du Variable Node en question
%
% SORTIES:
%   CNresponse - Réponse rij(0) à envoyer au Variable Node c(i)

end

function VNresponse = calculateVNresponse(recievedCNmessage, VNnumber)
% DESCRIPTION:
%   Calcule la réponse qij(0) à envoyer au Check Node f(j)
%
% ENTREES:
%   recievedCNmessage - Vecteur de probabilités de dimension [N, 1]
%   VNnumber - Index j du Check Node en question
%
% SORTIES:
%   VNresponse - Réponse qij(0) à envoyer au Check Node f(j)

end
