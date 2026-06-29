-- ============================================================
--  Проект: Тестирование данных в базе (SQL)
--  База: венчурные фонды и инвестиции в стартапы
--  (датасет Startup Investments, Kaggle)
-- ============================================================
--  СТРУКТУРА БАЗЫ (официальная ER-диаграмма Базового SQL)
--  PK — первичный ключ, FK — внешний ключ
-- ============================================================
--
--  company — компании-стартапы
--    id              PK
--    name            — название компании
--    category_code   — категория (например, news, social)
--    status          — acquired | operating | ipo | closed
--    founded_at      — дата основания
--    closed_at       — дата закрытия (если закрыта)
--    domain          — домен сайта
--    network_username— профиль в корпоративной сети биржи
--    country_code    — код страны (USA, GBR ...)
--    investment_rounds — число раундов как инвестор
--    funding_rounds  — число раундов привлечения инвестиций
--    funding_total   — сумма привлечённых инвестиций ($)
--    milestones      — число важных этапов
--    created_at, updated_at
--
--  fund — венчурные фонды
--    id              PK
--    name            — название фонда
--    founded_at      — дата основания
--    domain          — домен сайта
--    network_username
--    country_code
--    investment_rounds — число раундов с участием фонда
--    invested_companies — число проинвестированных компаний
--    milestones
--    created_at, updated_at
--
--  funding_round — раунды инвестиций
--    id              PK
--    company_id      FK -> company
--    funded_at       — дата проведения раунда
--    funding_round_type — venture | angel | series_a
--    raised_amount   — привлечённая сумма ($)
--    pre_money_valuation — оценка до инвестиций ($)
--    participants    — число участников раунда
--    is_first_round  — первый ли это раунд для компании
--    is_last_round   — последний ли это раунд
--    created_at, updated_at
--
--  investment — инвестиции фондов в компании
--    id              PK
--    funding_round_id FK -> funding_round
--    company_id      FK -> company
--    fund_id         FK -> fund
--    created_at, updated_at
--
--  acquisition — покупки одних компаний другими
--    id              PK
--    acquiring_company_id FK -> company (покупатель)
--    acquired_company_id  FK -> company (которую покупают)
--    term_code       — cash | stock | cash_and_stock
--    price_amount    — сумма покупки ($)
--    acquired_at     — дата сделки
--    created_at, updated_at
--
--  people — сотрудники компаний-стартапов
--    id              PK
--    first_name      — имя
--    last_name       — фамилия
--    company_id      FK -> company
--    network_username
--    created_at, updated_at
--
--  education — образование сотрудников
--    id              PK
--    person_id       FK -> people
--    degree_type     — BA (Bachelor of Arts) | MS (Master of Science)
--    instituition    — учебное заведение (так в схеме, с опечаткой)
--    graduated_at    — дата выпуска
--    created_at, updated_at
--
-- ============================================================


-- ------------------------------------------------------------
-- Задание 1: Посчитай, сколько компаний закрылось.
-- ------------------------------------------------------------
SELECT  
      COUNT (status)
FROM company
WHERE status = 'closed'
;


-- ------------------------------------------------------------
-- Задание 2: Отобрази количество привлечённых средств для новостных компаний США. Используй данные из таблицы company. Отсортируй таблицу по убыванию значений в поле funding_total.
-- ------------------------------------------------------------
SELECT  
        funding_total
FROM company
WHERE country_code = 'USA'
      AND category_code = 'news'
ORDER BY funding_total DESC      
;


-- ------------------------------------------------------------
-- Задание 3: Отобрази имя, фамилию и названия аккаунтов людей в поле network_username, которые начинаются на 'Silver'.
-- ------------------------------------------------------------
SELECT 
        first_name,
        last_name,
        network_username
FROM people
WHERE network_username LIKE 'Silver%'
;


-- ------------------------------------------------------------
-- Задание 4: Выведи на экран всю информацию о людях, у которых названия аккаунтов в поле network_username содержат подстроку 'money', а фамилия начинается на 'K'.
-- ------------------------------------------------------------
SELECT  
        *
FROM people
WHERE network_username LIKE '%money%'
      AND last_name LIKE 'K%'
;


-- ------------------------------------------------------------
-- Задание 5: Для каждой страны отобрази общую сумму привлечённых инвестиций, которые получили компании, зарегистрированные в этой стране. Страну, в которой зарегистрирована компания, можно определить по коду страны. Отсортируй данные по убыванию суммы.
-- ------------------------------------------------------------
SELECT 
       SUM(funding_total),
       country_code
FROM company
GROUP BY country_code
ORDER BY SUM(funding_total) DESC
;


-- ------------------------------------------------------------
-- Задание 6: Отобрази имя и фамилию всех сотрудников стартапов. Добавь поле с названием учебного заведения, которое окончил сотрудник, если эта информация известна.
-- ------------------------------------------------------------
SELECT  
        p.first_name,
        p.last_name,
        e.instituition
FROM people AS p
LEFT JOIN education AS e ON p.id = person_id
;


-- ------------------------------------------------------------
-- Задание 7: Найди общую сумму сделок по покупке одних компаний другими в долларах. Отбери сделки, которые осуществлялись только за наличные с 2011 по 2013 год включительно.
-- ------------------------------------------------------------
SELECT  
        SUM(price_amount)
FROM acquisition
WHERE term_code = 'cash'
      AND acquired_at BETWEEN '2011-01-01' AND '2013-12-31'
;


-- ------------------------------------------------------------
-- Задание 8: Выясни, в каких странах находятся фонды, которые чаще всего инвестируют в стартапы. 
-- Для каждой страны посчитай минимальное, максимальное и среднее число компаний, в которые инвестировали фонды этой страны, основанные с 2010 по 2012 год включительно. Исключи страны с фондами, у которых минимальное число компаний, получивших инвестиции, равно нулю. 
-- Выгрузи десять самых активных стран-инвесторов: отсортируй таблицу по среднему количеству компаний от большего к меньшему. Затем добавь сортировку по коду страны в лексикографическом порядке.
-- ------------------------------------------------------------
SELECT  
        MIN(invested_companies),
        MAX(invested_companies),
        AVG(invested_companies), country_code


FROM fund
WHERE founded_at BETWEEN '2010-01-01' AND '2012-12-31'
GROUP BY country_code
HAVING MIN(invested_companies) > 0
ORDER BY AVG(invested_companies) DESC, country_code
LIMIT 10
;

