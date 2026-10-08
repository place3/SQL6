CREATE TABLE connections (
    start_node varchar,
    end_node varchar,
    price integer
);

-- вставляем 4 узла (a, b, c, d), (в обе стороны)
INSERT INTO connections (start_node, end_node, price) VALUES
('a', 'b', 10),
('b', 'a', 10),
('b', 'c', 35),
('c', 'b', 35),
('a', 'c', 15),
('c', 'a', 15),
('a', 'd', 20),
('d', 'a', 20),
('b', 'd', 25),
('d', 'b', 25),
('c', 'd', 30),
('d', 'c', 30);

-- рекурсивно строим все возможные маршруты из точки a
WITH RECURSIVE way AS (

    SELECT
        start_node,
        end_node,
        price,
        ARRAY[start_node, end_node] AS route
    FROM connections
    WHERE start_node = 'a'

    UNION ALL

    -- продлеваем построенный path
    SELECT
        path.start_node,
        step.end_node,
        path.price + step.price,
        path.route || step.end_node
    FROM way path
    JOIN connections step
        ON path.end_node = step.start_node
    -- разрешаем шагтолько если
    -- а -  новый узел ещё не встречался в маршруте
    -- б либо это финальное замыкание маршрута обратно в А
    --     когда уже пройдены все 4 узла графа
    WHERE step.end_node <> ALL(path.route)
       OR (
           step.end_node = 'a'
           AND array_length(path.route, 1) = 4
       )
),

-- только полностью завершённые маршруты:
-- тtчто вернулись обратно в А и включают все узлы графа
completed_way AS (
    SELECT
        price AS total_price,
        route
    FROM way
    WHERE end_node = 'a'
      AND array_length(route, 1) = 5
)

-- ластовый шаг находим маршрут/ы с минимальной суммарной стоимостью
SELECT
    total_price,
    route
FROM completed_way
WHERE total_price = (
    SELECT MIN(total_price)
    FROM completed_way
)
ORDER BY total_price, route;
