CREATE INDEX order_product_order_id_idx ON order_product(order_id);

CREATE INDEX orders_status_date_idx ON orders(status, date_created);

CREATE INDEX order_product_product_id_idx ON order_product(product_id);

CREATE INDEX orders_date_created_idx ON orders(date_created);

CREATE INDEX orders_status_idx ON orders(status);

CREATE INDEX product_name_idx ON product(name);

CREATE INDEX product_price_idx ON product(price);
