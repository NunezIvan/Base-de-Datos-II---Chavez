-- =============================================
-- LABORATORIO 06: TRANSACCIONES RELACIONALES
-- Base de Datos II
-- Universidad Nacional Mayor de San Marcos
-- =============================================

-- Ejercicio 1 – Control básico de transacciones
DECLARE
BEGIN
    UPDATE employees 
    SET salary = salary * 1.10 
    WHERE department_id = 90;
    
    SAVEPOINT punto1;
    
    UPDATE employees 
    SET salary = salary * 1.05 
    WHERE department_id = 60;
    
    ROLLBACK TO punto1;
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Ejercicio 1 completado');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error en Ejercicio 1: ' || SQLERRM);
END;
/

-- Ejercicio 2 – Bloqueos entre sesiones

-- Sesión 1:

UPDATE employees
SET salary = salary + 500
WHERE employee_id = 103;

-- Sesión 2 (en otra ventana):

UPDATE employees
SET salary = salary + 300
WHERE employee_id = 103;

-- Consulta para ver sesiones bloqueadas (Ejercicio 2c):
SELECT 
    s.sid, 
    s.serial#, 
    s.username,
    s.blocking_session,
    s.sql_id,
    s.status
FROM v$session s
WHERE s.blocking_session IS NOT NULL;


-- Ejercicio 3 – Transacción controlada con bloque PL/SQL
DECLARE
    v_old_department_id NUMBER;
    v_old_job_id VARCHAR2(10);
    v_hire_date DATE;
BEGIN

    SELECT department_id, job_id, hire_date
    INTO v_old_department_id, v_old_job_id, v_hire_date
    FROM employees
    WHERE employee_id = 104;
    
    UPDATE employees 
    SET department_id = 110 
    WHERE employee_id = 104;
    
    INSERT INTO job_history (
        employee_id, 
        start_date, 
        end_date, 
        job_id, 
        department_id
    ) VALUES (
        104,
        v_hire_date,
        SYSDATE,
        v_old_job_id,
        v_old_department_id
    );
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Transferencia del empleado 104 completada exitosamente');
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: Empleado 104 no encontrado');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error en la transferencia: ' || SQLERRM);
END;
/

-- Ejercicio 4 – SAVEPOINT y reversión parcial
DECLARE
BEGIN

    UPDATE employees 
    SET salary = salary * 1.08 
    WHERE department_id = 100;
    
    SAVEPOINT A;
    
    UPDATE employees 
    SET salary = salary * 1.05 
    WHERE department_id = 80;
    
    SAVEPOINT B;
    
    DELETE FROM employees 
    WHERE department_id = 50;
    
    ROLLBACK TO B;
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Ejercicio 4 completado');
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error en Ejercicio 4: ' || SQLERRM);
END;
/

-- Consultas para verificar cambios (Ejercicio 4c):
-- Ver salarios antes y después (para departamentos 100 y 80)
SELECT department_id, AVG(salary) as avg_salary
FROM employees 
WHERE department_id IN (100, 80)
GROUP BY department_id;

-- Verificar que no se eliminaron empleados del departamento 50
SELECT COUNT(*) as empleados_depto_50
FROM employees 
WHERE department_id = 50;

