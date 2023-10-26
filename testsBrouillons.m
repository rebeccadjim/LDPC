clear;
close all;

C = [1 1 0 1 0 1 0 1];
H = [false true false true true false false true;
    true true true false false true false false;
    false false true false false true true true;
    true false false true true false true false];
    

testDoc = HARD_DECODER_GROUPE3(C, H, 1);
%doit retourner 1 0 0 1 0 1 0 1  comme dans le document