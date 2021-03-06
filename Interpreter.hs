module Interpreter where

import Parser 
import Graphics.Rendering.OpenGL (AccumOp(Mult))

-- Definição de tipos
---------------------
data Ty = TBool
        | TNum 
        deriving Show

-- Função que avalia um passo de execução
-- Adicionar os novos operadores (Multi)
--------------------------------------------
step :: Expr -> Maybe Expr
-- S-Add
step (Add (Num n1) (Num n2)) = Just (Num (n1 + n2))
-- S-Add2 
step (Add (Num n) e2) = 
    case (step e2) of
        Just e2' -> Just (Add (Num n) e2')
        Nothing  -> Nothing                        
-- S-Add1
step (Add e1 e2) = 
    case (step e1) of 
        Just e1' -> Just (Add e1' e2)
        Nothing  -> Nothing
-- S-And2
step (And BTrue e2) = Just e2
-- S-And3
step (And BFalse e2) = Just BFalse
-- S-And1
step (And e1 e2) = 
    case (step e1) of 
        Just e1' -> Just (And e1' e2)
        Nothing  -> Nothing
step (If BTrue e1 e2) = Just e1
step (If BFalse e1 e2) = Just e2
step (If e1 e2 e3) = case (step e1) of
                       Just e1' -> Just (If e1' e2 e3)
                       Nothing  -> Nothing
step (Or BTrue e2) = Just BTrue  
step (Or BFalse e2) = Just e2
step (Or e1 e2) = 
    case (step e1) of
        Just e1' -> Just (Or e1' e2)
        Nothing  -> Nothing 
step (Multi (Num n1) (Num n2)) = Just (Num (n1 + n2))
step (Multi (Num n1) e2) =
    case (step e2) of
        Just e2' -> Just (Multi (Num n1) e2')
        Nothing  -> Nothing 
step (Multi e1 e2) = 
    case (step e1) of 
        Just e1' -> Just (Multi e1' e2)
        Nothing  -> Nothing

step e = Just e

-- Função que avalia uma expressão até apresentar um
-- resultado ou gerar um erro
-- Não precisa alterar
----------------------------------------------------
eval :: Expr -> Maybe Expr
eval e = case (step e) of 
           Just e' -> if (e == e') then
                        Just e
                      else
                        eval e'
           _ -> error "Semantic error: erro avaliando expressão!" 

-- Função que verifica o tipo de uma expressão
----------------------------------------------
typeof :: Expr -> Maybe Ty 
typeof BTrue = Just TBool
typeof BFalse = Just TBool
typeof (Num _) = Just TNum
typeof (Add e1 e2) = case (typeof e1) of
                       Just TNum -> case (typeof e2) of
                                      Just TNum -> Just TNum
                                      _         -> Nothing -- erro de tipo
                       _         -> Nothing -- erro de tipo
typeof (And e1 e2) = case (typeof e1, typeof e2) of 
                       (Just TBool, Just TBool) -> Just TBool
                       _                        -> Nothing -- erro de tipo
typeof (If e1 e2 e3) = case (typeof e1) of 
                         Just TBool -> case (typeof e2, typeof e3) of 
                                         (Just TBool, Just TBool) -> Just TBool
                                         (Just TNum, Just TNum)   -> Just TNum
                                         _                        -> Nothing -- erro de tipo
                         _          -> Nothing -- erro de tipo
typeof (Or e1 e2) = case (typeof e1, typeof e2) of
                    (Just TBool, Just TBool) -> Just TBool
                    _                        -> Nothing 
typeof (Multi e1 e2) = case(typeof e1) of
                        Just TNum -> case (typeof e2) of
                            Just TNum -> Just TNum
                            _         -> Nothing 
                        _1        -> Nothing 
-- Função que faz a verificação de tipos
-- Não precisa alterar
----------------------------------------
typecheck :: Expr -> Expr
typecheck e = case (typeof e) of 
                Just _ -> e
                _ -> error "Type error: erro na verificação de tipos!"


------------------------------------------
-- Ler os códigos e chamar o interpretador
------------------------------------------
main = getContents >>= print . eval . typecheck . parser . lexer 

