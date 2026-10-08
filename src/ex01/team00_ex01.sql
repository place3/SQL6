WITH RECURSIVE way AS (
    SELECT
        start_node,
        end_node,
        price,
        ARRAY[start_node, end_node] AS route
    FROM connections
    WHERE start_node = 'a'
    UNION ALL
    SELECT
        path.start_node,
        step.end_node,
        path.price + step.price,
        path.route || step.end_node
    FROM way path
    JOIN connections step
        ON path.end_node = step.start_node
    WHERE step.end_node <> ALL(path.route)
       OR (
           step.end_node = 'a'
           AND array_length(path.route, 1) = 4
       )
)
SELECT
    price AS total_price,
    route
FROM way
WHERE end_node = 'a'
  AND array_length(route, 1) = 5
ORDER BY total_price, route;
