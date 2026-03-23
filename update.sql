SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

BEGIN;
SELECT
    id
FROM
    news_articles
WHERE
    (title LIKE '%胡衡华%' OR content LIKE '%胡衡华%')
ORDER BY
    publish_time DESC;


UPDATE
    news_articles
SET
    is_deleted = 1
WHERE
    (title LIKE '%胡衡华%' OR content LIKE '%胡衡华%')
    AND is_deleted = 0;
COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
