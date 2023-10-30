function c_cor = HARD_DECODER_GROUPE3(c, H, MAX_ITER)
% DESCRIPTION:
%   Décodeur LDPC hard appelé par le testeur automatique
%
% ENTREES:
%   c - Vecteur binaire de dimension [N, 1]
%   H - Matrice booléenne de parité de dimension [M, N] 
%   MAX_ITER - Nombre d'itérations maximales du décodeur
%
% SORTIES:
%   c_cor - vecteur binaire de dimension [N, 1] issu du décodage

    N = size(H,2);
    M = size(H,1);

    %Utiliser deux matrices pour représenter la communication
    %Puisque 1 lien sur le graphe de Tanner = 1 échange = 1 coef dans la
    %matrice
    VNtoCNmessages = -1*ones(M,N); %les VN écrivent, les CN lisent
    CNtoVNmessages = -1*ones(M,N); %les CN écrivent, les VN lisent

    iterationCounter = 0;
    c_cor = c;
    
    while (iterationCounter < MAX_ITER)

        %ETAPE 1: VN vers CN
        %Pour chaque VN
        for i = 1:N
            for j = 1:M
                if H(j,i)
                    VNtoCNmessages(j,i)= c_cor(i);
                end
            end
        end
        
        %ETAPE 2: CN vers VN (test de parité et réponse)
        changeMade = 0;
        for j = 1:M
            connectedVNindexes = find(H(j,:) == true);
            for i = connectedVNindexes
                %mise à l'écart de i 
                sans_i = connectedVNindexes(connectedVNindexes ~= i);
                %récupération des bits envoyés par les VN à l'étape 1
                assumedCorrectBits = VNtoCNmessages(j,sans_i);
                %calcul du bit qui vérifierai la parité et envoi au VN
                proposedBit = parityCheck(assumedCorrectBits);
                CNtoVNmessages(j,i) = proposedBit;
                %retenir si la proposition du VN était mauvaise
                if (proposedBit ~= VNtoCNmessages(j,i))
                    changeMade = changeMade +1;
                end
            end
        end
        
        %fin de l'algorithme si on a rien eu à changer par rapport aux
        %propositions des VN à l'étape 1 pour valider la parité
        if (changeMade == 0)
            break
        end

        %ETAPE 3: décision des VN
        for i = 1:N
            %récupération des messages des CN l'étape 2 (peu optimisé)
            %Matlab indique que ces deux lignes ne sont pas optimisées
            messagesFromConnectedCN = CNtoVNmessages(H(:,i) == true,i);
            %nouveau bit = vote à majorité entre l'observation et les msg
            c_cor(i) = majorityCheck(c(i),messagesFromConnectedCN);
        end

        iterationCounter = iterationCounter + 1;
    end

end



function requiredBit = parityCheck(bits)
% DESCRIPTION:
%   Indique le bit à choisir pour vérifier la parité
%
% ENTREES:
%   bits - bits considérés comme corrects
%
% SORTIES:
%   requiredBit - bit à choisir pour que sa somme XOR avec les bits
%   d'entrée fasse 0
    somme = sum(bits);
    if rem(somme,2) == 0
        requiredBit = 0; %XOR(0,0) donne 0
    else
        requiredBit = 1; %XOR(1,1) donne 0
    end
end



function decidedBit = majorityCheck(observation, CNresponses)
% DESCRIPTION:
%   Décider du bit en fonction de l'observation et des réponses obtenues
%   des CN à l'étape 2
%
% ENTREES:
%   observation - le bit tel qu'originellement observé
%   CNresponses - les réponses obtenues grâce au CN connectés
%
% SORTIES:
%   decidedBit - bit que le VN va retenir

    obsAndResponses = [observation transpose(CNresponses)];
    decidedBit = mode(obsAndResponses); %bit majoritaire dans le vecteur

end
