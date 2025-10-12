-- ============================================================================
-- UNIVERSIDAD NACIONAL MAYOR DE SAN MARCOS
-- Universidad del Perú. Decana de América
-- Facultad de Ingeniería de Sistemas e Informática
-- 
-- LABORATORIO 4 - Base de datos II
-- AUTOR: Nuñez Cárdenas Ivan Joaquin
-- DOCENTE: Jorge Luis Chávez Soto
-- CURSO: Base de datos II
-- FECHA: Lima, Perú 2025
-- ============================================================================

-- ============================================================================
-- PROCEDIMIENTOS Y FUNCIONES - CONSULTAS SOBRE PROVEEDORES Y PARTES
-- ============================================================================

-- ============================================================================
-- 1. Color y ciudad para las partes que no son de París, con peso mayor de 10
-- ============================================================================
CREATE OR REPLACE PROCEDURE SP_PARTES_NO_PARIS_PESO AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Color y Ciudad de partes (no París, peso > 10):');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
    
    FOR rec IN (
        SELECT COLOR, CITY
        FROM P
        WHERE CITY != 'Paris' AND WEIGHT > 10
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Color: ' || rec.COLOR || ', Ciudad: ' || rec.CITY);
    END LOOP;
END SP_PARTES_NO_PARIS_PESO;
/

-- ============================================================================
-- 2. Para todas las partes, número de parte y peso en gramos
-- ============================================================================
CREATE OR REPLACE PROCEDURE SP_PARTES_PESO_GRAMOS AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Número de parte y peso en gramos:');
    DBMS_OUTPUT.PUT_LINE('----------------------------------');
    
    FOR rec IN (
        SELECT P_NUM, 
               WEIGHT, 
               ROUND(WEIGHT * 453.592, 2) AS PESO_GRAMOS
        FROM P
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Parte: ' || rec.P_NUM || ', Peso: ' || rec.PESO_GRAMOS || ' gramos');
    END LOOP;
END SP_PARTES_PESO_GRAMOS;
/

-- ============================================================================
-- 3. Detalle completo de todos los proveedores
-- ============================================================================
CREATE OR REPLACE PROCEDURE SP_DETALLE_PROVEEDORES AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Detalle completo de proveedores:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    
    FOR rec IN (
        SELECT * 
        FROM S 
        ORDER BY S_NUM
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Proveedor: ' || rec.S_NUM ||
                           ', Nombre: ' || rec.SNAME ||
                           ', Status: ' || rec.STATUS ||
                           ', Ciudad: ' || rec.CITY);
    END LOOP;
END SP_DETALLE_PROVEEDORES;
/

-- ============================================================================
-- 4. Combinaciones de proveedores y partes co-localizados
-- ============================================================================
CREATE OR REPLACE PROCEDURE SP_PROVEEDORES_PARTES_COLOCALIZADOS AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Proveedores y partes co-localizados:');
    DBMS_OUTPUT.PUT_LINE('------------------------------------');
    
    FOR rec IN (
        SELECT S.S_NUM, S.SNAME, P.P_NUM, P.PNAME, S.CITY
        FROM S, P
        WHERE S.CITY = P.CITY
        ORDER BY S.S_NUM, P.P_NUM
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Proveedor: ' || rec.S_NUM || ' (' || rec.SNAME ||
                           '), Parte: ' || rec.P_NUM || ' (' || rec.PNAME ||
                           '), Ciudad: ' || rec.CITY);
    END LOOP;
END SP_PROVEEDORES_PARTES_COLOCALIZADOS;
/

-- ============================================================================
-- 5. Pares de ciudades (proveedor -> parte)
-- ============================================================================
CREATE OR REPLACE PROCEDURE SP_PARES_CIUDADES AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Pares de ciudades (Proveedor -> Parte):');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    
    FOR rec IN (
        SELECT DISTINCT S.CITY AS CIUDAD_PROVEEDOR, 
                        P.CITY AS CIUDAD_PARTE
        FROM S, P, SP
        WHERE S.S_NUM = SP.S_NUM
          AND P.P_NUM = SP.P_NUM
        ORDER BY S.CITY, P.CITY
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Ciudad Proveedor: ' || rec.CIUDAD_PROVEEDOR ||
                           ' -> Ciudad Parte: ' || rec.CIUDAD_PARTE);
    END LOOP;
END SP_PARES_CIUDADES;
/

-- ============================================================================
-- 6. Pares de proveedores co-localizados
-- ============================================================================
CREATE OR REPLACE PROCEDURE SP_PROVEEDORES_PARES_COLOCALIZADOS AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Pares de proveedores co-localizados:');
    DBMS_OUTPUT.PUT_LINE('------------------------------------');
    
    FOR rec IN (
        SELECT S1.S_NUM AS PROVEEDOR1, 
               S2.S_NUM AS PROVEEDOR2, 
               S1.CITY
        FROM S S1, S S2
        WHERE S1.CITY = S2.CITY
          AND S1.S_NUM < S2.S_NUM
        ORDER BY S1.S_NUM, S2.S_NUM
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Par: (' || rec.PROVEEDOR1 || ', ' || rec.PROVEEDOR2 ||
                           ') en ' || rec.CITY);
    END LOOP;
END SP_PROVEEDORES_PARES_COLOCALIZADOS;
/

-- ============================================================================
-- 7. Total de proveedores (función)
-- ============================================================================
CREATE OR REPLACE FUNCTION FN_TOTAL_PROVEEDORES RETURN NUMBER AS
    v_total NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_total FROM S;
    RETURN v_total;
END FN_TOTAL_PROVEEDORES;
/

-- ============================================================================
-- 8. Cantidad mínima y máxima para la parte P2
-- ============================================================================
CREATE OR REPLACE PROCEDURE SP_MIN_MAX_P2 (
    p_min OUT NUMBER,
    p_max OUT NUMBER
) AS
BEGIN
    SELECT NVL(MIN(QTY), 0), NVL(MAX(QTY), 0)
    INTO p_min, p_max
    FROM SP
    WHERE P_NUM = 'P2';
END SP_MIN_MAX_P2;
/

-- ============================================================================
-- 9. Para cada parte abastecida, número y total despachado
-- ============================================================================
CREATE OR REPLACE PROCEDURE SP_TOTAL_DESPACHADO AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Parte y total despachado:');
    DBMS_OUTPUT.PUT_LINE('-------------------------');
    
    FOR rec IN (
        SELECT P_NUM, SUM(QTY) AS TOTAL_QTY
        FROM SP
        GROUP BY P_NUM
        ORDER BY P_NUM
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Parte: ' || rec.P_NUM || ', Total: ' || rec.TOTAL_QTY);
    END LOOP;
END SP_TOTAL_DESPACHADO;
/

-- ============================================================================
-- 10. Partes abastecidas por más de un proveedor
-- ============================================================================
CREATE OR REPLACE PROCEDURE SP_PARTES_VARIOS_PROVEEDORES AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Partes abastecidas por más de un proveedor:');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
    
    FOR rec IN (
        SELECT P_NUM, COUNT(DISTINCT S_NUM) AS NUM_PROVEEDORES
        FROM SP
        GROUP BY P_NUM
        HAVING COUNT(DISTINCT S_NUM) > 1
        ORDER BY P_NUM
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Parte: ' || rec.P_NUM ||
                           ' (Proveedores: ' || rec.NUM_PROVEEDORES || ')');
    END LOOP;
END SP_PARTES_VARIOS_PROVEEDORES;
/

-- ============================================================================
-- 11. Proveedores que abastecen la parte P2
-- ============================================================================
CREATE OR REPLACE PROCEDURE SP_PROVEEDORES_P2 AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Proveedores que abastecen P2:');
    DBMS_OUTPUT.PUT_LINE('------------------------------');
    
    FOR rec IN (
        SELECT DISTINCT S.SNAME
        FROM S, SP
        WHERE S.S_NUM = SP.S_NUM
          AND SP.P_NUM = 'P2'
        ORDER BY S.SNAME
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Proveedor: ' || rec.SNAME);
    END LOOP;
END SP_PROVEEDORES_P2;
/

-- ============================================================================
-- 12. Proveedores que abastecen por lo menos una parte
-- ============================================================================
CREATE OR REPLACE PROCEDURE SP_PROVEEDORES_CON_ENVIOS AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Proveedores que abastecen al menos una parte:');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------');
    
    FOR rec IN (
        SELECT DISTINCT S.SNAME
        FROM S, SP
        WHERE S.S_NUM = SP.S_NUM
        ORDER BY S.SNAME
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Proveedor: ' || rec.SNAME);
    END LOOP;
END SP_PROVEEDORES_CON_ENVIOS;
/

-- ============================================================================
-- 13. Proveedores con status menor que el máximo
-- ============================================================================
CREATE OR REPLACE PROCEDURE SP_PROVEEDORES_STATUS_MENOR_MAX AS
    v_max_status NUMBER;
BEGIN
    SELECT MAX(STATUS) INTO v_max_status FROM S;
    
    DBMS_OUTPUT.PUT_LINE('Proveedores con status < ' || v_max_status || ':');
    DBMS_OUTPUT.PUT_LINE('----------------------------------');
    
    FOR rec IN (
        SELECT S_NUM, SNAME, STATUS
        FROM S
        WHERE STATUS < v_max_status
        ORDER BY S_NUM
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Proveedor: ' || rec.S_NUM ||
                           ' (' || rec.SNAME || '), Status: ' || rec.STATUS);
    END LOOP;
END SP_PROVEEDORES_STATUS_MENOR_MAX;
/

-- ============================================================================
-- 14. Proveedores que abastecen P2 (usando EXISTS)
-- ============================================================================
CREATE OR REPLACE PROCEDURE SP_PROVEEDORES_P2_EXISTS AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Proveedores que abastecen P2 (EXISTS):');
    DBMS_OUTPUT.PUT_LINE('---------------------------------------');
    
    FOR rec IN (
        SELECT S_NUM, SNAME
        FROM S
        WHERE EXISTS (
            SELECT 1
            FROM SP
            WHERE SP.S_NUM = S.S_NUM
              AND SP.P_NUM = 'P2'
        )
        ORDER BY S_NUM
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Proveedor: ' || rec.S_NUM || ' - ' || rec.SNAME);
    END LOOP;
END SP_PROVEEDORES_P2_EXISTS;
/

-- ============================================================================
-- 15. Proveedores que NO abastecen P2
-- ============================================================================
CREATE OR REPLACE PROCEDURE SP_PROVEEDORES_NO_P2 AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Proveedores que NO abastecen P2:');
    DBMS_OUTPUT.PUT_LINE('---------------------------------');
    
    FOR rec IN (
        SELECT S_NUM, SNAME
        FROM S
        WHERE NOT EXISTS (
            SELECT 1
            FROM SP
            WHERE SP.S_NUM = S.S_NUM
              AND SP.P_NUM = 'P2'
        )
        ORDER BY S_NUM
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Proveedor: ' || rec.S_NUM || ' - ' || rec.SNAME);
    END LOOP;
END SP_PROVEEDORES_NO_P2;
/

-- ============================================================================
-- 16. Proveedores que abastecen TODAS las partes
-- ============================================================================
CREATE OR REPLACE PROCEDURE SP_PROVEEDORES_TODAS_PARTES AS
    v_total_partes NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_total_partes FROM P;
    
    DBMS_OUTPUT.PUT_LINE('Proveedores que abastecen TODAS las partes:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    
    FOR rec IN (
        SELECT S.S_NUM, 
               S.SNAME, 
               COUNT(DISTINCT SP.P_NUM) AS PARTES_ABASTECIDAS
        FROM S, SP
        WHERE S.S_NUM = SP.S_NUM
        GROUP BY S.S_NUM, S.SNAME
        HAVING COUNT(DISTINCT SP.P_NUM) = v_total_partes
        ORDER BY S.S_NUM
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Proveedor: ' || rec.S_NUM || ' - ' || rec.SNAME);
    END LOOP;
END SP_PROVEEDORES_TODAS_PARTES;
/

-- ============================================================================
-- 17. Partes con peso > 16 libras O abastecidas por S2
-- ============================================================================
CREATE OR REPLACE PROCEDURE SP_PARTES_PESO_O_S2 AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Partes con peso > 16 libras O abastecidas por S2:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
    
    FOR rec IN (
        SELECT DISTINCT P.P_NUM, P.PNAME, P.WEIGHT
        FROM P
        WHERE P.WEIGHT > 16
           OR EXISTS (
               SELECT 1 
               FROM SP 
               WHERE SP.P_NUM = P.P_NUM 
                 AND SP.S_NUM = 'S2'
           )
        ORDER BY P.P_NUM
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Parte: ' || rec.P_NUM ||
                           ' (' || rec.PNAME || '), Peso: ' || rec.WEIGHT);
    END LOOP;
END SP_PARTES_PESO_O_S2;
/

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================

COMMIT;
