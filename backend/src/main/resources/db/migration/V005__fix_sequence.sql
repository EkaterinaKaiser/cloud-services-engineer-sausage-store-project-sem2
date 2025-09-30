-- Исправляем последовательность для таблицы orders
-- Устанавливаем счетчик на максимальное значение + 1
SELECT setval('orders_id_seq', (SELECT MAX(id) FROM orders) + 1);

-- Также исправим последовательность для products на всякий случай
SELECT setval('product_id_seq', (SELECT MAX(id) FROM product) + 1);
