function c_cor = SOFT_DECODER_GROUPE3(c, H, p, MAX_ITER)
% DESCRIPTION:
%   Décodeur LDPC soft
%
% ENTREES:
%   c - Vecteur binaire de dimension [N, 1]
%   H - Matrice booléenne de parité de dimension [M, N] 
%   p - Vecteur de dimension [N, 1] contenant les probabilités p(i) 
%   MAX_ITER - Nombre d'itérations maximales du décodeuer
%
% SORTIES:
%   c_cor - vecteur binaire de dimension [N, 1] issu du décodage

    N = size(H,2);
    M = size(H,1);

    %Utiliser deux matrices pour représenter la communication
    %Puisque 1 lien sur le graphe de Tanner = 1 échange = 1 coef dans la
    %matrice
    %Donc le message à la ligne j, colonne i correspond à l'échange (dans
    %un sens ou dans l'autre selon la matrice) entre le CN j et le VN i
    %De plus, dans cette version soft, le premier coef correspond à msg(1)
    %tandis que le deuxième coef correspond à msg(0)
    VNtoCNmessages = -1*ones(M,N,2); %les VN écrivent, les CN lisent
    CNtoVNmessages = -1*ones(M,N,2); %les CN écrivent, les VN lisent

    iterationCounter = 0;
    c_cor = c;
    
    %ETAPE 1: VN vers CN, ici en dehors de la boucle (comme dans le document)
    %Pour chaque VN :
    for i = 1:N
        for j = 1:M
            if H(j,i)
                %qij(1) et qij(0)
                VNtoCNmessages(j,i,:)= [p(i) 1-p(i)];
            end
        end
    end
    
    while (iterationCounter < MAX_ITER)
        
        %ETAPE 2: CN vers VN (test de parité et réponse)
        for j = 1:M
            connectedVNindexes = find(H(j,:) == true);
            for i = connectedVNindexes
                %mise à l'écart de i
                sans_i = connectedVNindexes(connectedVNindexes ~= i);
                %récupération des q(1) envoyés par les VN à l'étape 1 sans
                %celui du VN étudié
                recieved_q_sans_i = VNtoCNmessages(j,sans_i,1);
                %calcul de la réponse rji(0) à envoyer
                rji = calculateCNresponse(recieved_q_sans_i);
                CNtoVNmessages(j,i,:) = rji;
            end
        end

        %ETAPE 3: réponse des VN et décision
        for i = 1:N
            connectedCNindexes = transpose(find(H(:,i) == true));
            for j = connectedCNindexes
                %mise à l'écart de j
                sans_j = connectedCNindexes(connectedCNindexes ~= j);
                %récupération des rji envoyés par les CN à l'étape 2 sans
                %celui du CN étudié
                recieved_r_sans_j = permute(CNtoVNmessages(sans_j,i,:),[2, 1, 3]);
                %calcul de la réponse qij à envoyer
                qij = calculateVNresponse(recieved_r_sans_j, p(i));
                VNtoCNmessages(j,i,:) = qij;
            end
            recieved_r = CNtoVNmessages(connectedCNindexes,i,:);
            c_cor(i) = estimateBit(recieved_r, p(i));
        end
        
        %Si c vérifie la parité, on finit l'algorithme
        if(verifyParity(c_cor)==true)
            break;
        end
        
        iterationCounter = iterationCounter + 1;
        
    end
    c_cor = logical(c_cor);
end



function CNresponse = calculateCNresponse(q_sans_i)
% DESCRIPTION:
%   Calcule la réponse rji à envoyer au Variable Node c(i)
%
% ENTREES:
%   q_sans_i - messages reçus qij(1) sans celui du VN destinataire c(i)
%
% SORTIES:
%   CNresponse - Réponses rji(1) et rji(0) à envoyer au Variable Node c(i)
    
    rji_zero = 0.5 + 0.5*prod(1-2*q_sans_i,'all');
    CNresponse = [1-rji_zero rji_zero];
    
end


function VNresponse = calculateVNresponse(recievedCNmessage, pb)
% DESCRIPTION:
%   Calcule la réponse qij(0) à envoyer au Check Node f(j)
%
% ENTREES:
%   recievedCNmessage - messages reçus rij sans ceux du CN destinataire f(i)
%   pb - Probabilité p(i)
%
% SORTIES:
%   VNresponse - Réponse qij(0) à envoyer au Check Node f(j)
    
    pre_qij_zero = (1-pb)*prod(recievedCNmessage(:,2),'all');
    pre_qij_un = pb*prod(recievedCNmessage(:,1),'all');
    Kij = 1/(pre_qij_zero + pre_qij_un);
    VNresponse = [Kij*pre_qij_un Kij*pre_qij_zero];

end


function VNestimation = estimateBit(recievedCNmessage, pb)
% DESCRIPTION:
%   Estime le bit c(i) à partir des rji.
%
% ENTREES:
%   recievedCNmessage - Vecteur dimension [M,2] messages rji(1) et rji(0)
%   pb - Probabilité p(i)
%
% SORTIES:
%   VNestimation - Bit estimé c(i)

    Qi_zero = (1-pb)*prod(recievedCNmessage(:,2),'all');
    Qi_un = pb*prod(recievedCNmessage(:,1),'all');
    %Ki inutile car on ne fait que vérifier si Q(1) > Q(0)
    if Qi_un > Qi_zero
        VNestimation = 1;
    else
        VNestimation = 0;
    end

end

function isParityVerified = verifyParity(bits)
% DESCRIPTION:
%   Indique si la suite de bits vérifie la parité
%
% ENTREES:
%   bits - suite de bits
%
% SORTIES:
%   isParityVerified - false si non valide, true si valide
    
    somme = sum(bits);
    if rem(somme,2) == 0
        isParityVerified = true;
    else
        isParityVerified = false;
    end
end
