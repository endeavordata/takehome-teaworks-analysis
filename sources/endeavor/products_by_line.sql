SELECT
    product_line,
    COUNT(*) AS sku_count
FROM products
GROUP BY product_line
ORDER BY sku_count DESC;
