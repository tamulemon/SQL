/*****************************************************/
-- all about user

--Login identification name 
SELECT SUSER_SNAME()
SELECT SUSER_NAME()
--PCLC0\mechen

SELECT CURRENT_USER
--PCLC0\mechen

--DOMAIN\user_login_name if using Windows Authentication, otherwise SQL Server login identification name
SELECT SYSTEM_USER
--PCLC0\mechen

--database username - a.k.a USER and CURRENT_USER
SELECT USER_NAME()

--current session's username
SELECT SESSION_USER

--------------------------------------

SELECT
    'Baseline' AS TestName ,
    ORIGINAL_LOGIN() AS [ORIGINAL_LOGIN], -- this will be consistant with the login even impersonated
    CURRENT_USER     AS [CURRENT_USER],-- will reflect the impersonated username
    SESSION_USER     AS [SESSION_USER],-- will reflect the impersonated username
    SYSTEM_USER      AS [SYSTEM_USER], -- will reflect the impersonated user login
    USER_NAME()      AS [USER_NAME], -- will reflect the impersonated username
    USER             AS [USER],-- will reflect the impersonated username
    SUSER_SNAME()    AS [SUSER_SNAME],  -- will reflect the impersonated user login
    SUSER_NAME()     AS [SUSER_NAME] -- will reflect the impersonated user login

--In short
--ORIGINAL_LOGIN, SYSTEM_USER, SUSER_SNAME, SUSER_NAME: login
--CURRENT_USER, SESSION_USER, USER_NAME, USER: user
-- if login and user is created as the same name, they will display same thing


-- this proves that Login and username can be different. This is my SQL server Authed TMO db result:
/*
TestName	ORIGINAL_LOGIN	CURRENT_USER	SESSION_USER	SYSTEM_USER	USER_NAME	USER	SUSER_SNAME	SUSER_NAME
Baseline             	mchen	mChen	mChen	mchen	mChen	mChen	mchen	mchen
*/


-- if system admin, Current_user = session_user = user_name = user = 'dbo'
-- otherwise, user name


--This is my windows Authed UO db result, meaning that my login and username is the same
/*
TestName	ORIGINAL_LOGIN	CURRENT_USER	SESSION_USER	SYSTEM_USER	USER_NAME	USER	SUSER_SNAME	SUSER_NAME
Baseline             	PCLC0\mechen	PCLC0\mechen	PCLC0\mechen	PCLC0\mechen	PCLC0\mechen	PCLC0\mechen	PCLC0\mechen	PCLC0\mechen
*/


/*****************************************************/
-- # of current open transaction
SELECT @@TRANCOUNT

-- # of rows affected by last statement
SELECT @@ROWCOUNT 